# amboso

## A build tool wrapping make, with some git integration, powered by bash.

## Table of Contents

+ [What is this thing?](#witt)
  + [Prerequisites](#prerequisites)
  + [See how it behaves](#tryanvil)
+ [General Usage](#generalusage)
  + [stego.lock](#stego)
  + [Hard failure](#bin)
  + [Tests directory](#kazoj)
  + [Test mode](#test_mode)
+ [Maintaining compatibility](#amboso_env)
  + [For the super repo](#super_repo)
  + [.gitignore for git mode](#gitignore_gitmode)
  + [For the build process](#build_step)
  + [About git mode](#git_mode)
+ [Why should I consider using this?](#reasons)
+ [Local installation](#local_install)
+ [Legacy notes](#legacy_notes)
  + [Legacy version dirs](#legacy_version_dirs)
+ [Todo](#todo)

### Note

This script has reached a size where I prefer moving development to a different language.

At the moment, a complementary implementation in Rust is being worked on [at this repo link](https://github.com/jgabaut/invil).

Having to rely on the Rust compiler is less flexible than a shell script, but the runtime alone can have such better results it's worth the move.

Since version 1.8, a steady stream of patches have been included to ease the transition, with 2.0, to the Rust implementation as the refence one.

Notably, version 1.9.x is highly unstable (in the sense that breaking changes have been made at patch level), and as such, should be considered deprecated once 2.0 is reached.

## What is this thing? <a name = "witt"></a>

This tool is just a bash script handling some flags to perform automated builds (leveraging `make`, so there isn't much you can do "only" with this script) and tests.

If you want to run something like `git checkout vMY_TAG; make`, then you may need a few other args to move the completed build to an ordered directory tree.

`amboso` uses a simple text file to pin some tags your repo offers, and enables your repo to handle a directory where you can keep all compiled version while keeping a clean `git status`.

The idea is nothing great.

I wanted to build some older tagged version of a C project I was building using make, but for some of them I didn't have a proper past commit.

I decided to try a little script to help me do this in the future, one command to prepare any tagged version I'd want, even tough I think this probably makes no sense to use over other build systems.

Still, the added benefit of this little tool was worth the time for me.

I did not want to learn how to write nice makefiles or chaining a couple git commands to checkout... Wait, you might still need to do that for this? Sigh...

### I wanted to name a build tool `anvil`, while also making it sound like I'm  bozo for doing this poor `make` frontend.

## Prerequisites <a name = "prerequisites"></a>

* At the moment the only supported build step command is `make rebuild`. This means you use make to run the target `rebuild`.
  * Running with `-R` turns this back to the original behaviour, running just `make` with no target argument.

* You definitely need `bash`, I'm using version `5.1.x` but for now I don't know about incompatible features used here.
  * For macOS users: check this issue for unexpected behaviour on bash `3.x`. [#21](/../../issues/21)

* You need `gawk` to be your `awk` symlink. While work to support `nawk` and `mawk` will be coming, it's not a priority as of now.
  * macOS ships with `nawk` by default, but if you have `brew` installed, you should be able to run
    `brew install gawk`
  * After that, it's just a matter of changing the `awk` binary to be a symlink to `gawk`. Maybe copy it to `awk.bkp` first.

* You should test you have `bc` installed, since it's used to calc runtimes.

## See how it behaves <a name = "tryanvil"></a>

To see how this marvelous work of art works, run:

```sh
  cd try-anvil
  ./try_anvil
```

## try-anvil dir

All commands ran by the scripts will be shown on screen with a `+` before them.

`try-anvil/try_anvil` It's a script running `./anvil` with various flags using the provided ./bin example references, so you can see how to call amboso with different flags.

### Note

- The script symlinks `amboso` to `./anvil`, using `ln -s PATH_TO/amboso/amboso ./anvil`.

  - If you include this repo as a submodule, you should also do the same and have the `anvil` link in your main repo directory, so you can call that instead of `REPO/amboso/amboso`.

  - If you installed `anvil` globally with `sudo make install`, you should be mindful of different anvil versions if you are using this repo as a submodule.

  - When running inside a dir containing an `amboso` folder, `anvil` will try to source `amboso_fn.sh` from `./amboso/amboso_fn.sh` instead of the file located inside global installation `/usr/local/bin/amboso_fn.sh`.
  - You should see a warning message if a version mismatch occurs.

This command hints you to symlinking `./amboso` to `super_repo/anvil`, and shows differents outputs based on the queries made.

It can now also show how the repo itself complies with amboso specs to run in git mode.

## General usage <a name = "generalusage"></a>

## stego.lock <a name = "stego"></a>

This file contains user-defined tags for supported versions and fundamental CLI arguments you don't want to type again.

Defined env arguments are in this format:
```
envvalue = "val"
```

Defined tags are in this format:
```
"0.1.0" = "Desc"
```

You can define both git-mode tags and base-mode tags , each supported when running in the corresponding mode.

Definition of a base-mode tag **must** start with a `-`, like so
```
"-0.0.1" = "1"# A nice comment
```
The `-` character will not be a part of your tag name, it only marks base-mode tags when at the start of a tag name.

## Hard failure <a name = "bin"></a>

I'll tell you that even the help option can fail, if you don't point this child to where your targets are and rely on naming your compliant folder `./bin/`.
You have a bin/ directory in the repo to test this behaviour.
Locating folders is probably the only thing this script does, yet you still have to make sure to setup a proper amboso base directory with the targets dirs, and the `stego.lock` file.

You should rely on your `stego.lock` file to ensure you don't have to retype arguments you're 100% positive are correct, just to get the damn thing to build.

### Note

Since I've been using `/bin/` as a target dir myself, I haven't tested the script too much with the passing a different dirname with -D flag.

I will look into this to ensure you don't have to stick to this name for the target directory.

## bin/

Contains a directory for each supported tag (directories **must** start with an extra v prepended to the tag name, like so:

```console
super-repo
├── amboso
│   ├── amboso
│   ├── bin
│   │   ├── stego.lock
│   │   ├── v0.1.0
│   │   │   └── hello_world.c
│   │   ├── v0.9.0
│   │   │   ├── hello_world.c
│   │   │   └── Makefile
│   │   ├── v1.0.0
│   │   └── v1.1.0
│   │   └── v1.1.1
│   ├── kazoj
│   │   ├── bone
│   │   │   └── good_test_exe
│   │   └── kulpo
│   │       └── bad_test_exe
│   ├── CODEOWNERS
│   ├── hello_world.c
│   ├── LICENSE
│   ├── Makefile
│   ├── README.md
│   └── try-anvil
│       ├── try_anvil
│       └── try_anvil_auto
├── kazoj
```

```
bin/vTAG_NAME/executable
```
ie. directory bin contains a directory named "vMYTAG" for each supported version with name "MYTAG".
It also contains the stego.lock file.

Having to prepend every tag directory with 'v' may not be the best, but it's something we could change support for in the future.

The script **always** needs to know the directory containing the target builds, so **if you don't define one yourself** when running, by using -D :

```sh
amboso -D SOME_DIR -h
```

, amboso will assume the target directory is in its current working directory and called 'bin', so `./bin`, and will try to read `stego.lock` to then try and gather all the values needed for -S -E -M flags.

## kazoj/ <a name = "kazoj"></a>

Contains a directory for each test group, ATM there's one for successful tests and one for failures. The two subdirectories can have any name and they are to be specified in `kazoj.lock`. Canonic names are, respectively:
- `bone` : The general directory, for successful tests
- `kulpo` : The error directory, for failure tests

You should have your own `kazoj` directory (which you can specify in `stego.lock`), in your super-repo.
And there, there should be a `kazoj.lock` file to remember the names of your cases/errors folders.
Maybe run it with your super-repo `anvil` symlink.

## Test mode <a name = "test_mode"></a>

Running `anvil` with `-t` or `-T` will start test mode.

- If using `-t`, `anvil` will try to run ALL detected executable tests.
- If using `-T`, `anvil` should only try to test the passed QUERY tag (must be a valid test name).

- Use `-i` to record all the tests stdout and stderr to aptly named files.
- You can do the same for just 1 file with `-b`.



## Maintaining compatibility <a name = "amboso_env"></a>

Using amboso in a project requires some costraints to be valid both from the repo perspective **and** from the build process perspective.

### For the super repo: <a name = "super_repo"></a>

Use a `stego.lock` file to keep the main compliance checks stable.

It will store the source file name for single file mode and the target binary name.

It also stores the lowest version providing a Makefile, so that you can easily jump into a small project and not set up make right away (why not I guess).
Even tought it only takes a couple minutes to do that, we like to postpone.

Sticking to a source file name and a target executable name should be pretty easy (maybe similar to repo name?).

Plus, you can definitely change idea about those later, by always checking in your lock.

I can't recommend using the -D flag everytime just to tell amboso where to look, but a fallback option to provide a different default directory name than `./bin` through the `stego.lock` itself could be added.

### .gitignore for git mode  <a name = "gitignore_gitmode"></a>

To successfully use git mode, you must assure idempotency of the switch back to the main version. This is accomplished by correctly setting up your `.gitignore`, so that all object files & the executable are always ignored in all supported versions, and by always having the needed directory for any tag ready inside the tagged commit.
This must be done for the first version you want to support in git mode, and can stay pretty much untouched after.
Your repo `.gitignore` should include some lines like this:

```
# ignore all object files
*.o
# also explicitly ignore our executable for good measure
BIN-NAME
# and also explicitly ignore our debug executable for good measure
DEBUG-BIN-NAME
# also ignore our builds dir
BUILDS-DIR-NAME
```
Where:
  - BIN-NAME is the target executable
  - DEBUG-BIN-NAME is its eventual debug compiled version
  - BUILDS-DIR-NAME is the directory that you're expecting to use to store the built versions.
    - If it's inside the repo, it's best to gnore it as a whole.
    - If you're targeting `amboso <2.0.4`, you must refer to the legacy handling of things, which included committing a new directory for every new amboso-supported tag... Link [here](#legacy_version_dirs).

That's it. You can easily

I guess suggesting skipping object files and the main project executable is not a hot take.

### For the build process: <a name = "build_step"></a>

You need to make sure all supported tags compile down to the same binary name (we'll see about this if/when we support other languages), and also that the eventual `make clean` correctly handles all the stuff not included in the tag itself.
I don't think pegging the executable name is that restricting, as you could always use repo name. And maybe pretend symlinks are more than that to have a fancier name. :P

Especially for tags using a Makefile, you should make sure to actually output the compilation artifacts to the correct directory. Provided examples assume the output from compilation goes directly to repo root dir (where also your `./anvil` and `./bin` should ideally be).
And I guess I must say that this script being mostly make frontend should tell you enough about the fact that you still need to create the Makefile for your project, if planning to use make as the build step tool. And here it is for another TODO add support for giving your own build/clean command. Coming soon tm

## About git mode <a name = "git_mode"></a>

All files generated at runtime and not idempotently checked in will cause the `git switch -` to fail when trying to script the undoing of queried tag checkout.
You could script the removal of untracked files, but it only makes sense for the single file build, and you would still need to provide the full list of files to delete if you don't want to have bad surprises.
I guess we could do `git clean -f -d` (also -d for the comfy dry run) but that risks too much, adding -i would make the cleaning interactive.

Tags supported by amboso running in git mode would be a subset of ` git tag -l `. This could mean supporting a non-compliant tag could be done with a full source build maintained inside the bin/v**VERS** directory. I don't know about that, if we're gonna front-end git tags better try to do it well.

## Why would I use this when I can generate a Makefile automatically, or something? <a name = "reasons"></a>

Good question, you shouldn't. No reason at all. Go back to your serious build system and leave these silly kid scripts to me.

## Local installation <a name = "local_install"></a>

Running:

```
sudo make install
```

copies `amboso_fn.sh` and `amboso` (renamed as `anvil`) to `/usr/local/bin`.

This allows calls to amboso plug into any directory, by having a default path.

Not much useful by itself, since you won't probably have a compliant `stego.lock` in a random directory.
May be useful to me to anchor a default version locally.

Run `sudo make uninstall` to clean the installed files.

## Legacy notes <a name = "legacy_notes"></a>

This section contains notes about previous versions of `amboso`.

### Legacy version directories <a name = "legacy_version_dirs"></a>

#### This info only applies to amboso <= 2.0.3. After 2.0.4, there's no need to prepare the build directory tree beforehand.

**All** of your "version" directories (`vMYTAG/`) must include a `.gitignore` with some lines like this:

```
# You should put this .gitignore inside every one of your vMYTAG folders, each one before creating its own tagged commit on the repo:
*
!.gitignore
#
#The * line tells git to ignore all files in the folder, but !.gitignore tells git to still include the .gitignore file, thus keeping the directory checked in with your tag.
```

## Todo <a name = "todo"></a>

* Since the script is just selecting your `stego.lock` file to find the path to the correct target dir for your tag, we could try to use something other than `make`.
* ATM I don't really see how to easily change that, and `amboso` is pretty long already. Maybe a second argument with the path to your build-step script?
