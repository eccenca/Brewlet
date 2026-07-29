# Changelog

All notable changes to Brewlet are documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](https://semver.org/).

Releases up to and including 1.7.4 were made in the upstream project,
[zkokaja/Brewlet](https://github.com/zkokaja/Brewlet), and are reconstructed
here from its tags and commit history.

## [1.8.3] 2026-07-29

### Changed

- Releases are built by the same `task package` command used locally and
  published with the GitHub CLI, taking their notes from this file. They are no
  longer marked as drafts or prereleases, and the runner image is pinned so a
  release cannot silently change Xcode versions.
- The README points at this fork's releases rather than upstream's, and
  describes the count badge that replaced the colored icon.

### Fixed

- The version stamp looked for `.git/shallow` relative to the build's working
  directory rather than the project, so a shallow clone could pass for a full
  one and stamp a build number lower than the previous release's. It now asks
  git directly.

## [1.8.1] 2026-07-29

### Fixed

- The menu bar icon tooltip reported the marketing version from `Info.plist`,
  which lags behind the released version. It now shows the same build version
  as the Preferences window.

### Changed

- Versions are displayed without the `v` prefix that this project's git tags
  carry, since the prefix is a tag-naming convention rather than part of the
  version.
- The shipped version now derives from git at build time: the nearest tag
  becomes `CFBundleShortVersionString` and the commit count becomes
  `CFBundleVersion`. Tags are the single source of truth, so `MARKETING_VERSION`
  no longer needs bumping by hand — it only serves as the fallback for builds
  made outside a git checkout.

## [1.8.0] 2026-07-29

### Added

- "Update" menu action that runs `brew update` on its own, refreshing
  Homebrew's catalog without upgrading anything. It appears only next to
  "Upgrade", since the combined item already reads "Update" when everything is
  up to date.
- Section headers for "Formulae" and "Casks" in the Packages sub-menu, shown
  only for groups that actually have outdated packages.
- The number of outdated packages as a badge composited onto the menu bar icon.
- "Launch Brewlet at login" preference, backed by `SMAppService`. Hidden on
  macOS versions below 13, where the API is unavailable.
- The build's `git describe` output (e.g. `v1.7.4-8-g0dd2bdc-dirty`) stamped
  into `Info.plist` at build time and shown as the subtitle of the Preferences
  window, so a running app can be traced back to an exact commit.
- A [Taskfile](Taskfile.yml) wrapping the Xcode build lifecycle: `task build`,
  `task run`, `task release`.

### Fixed

- Crash when `brew` command handlers updated the UI off the main thread.

## [1.7.4] - 2023-04-01

### Fixed

- Restored the `DispatchQueue` calls that 1.7.2 removed while diagnosing a
  crash.

### Changed

- Updated the project to Xcode's recommended settings.

## [1.7.3] - 2023-03-12

### Added

- Version number in the menu bar icon tooltip.

## [1.7.2] - 2023-03-11

### Changed

- Removed `DispatchQueue` calls in an attempt to diagnose a crash; reverted in
  1.7.4.

## [1.7.1] - 2023-03-04

### Added

- "Don't upgrade casks" preference, for casks that need manual intervention.
- More detailed error messages.

### Fixed

- Wrong flag passed to the `upgrade` command.

### Changed

- The GitHub Action now builds a draft release.

## [1.7] - 2022-04-27

### Changed

- Maintenance release: marketing version bumped to 1.7, copyright year updated.

## [1.6] - 2022-03-13

### Added

- Cask support, via the `brew info --json=v2` API.
- "Open log" menu item.
- More descriptive notifications.

### Changed

- Logs are written to a single file under `~/Library/Logs/Brewlet`.

## [1.5-universal] - 2020-12-18

### Changed

- Built with GitHub's default Xcode version, producing a universal binary that
  runs natively on Apple Silicon and Intel.

## [1.5] - 2020-12-07

### Added

- Services menu, to start, stop, and restart Homebrew services.
- Preference for the Homebrew installation location, defaulting to the path for
  the current architecture.
- Installation via `brew tap`.

### Fixed

- Crash when no services are installed.
- Upgrade button not working in some cases ([#11]).
- Missing revision number in reported versions.
- Installed and stable versions shown the wrong way round for outdated
  packages.

## [1.4] - 2020-06-15

### Added

- "Auto upgrade packages when updates are available" preference ([#4]).
- Help tooltips in the preferences window.
- Documentation and docstrings throughout the source.

### Changed

- The update button is disabled while an upgrade is running, both for bulk and
  single-package upgrades ([#5]).

## [1.3] - 2020-03-01

### Added

- Preferences window, which the analytics setting moved into.
- "Last updated" timestamp.
- Package descriptions as menu item tooltips.
- Dark mode support.

### Changed

- Refactored the code into classes and added package filter criteria.
- Notifications are only sent when the outdated package count changes, instead
  of repeating on every check.

### Fixed

- Available-packages icon in dark mode.

## [1.2] - 2020-02-13

### Added

- Upgrade individual packages from the menu.
- Hourly update checks, plus a manual update action.

## [1.1] - 2020-02-12

### Added

- Notifications when updates are available and when errors occur.
- Icon animation while packages are upgrading.
- Keyboard shortcut for Quit.
- Upgrade output logged to a temporary file.

### Changed

- Reorganized the menu layout.
- The update item is hidden when everything is up to date.

## [1.0] - 2020-02-09

### Added

- Initial release: a macOS menu bar app that watches Homebrew for outdated
  packages and can upgrade them, clean up, and export the installed package
  list.

[1.8.3]: https://github.com/eccenca/Brewlet/compare/v1.8.1...v1.8.3
[1.8.1]: https://github.com/eccenca/Brewlet/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/eccenca/Brewlet/compare/v1.7.4...v1.8.0
[1.7.4]: https://github.com/eccenca/Brewlet/compare/v1.7.3...v1.7.4
[1.7.3]: https://github.com/eccenca/Brewlet/compare/v1.7.2...v1.7.3
[1.7.2]: https://github.com/eccenca/Brewlet/compare/v1.7.1...v1.7.2
[1.7.1]: https://github.com/eccenca/Brewlet/compare/v1.7...v1.7.1
[1.7]: https://github.com/eccenca/Brewlet/compare/v1.6...v1.7
[1.6]: https://github.com/eccenca/Brewlet/compare/v1.5-universal...v1.6
[1.5-universal]: https://github.com/eccenca/Brewlet/compare/v1.5...v1.5-universal
[1.5]: https://github.com/eccenca/Brewlet/compare/v1.4...v1.5
[1.4]: https://github.com/eccenca/Brewlet/compare/v1.3...v1.4
[1.3]: https://github.com/eccenca/Brewlet/compare/v1.2...v1.3
[1.2]: https://github.com/eccenca/Brewlet/compare/v1.1...v1.2
[1.1]: https://github.com/eccenca/Brewlet/compare/v1.0...v1.1
[1.0]: https://github.com/eccenca/Brewlet/releases/tag/v1.0
[#4]: https://github.com/zkokaja/Brewlet/issues/4
[#5]: https://github.com/zkokaja/Brewlet/issues/5
[#11]: https://github.com/zkokaja/Brewlet/issues/11
