//
//  Version.swift
//  Brewlet
//
//  Exposes the build's git provenance to the UI.
//

import Foundation

extension Bundle {

    /// The `git describe --always --dirty --tags` output captured when the app
    /// was built, e.g. `v1.8.0-2-g49b7c16-dirty`.
    ///
    /// Stamped into the built `Info.plist` by the "Stamp git version" build
    /// phase. Nil when the app was not built from a git checkout (a source
    /// tarball, for instance), since there is nothing to describe.
    var gitVersion: String? {
        guard let version = infoDictionary?["GitVersion"] as? String,
              !version.isEmpty else {
            return nil
        }
        return version
    }

    /// Version for display, preferring the exact build
    /// (`1.8.0-2-g49b7c16-dirty`) and falling back to the released marketing
    /// version (`1.8.0`) when no git description was stamped in.
    ///
    /// The `v` that this project's tags carry is a tag-naming convention, not
    /// part of the version itself, so it is dropped here: the UI shows plain
    /// version numbers everywhere.
    var displayVersion: String {
        guard let gitVersion = gitVersion else {
            return infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        }
        return gitVersion.droppingTagPrefix
    }
}

private extension String {

    /// Drops a leading `v` when it introduces a version number, leaving bare
    /// commit hashes (what `git describe --always` falls back to in a repo
    /// without tags) untouched.
    var droppingTagPrefix: String {
        guard hasPrefix("v"), dropFirst().first?.isNumber == true else {
            return self
        }
        return String(dropFirst())
    }
}
