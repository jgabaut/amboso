# amboso

## Totally serious build tool written in bash.

- I wanted to build some project versions I tagged on github but of which I tought I couldn't get the commits anymore, while still having source.

- I wanted to handle commits and those sweet diffs instead of full source versions. But the thrill of wasting space (instead of supporting git checkout on tags) before pushing this repo was too much.

- I wanted to not learn how to write nice makefiles or chaining a couple git commands to checkout.

- I wanted to use the esperanto word for anvil on a build tool, while also naming it to sound like I'm a bozo for doing this poor make frontend. Or bad VCS, depending on how little you value and understand git by itself (which is quite the service, we must say).

To see how this marvelous work of art works, try running :

```
$ ./amboso -h
```

I'll tell you that even the help option can fail, if you don't point this child to where your targets are and rely on naming your compliant folder "./bin/".
You can rely on your stego.lock file to ensure you don't have to retype arguments you're 100% positive are correct, just to get the damn thing to build.

# stego.lock

## This file contains user-defined tags for supported versions and fundamental CLI arguments you don't want to type again.

#### Defined tags can't containg the character #, as that marks start of command.

#### Beware of spaces: space is not a separator ATM for the line parsing, so if you want to write a comment (after using #) you have to make sure you put the hashtag directly after your value, like so:

```
my_value=1# A nice comment
```
**NOT** like this:
```
my_value=1 # A nice comment
```
That extra space will hit you hard. Almost as hard as switching to awk from cut.

# bin

## Contains a directory for each supported version (directories **must** start with an extra v prepended to the tag name, like so:

```
bin/v012345/
```
ie. directory bin contains a directory "vMYTAG" for each supported version with name MYTAG.
It also contains the stego.lock file.

#### The script always needs to know the directory containing the target builds, so if you don't define one yourself by running:

```
amboso -D SOME_DIR -h
```

#### It will assume the target directory is in the working directory and called 'bin', so `./bin`.

That's it, I guess. Coming soon with that dang commit support.
