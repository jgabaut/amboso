# Changelog

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
