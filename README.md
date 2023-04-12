# amboso

## Totally serious build tool, powered by bash.

I wanted to build some project versions I tagged on github but of which I tought I couldn't get the commits anymore, while still having source. (?????)

I wanted to handle commits and those sweet diffs instead of full source versions. But the thrill of wasting space (instead of supporting right away git checkout on tags) before pushing this repo was too much.

I did not want to learn how to write nice makefiles or chaining a couple git commands to checkout. Not at all. Not required to use this, the Makefile will appear by itself. Dang `make`.

### I wanted to name a build tool `anvil`, while also making it sound like I'm  bozo for doing this poor `make` frontend. Or bad VCS, depending on how little you value and understand git by itself (which is quite the service, we must say).

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

### Beware of spaces:

### Space is not a separator ATM for the line parsing, so if you want to write a comment (after using #) you have to make sure you put the hashtag directly after your value, like so:

```
my_value=1# A nice comment
```

**NOT** like this:

```
my_value=1 # A bad comment
```

That extra space will hit you hard. Almost as hard as switching to awk from cut.
This is not a big problem and will be solved TODO soom tm Be mindful tho

## try-anvil

Backtraced script running `./anvil` with various flags using the provided ./bin example references.

This command hints you to symlinking `./amboso` to `super_repo/anvil`, and shows differents outputs based on the queries made.

## bin/

### Contains a directory for each supported version (directories **must** start with an extra v prepended to the tag name, like so:

`super_repo/amboso/`
├── amboso
├── bin
│   ├── `stego.lock`
│   ├── v0.1.0
│   │   └── `hello_world.c`
│   └── v0.9.0
│       ├── `hello_world.c`
│       └── `Makefile`

```
bin/vVERS_NAME/executable
```
ie. directory bin contains a directory "vMYTAG" for each supported version with name MYTAG.
It also contains the stego.lock file.

The script **always** needs to know the directory containing the target builds, so **if you don't define one yourself** when running, by using -D :

```
amboso -D SOME_DIR -h
```

, amboso will assume the target directory is in its current working directory and called 'bin', so `./bin`, and launch again setting the -D value, to then try and gather all -S -E -M flags.

## Mantaining compatibility with amboso assumptions

Using amboso for a project requires some costraints to be valid both from the repo perspective **and** from the build process perspective.

### For the repo:

  I guess it may not be necessarily, 100% true, but you pretty much **always** need a `stego.lock` file to keep the main compliance checks stable.
  It will store the source file name for single file mode and the target binary name.
  It also stores the lowest version implementing make so that you can easily jump into a small project and worry a bit later about writing a proper Makefile.
  Even tought it only takes a couple minutes to do that, we like to postpone.

  Sticking to a source file name and a target executable name should be pretty easy (maybe similar to repo name?). Plus, you can definitely change idea about those later, by always checking in your lock.
  I can't recommend using the -D flag everytime just to tell amboso where to look, but I guess a fallback option to provide a different default directory name than `./bin` could be easily added. TODO coming soon tm

  You must assure idempotency of the checkout-back to the main version, to run in git mode. This is accomplished by correctly setting up your `.gitignore`, so that all object files & the executable are always ignored in all supported versions.
  This requirement cannot be mitigated retroactively, as you can't touch the tag commit containing the `.gitignore`. But I think skipping object files and the main project executable should be standard practice.
  Also I guess having to prepend every tag directory with 'v' may not be the best, but it's something we could change support for in the future.

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

That's it, I guess. Coming soon with that dang commit support.
