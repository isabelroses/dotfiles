# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.4.0] - 2018-10-22

### Fixed

- Issues with Lua's `io.popen` on some systems by using Micro's built-in `RunShellCommand` instead, [thanks to @scottbilas](https://github.com/NicolaiSoeborg/filemanager-plugin/pull/38)

### Added

- Adds the option `filemanager-openonstart` to allow auto-opening the file tree when Micro is started (default OFF)

### Changed

- Update README's option's documentation

## [3.3.1] - 2018-10-03

### Changed

- Performance improvement by removing unnecessary refresh of the opened file, [thanks to @jackwilsdon](https://github.com/NicolaiSoeborg/filemanager-plugin/pull/37)

## [3.3.0] - 2018-09-13

### Added

- The ability to sort folders above files, [thanks to @cbrown1](https://github.com/NicolaiSoeborg/filemanager-plugin/pull/33)

### Fixed

- The displayed filenames are now correctly only showing their "basename" on Windows

## [3.2.0] - 2018-02-15

### Added

- The ability to go to parent directory with left arrow (when not minimizing). Thanks @avently
- The ability to jump to the `..` as a "parent directory". Thanks @avently

## [3.1.2] - 2018-02-07

### Fixed

- The minimum Micro version, which was incorrectly set to v1.4.0. Ref [issue #28](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/28)

## [3.1.1] - 2018-02-04

### Fixed

Ref https://github.com/zyedidia/micro/issues/992 for both of these fixes.

- The syntax parser not loading correctly (mostly block comments) on opened files. **Requires Micro >= v1.4.0**
- An errant tab being inserted into the newly opened file.

## [3.1.0] - 2018-01-30

### Added

- The ability to hide dotfiles using the `filemanager-showdotfiles` option.
- The ability to hide files ignored in your VCS (aka `.gitignore`'d) using the `filemanager-showignored` option. Only works with Git at the moment.
- This `CHANGELOG.md`

### Fixed

- A bug with the `rm` command that caused weird, undefined behaviour to contents within the same dir as the file/dir deleted.
- Issue [#24](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/24)

## [3.0.0] - 2018-01-10

### Fixed

- Issues [#13](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/13), [#14](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/14), [#15](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/15), [#19](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/19), [#20](https://github.com/NicolaiSoeborg/filemanager-plugin/issues/20)
- The broken syntax highlighting

### Added

- Directory expansion/compression below itself for viewing more akin to a file tree.
- The `rm` command, which deletes the file/directory under the cursor.
- The `touch` command, which creates a file with the passed filename.
- The `mkdir` command, which creates a directory with the passed filename.
- An API, of sorts, for the user to rebind their keys to if they dislike the defaults.
- An [editorconfig](http://editorconfig.org/) file.

### Changed

- The view that it spawns in to read-only, which requires Micro version >= 1.3.5
- The functionality of some keybindings (when in the view) so they work safetly, or at all, with the plugin.
- From the `enter` key to `tab` for opening/going into files/dirs (a side-effect of using the read-only setting)

### Removed

- The ability to use a lot of keybindings that would otherwise mess with the view, and have no benifit.
- The pointless `.gitignore` file.

[unreleased]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.4.0...HEAD
[3.4.0]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.3.1...v3.4.0
[3.3.1]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.3.0...v3.3.1
[3.3.0]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.1.2...v3.2.0
[3.1.2]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.1.1...v3.1.2
[3.1.1]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/NicolaiSoeborg/filemanager-plugin/compare/v2.1.1...v3.0.0
