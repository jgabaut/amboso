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

    destination.write_text(result.stdout, encoding="utf-8")


def find_manpages():
    if not MAN_DIR.exists():
        die(f"missing {MAN_DIR}")

    return sorted(
        path
        for path in MAN_DIR.glob("man[1-9]/*")
        if path.is_file() and re.fullmatch(r".+\.[1-9]", path.name)
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
                f'        <li>'
                f'<a href="{html.escape(href)}">'
                f'<code>{html.escape(title)}</code>'
                f'</a>'
                f'</li>'
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
body {{
    max-width: 900px;
    margin: 0 auto;
    padding: 2rem;
    font-family: system-ui, sans-serif;
    line-height: 1.5;
}}

h1, h2, code {{
    font-family: ui-monospace, monospace;
}}

section {{
    margin: 2rem 0;
}}

li {{
    margin: 0.5rem 0;
}}

a {{
    color: #0969da;
    text-decoration: none;
}}

a:hover {{
    text-decoration: underline;
}}

@media (prefers-color-scheme: dark) {{
    body {{
        background: #0d1117;
        color: #e6edf3;
    }}

    a {{
        color: #58a6ff;
    }}
}}
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

    # Start from a clean output directory so deleted manpages don't
    # remain published.
    if SITE_DIR.exists():
        shutil.rmtree(SITE_DIR)

    SITE_DIR.mkdir(parents=True)

    for source in pages:
        section = section_from_path(source)
        destination = SITE_DIR / f"man{section}" / output_name(source)

        print(f"{source.relative_to(ROOT)} -> {destination.relative_to(ROOT)}")
        render_manpage(source, destination)

    index = SITE_DIR / "index.html"
    index.write_text(make_index(pages), encoding="utf-8")

    print()
    print(f"Built {len(pages)} manpage(s) into {SITE_DIR}")


if __name__ == "__main__":
    main()
