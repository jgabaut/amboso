#!/usr/bin/env python3

from pathlib import Path
import html
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
MAN_DIR = ROOT / "man"
SITE_DIR = ROOT / "_site"


CSS = r"""
:root {
    color-scheme: light dark;
    --bg: #ffffff;
    --fg: #24292f;
    --muted: #57606a;
    --border: #d0d7de;
    --link: #0969da;
    --code-bg: #f6f8fa;
}

@media (prefers-color-scheme: dark) {
    :root {
        --bg: #0d1117;
        --fg: #e6edf3;
        --muted: #8b949e;
        --border: #30363d;
        --link: #58a6ff;
        --code-bg: #161b22;
    }
}

* {
    box-sizing: border-box;
}

body {
    max-width: 1000px;
    margin: 0 auto;
    padding: 2rem;
    background: var(--bg);
    color: var(--fg);
    font-family:
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;
    line-height: 1.6;
}

a {
    color: var(--link);
}

a:hover {
    text-decoration: underline;
}

h1,
h2,
h3,
h4,
h5,
h6,
code,
pre {
    font-family:
        ui-monospace,
        SFMono-Regular,
        Menlo,
        Monaco,
        Consolas,
        "Liberation Mono",
        monospace;
}

h1 {
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--border);
}

pre {
    padding: 1rem;
    overflow-x: auto;
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: 6px;
}

code {
    font-size: 0.9em;
}

nav {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--border);
}

nav a {
    text-decoration: none;
    font-weight: 600;
}

nav a:hover {
    text-decoration: underline;
}

.manual-content {
    overflow-x: auto;
}

@media (max-width: 700px) {
    body {
        padding: 1rem;
    }
}
"""


def die(message):
    print(f"error: {message}", file=sys.stderr)
    sys.exit(1)


def section_from_path(path):
    # man/man1/foo.1 -> "1"
    return path.parent.name.removeprefix("man")


def page_name(path):
    # foo.1 -> foo(1)
    return f"{path.stem}({section_from_path(path)})"


def output_name(path):
    # foo.1 -> foo.1.html
    return path.name + ".html"


def add_style(document, navigation):
    """Inject our stylesheet and navigation into a mandoc HTML document."""

    style = f"<style>\n{CSS}\n</style>"

    # Add CSS before </head>.
    if "</head>" in document:
        document = document.replace(
            "</head>",
            f"{style}\n</head>",
            1,
        )
    else:
        document = f"<style>{CSS}</style>\n{document}"

    # Add navigation immediately after <body>.
    if "<body>" in document:
        document = document.replace(
            "<body>",
            f"<body>\n{navigation}",
            1,
        )

    return document


def render_manpage(source, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)

    result = subprocess.run(
        ["mandoc", "-T", "html", str(source)],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        die(f"failed to render {source}")

    navigation = """
<nav>
    <a href="../index.html">← Manual index</a>
</nav>
"""

    document = add_style(result.stdout, navigation)

    destination.write_text(document, encoding="utf-8")


def find_manpages():
    if not MAN_DIR.exists():
        die(f"missing {MAN_DIR}")

    return sorted(
        path
        for path in MAN_DIR.glob("man[1-9]/*")
        if path.is_file()
        and re.fullmatch(r".+\.[1-9]", path.name)
    )


def make_index(pages):
    groups = {}

    for page in pages:
        section = section_from_path(page)
        groups.setdefault(section, []).append(page)

    sections = []

    for section in sorted(groups):
        entries = []

        for page in groups[section]:
            title = page_name(page)
            href = f"man{section}/{output_name(page)}"

            entries.append(
                f"""        <li>
            <a href="{html.escape(href)}">
                <code>{html.escape(title)}</code>
            </a>
        </li>"""
            )

        sections.append(
            f"""    <section>
        <h2>Section {html.escape(section)}</h2>
        <ul>
{chr(10).join(entries)}
        </ul>
    </section>"""
        )

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manual</title>
<style>
{CSS}
</style>
</head>
<body>

<h1>Manual</h1>

{chr(10).join(sections)}


<a href="https://github.com/jgabaut/amboso/wiki">
Wiki
</a>
<br>
<a href="https://github.com/jgabaut/amboso">
amboso repo
</a>
<br>
<a href="https://github.com/jgabaut/invil">
invil repo
</a>
<br>
<a href="https://github.com/jgabaut/canvil">
canvil repo
</a>

</body>
</html>
"""


def main():
    pages = find_manpages()

    if not pages:
        die(f"no manpages found under {MAN_DIR}/man[1-9]/")

    # Remove the previous build so deleted manpages don't remain published.
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)

    SITE_DIR.mkdir(parents=True)

    for source in pages:
        section = section_from_path(source)
        destination = SITE_DIR / f"man{section}" / output_name(source)

        print(
            f"{source.relative_to(ROOT)} "
            f"-> {destination.relative_to(ROOT)}"
        )

        render_manpage(source, destination)

    index = SITE_DIR / "index.html"
    index.write_text(make_index(pages), encoding="utf-8")

    print()
    print(f"Built {len(pages)} manpage(s) into {SITE_DIR}")


if __name__ == "__main__":
    main()
