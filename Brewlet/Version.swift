//
//  Version.swift
//  Brewlet
//
//  Exposes the build's git provenance to the UI.
//

import Foundation

extension Bundle {

    /// The `git describe --always --dirty --tags` output captured when the app
    /// was built, e.g. `v1.7.4-8-g0dd2bdc-dirty`.
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

    /// Human-readable version for display, preferring the exact build
    /// (`v1.7.4-8-g0dd2bdc-dirty`) and falling back to the released marketing
    /// version (`v1.7.4`) when no git description was stamped in.
    var displayVersion: String {
        if let gitVersion = gitVersion {
            return gitVersion
        }
        let marketingVersion = infoDictionary?["CFBundleShortVersionString"] as? String
        return "v\(marketingVersion ?? "?")"
    }
}
