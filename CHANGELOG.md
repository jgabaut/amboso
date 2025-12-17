# Changelog

## [2.1.0] - 2025-12-17

### Added

- Improved stego parsing, supporting more complex entries
- Add test subcommand
  - Runs all tests or the specified test name
  - Supports `-l` for listing all tests, `-b` to record
- Add `-I` to set builds dir
- Support `-k` in init subcommand
  - `anvilPy` kern: `main.py` and `pyproject.toml`
  - `custom` kern: copy a template project by name from `~/.anvil/templates/TEMPLATE`
- Support `anvilPy` in `-G` mode
- Pass extra arguments to build step in `amboso-C`, `custom` kern
- Add `utils/anvil_args.h` for build scripts in C that want to use the `custom` kern passed args

### Changed

- Drop `amboso_fn.sh` sourcing
- Get all values for anvilPy kern using the new support rather than grepping
- Fix message for `custom_build_step()`
- Handle `-tl` to list all test names
- Check build system for `anvilPy`
- Add `akcipitro` commit mentions
- Handle dashes in dir name for `init` subcommand
- Handle no op specified for `anvilPy`, `custom` kern

## [2.0.12] - 2025-06-17

### Changed

- Guard splash and invil notice with quiet flag

## [2.0.11] - 2025-04-11

### Added

- Add `amboso_test_step()`

### Changed

- Refactor test macro to be iterative
- Fix `-t` macro using `i` as an index
  - Was being updated by functions called inside
- Refactor usage of `i` as an index
- Refuse `AMBOSO_LVL_REC == 3`
- Refuse`-Ti` when running as `>=2.0.11`
- Wrap `-Ti` behaviour as legacy support
- Fix word splitting in `anvilPy_build_step()`
- Fix git mode CI:
  - Specify `fetch-depth` for workflow checkout since tags are needed
  - Add --detach to the switchback after a checkout coming from detached HEAD

## [2.0.10] - 2025-03-31

### Added

- Add `compare_semver()`
  - Improves handling `std_amboso_version` checks properly

### Changed

- Use `compare_semver()` for getting `has_makefile`, `can_automake`
- Fix bad call to `custom_build_step()`
- Fix: use `.` as default for `stego_dir` when missing `-O`
- Fix: `-P` and `--no-color` immediately set `AMBOSO_COLOR`
- Lower warn output for testfiles not ending in `.k`
- Check if `bc` is installed

## [2.0.9] - 2024-11-26

### Added

- Add -Z to pass custom CFLAGS
  - Avoids reading passed CFLAGS var
- Add 2.1.0 support from stego.lock
- Add rough support for anvilPy kern
- Add rough support for custom kern

### Changed

- Flags expecting an argument refuse args starting with -
  - Pass AMBOSO_ALLOW_FLAGS_HYPHEN_ARG >0 to skip this check
- Try reading AMBOSO_CONFIG_ARG_ISFILE to use -C with flags directly
  - Setting it to 0 enables the new, backwards incompatible behaviour
- Fix echo_active_flags() reporting -C incorrectly
- Try using HEAD when -G receives an invalid tag
- Refactor build, delete step to make init and purge iterative

## [2.0.8] - 2024-10-24

### Changed

- Fix print_amboso_stego_scopes() using the wrong char to detect base tags
- Fix realpath usage problems
- Ensure usage of gawk

## [2.0.7] - 2024-08-29

### Added

- Parse global conf at $HOME/.anvil/anvil.toml
- Handle long options with the "-:" getopt trick

### Changed

- Handle help flag earlier
- Improved help message
- Fix init subcommand bug introduced by 2.0.6
- Fix a shellcheck error in reporting unused arguments
- Compacted getopt code since it's a couple expressions in each case anyway
- Compacted usage of anvil_version and anvil_kern from toml parsing

## [2.0.6] - 2024-04-19

### Changed
- Update `amboso_init_proj()` to use passed dir basename
  - This is a minor breaking change from `2.0.0`
  - At the moment there's no way to pass `-e` with `init` to be backwards-compatible and still generate projects with `hello_world` as target name (old behaviour)

## [2.0.5] - 2024-03-25

### Changed

- Use `/usr/bin/bash` instead of `/bin/bash` in shebangs
  - Should help with #102
- Fix generated `Makefile.am`
  - Should solve the failing build when passing `--enable-debug` to the generated configure script
- Print "unsupported" error message and quit when finding `anvilPy` kern in `stego.lock`

## [2.0.4] - 2024-02-16

### Added

- Add `ANVIL__HEADERGEN_TIME` to generated C header

### Changed

- Fix check for `gawk`
  - Closes #100
- Try to `mkdir` missing directories (`scripts_dir`, `script_path`)
  - Drop `bin` checkout and won't need it anymore
- Drop resorting to `./stego.lock` when `scripts_dir` is not a valid directory
- Drop `app()` and `-c` flag
- Bump embedded `najlo` to `0.0.4`
- Update `backtrace()`, `at()`
- Move `try-anvil/` under `utils/`

## [2.0.3] - 2024-02-05

### Added

- Add `min_amboso_v_` consts to better wrap extensions to `2.0`
- Add interpreter branch for when the queried tag ends with `stego.lock`
  - ATM the interpretation ends up going to `try_make()`
- Add `stego_dir` logic to set a different location for `stego.lock` than `scripts_dir`
  - The new default is `../.`, but a fallback to `scripts_dir` should ensure backwards compatibility
- Add legacy lex for `1.x` `stego.lock` files, available by using `-a <VERSIONlessThan2.0>` when calling the script
- Add forced global source
  - When passing `-a` as first argument, the sourcing will be forced from global `amboso_fn.sh` instead of local.
  - Could be useful for breaking changes that may need a newer API than the repo one.
- Add `-Xx` option to run as `najlo`, to parse Makefiles
  - Uses a copypaste of [najlo.sh](https://github.com/jgabaut/najlo)
  - Experimental

### Changed

- Read `amboso_kern` from `stego.lock`, backwards compatible
  - Should need `2.0.3` min to be used
- Fix: try using `gawk` when `awk` seems to be `mawk`
- Avoid passing extended flags to patches below their introduction

### Known issues

- Since this version was naively testing for local `awk` version with -W version, it hangs early as `nawk` ignores the option.
- This makes the script not work on `macOS`.

## [2.0.2] - 2024-01-09

### Added

- Add -a to set `std_amboso_version`
  - Closes #96
- Add -k to set `std_amboso_kern`
- Add `min_amboso_v_kern` to ignore valid `-k` arg when running as below `2.0.2`
- Use globs for generated `configure.ac`
  - Closes #95

### Changed

- Improved git info for `gen_C_header()`

## [2.0.1] - 2024-01-04

### Added

- Add `-e` to turn off extensions to `2.0`

### Changed

- Try `.` if `$scripts_dir` is not a directory (just after it's reset to `./bin`)
- `git_mode_check()` returns success when no repo is found

## [2.0.0] - 2023-12-26

### Added
- Add `-P` flag to turn off colored output
- Add `-J` to log output to `anvil.log`
- Add `-R` to turn off `make rebuild` and run `make`
- Add `-F` to force-build a tag
- Run `make` when no arguments are provided
  - Closes #87
- Warn on empty version map
- Warn for detected `mawk`
  - Closes #58
- Warn for `bash 4.x`
  - Closes #21

### Changed
- Deprecate using `-ti` to record tests
  - Closes #91
- Force `stego.lock` version tags to be strict semver
  - Closes #85
- Run `make rebuild` by default
- Change base mode tags name prefix from `-` to `B`
- Pass `CC` and `CFLAGS` to base mode build
  - Closes #5
- Ignore tests with no `.k` extension
  - Closes #84
- Unify output format to `log_cl`
  - Closes #92
- Colorless amboso sourcing
- Return earlier for `-v`
- Drop `$milestones_dir`
- Drop some comment legacy code
- Generated `.gitignore` for `init` subcommand includes `invil.log`, `anvil.log`
- `verbose_flag` defaults to `3` and allows `[0-5]`
  - Closes #90
- Better error messages when sourcing a deprecated `amboso_fn`
  - Closes #82
  - Closes #80
  - Closes #81
  - Closes #83
  - Improved help message

### Fixed

- Pass `-C` arguments when doing init
  - Closes #89
- Proper pass of `-V <LVL>` to subcalls
