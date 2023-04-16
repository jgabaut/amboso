# amboso

## A make frontend with some git integration, powered by bash.

I wanted to build some older tagged version of a C project I was building using make, but for some of them I didn't have a proper past commit.

I decided to try a little script to help me do this in the future, one command to prepare any tagged version I'd want, even tough I think this probably makes no sense to use over other build systems.

Still, the added benefit of this little tool was worth the time for me.

I did not want to learn how to write nice makefiles or chaining a couple git commands to checkout... Wait, you might still need to do that for this? Sigh...

### I wanted to name a build tool `anvil`, while also making it sound like I'm  bozo for doing this poor `make` frontend.

To see how this marvelous work of art works, run:

```
$ ./try_anvil
```

I'll tell you that even the help option can fail, if you don't point this child to where your targets are and rely on naming your compliant folder "./bin/".
You have a bin/ directory in the repo to test this behaviour.

You should rely on your `stego.lock` file to ensure you don't have to retype arguments you're 100% positive are correct, just to get the damn thing to build.

## stego.lock

This file contains user-defined tags for supported versions and fundamental CLI arguments you don't want to type again.

Defined tags are terminated by a **mandatory** # character, which marks start of comment.

You can define either git-mode tags or base-mode tags , each supported when running in the corresponding mode.

Definition of a base-mode tag **must** start with a '?', like so
```
?my_value=1# A nice comment
```
The '?' character will not be a part of your tag name, it only marks base-mode tags when at the start of a tag name.

## Beware of spaces:

Space is a valid separator for `stego.lock` lines, so ie. you can't have a tag name containing spaces.

I suggest you write your comments like this, even if not strictly needed:

```
my_value=1# A nice comment
```

**NOT** like this:

```
my_value=1 # A bad comment
```

## try-anvil

Backtraced script running `./anvil` with various flags using the provided ./bin example references.

This command hints you to symlinking `./amboso` to `super_repo/anvil`, and shows differents outputs based on the queries made.

It can now also show how the repo itself complies with amboso specs to run in git mode.

## bin/

### Contains a directory for each supported tag (directories **must** start with an extra v prepended to the tag name, like so:

```
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
│   ├── CODEOWNERS
│   ├── hello_world.c
│   ├── LICENSE
│   ├── Makefile
│   ├── README.md
│   └── try_anvil

```

```
bin/vTAG_NAME/executable
```
ie. directory bin contains a directory named "vMYTAG" for each supported version with name "MYTAG".
It also contains the stego.lock file.

Having to prepend every tag directory with 'v' may not be the best, but it's something we could change support for in the future.

The script **always** needs to know the directory containing the target builds, so **if you don't define one yourself** when running, by using -D :

```
amboso -D SOME_DIR -h
```

, amboso will assume the target directory is in its current working directory and called 'bin', so `./bin`, and will try to read `stego.lock` to then try and gather all the values needed for -S -E -M flags.

## Mantaining compatibility with amboso assumptions

Using amboso in a project requires some costraints to be valid both from the repo perspective **and** from the build process perspective.

### For the repo:

I guess you pretty much need a `stego.lock` file to keep the main compliance checks stable.
It will store the source file name for single file mode and the target binary name.
It also stores the lowest version providing a Makefile so that you can easily jump into a small project and not set up make right away (why not I guess).
Even tought it only takes a couple minutes to do that, we like to postpone.

Sticking to a source file name and a target executable name should be pretty easy (maybe similar to repo name?). Plus, you can definitely change idea about those later, by always checking in your lock.
I can't recommend using the -D flag everytime just to tell amboso where to look, but I guess a fallback option to provide a different default directory name than `./bin` could be easily added. TODO coming soon tm

### git checkout tag && git switch -
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
```
Where BIN-NAME is the target executable and DEBUG-BIN-NAME is its eventual debug compiled version.

**All** of your "v" directories ("vMYTAG") must include a `.gitignore` with some lines like this:

```
# You should put this .gitignore inside every one of your vMYTAG folders, each one before creating its own tagged commit on the repo:
*
!.gitignore
#
#The * line tells git to ignore all files in the folder, but !.gitignore tells git to still include the .gitignore file, thus keeping the directory checked in with your tag.
```

I guess suggesting skipping object files and the main project executable is not a hot take.

### For the build process:

You need to make sure all supported tags compile down to the same binary name (we'll see about this if/when we support other languages), and also that the eventual `make clean` correctly handles all the stuff not included in the tag itself.
I don't think pegging the executable name is that restricting, as you could always use repo name. And maybe pretend symlinks are more than that to have a fancier name. :P

Especially for tags using a Makefile, you should make sure to actually output the compilation artifacts to the correct directory. Provided examples assume the output from compilation goes directly to repo root dir (where also your `./anvil` and `./bin` should ideally be).
And I guess I must say that this script being mostly make frontend should tell you enough about the fact that you still need to create the Makefile for your project, if planning to use make as the build step tool. And here it is for another TODO add support for giving your own build/clean command. Coming soon tm

## About git mode

All files generated at runtime and not idempotently checked in will cause the `git switch -` to fail when trying to script the undoing of queried tag checkout.
You could script the removal of untracked files, but it only makes sense for the single file build, and you would still need to provide the full list of files to delete if you don't want to have bad surprises.
I guess we could do `git clean -f -d` (also -d for the comfy dry run) but that risks too much, adding -i would make the cleaning interactive.

Tags supported by amboso running in git mode would be a subset of ` git tag -l `. This could mean supporting a non-compliant tag could be done with a full source build mantained inside the bin/v**VERS** directory. I don't know about that, if we're gonna front-end git tags better try to do it well.

## Why would I use this when I can generate a Makefile automatically, or something?

Good question, you shouldn't. No reason at all. Go back to your serious build system and leave these silly kid scripts to me.
