//
//  PreferencesController.swift
//  Brewlet
//
//  Created by zzada on 2/23/20.
//  Copyright © 2020 zzada. All rights reserved.
//

import OSLog
import Cocoa
import ServiceManagement

protocol PreferencesDelegate {
    func updateIntervalChanged(newInterval: TimeInterval?) // if nil, then don't update
    func includeDependenciesChanged(newState: NSControl.StateValue)
    func shareAnalyticsChanged(newState: NSControl.StateValue)
    func brewPathChanged(newPath: String)
}

class PreferencesController: NSWindowController {

    @IBOutlet weak var includeDependencies: NSButton!
    @IBOutlet weak var updateInterval: NSSlider!
    @IBOutlet weak var shareAnalytics: NSButton!
    @IBOutlet weak var autoUpgrade: NSButton!
    @IBOutlet weak var dontNotifyAvailable: NSButton!
    @IBOutlet weak var dontUpgradeCasks: NSButton!
    @IBOutlet weak var brewPath: NSTextField!
    @IBOutlet weak var intel: NSButton!
    @IBOutlet weak var appleSilicon: NSButton!
    @IBOutlet weak var custom: NSButton!
    @IBOutlet weak var launchAtLogin: NSButton!

    var delegate: PreferencesDelegate?
    
    enum HomebrewPath: String {
        case appleSilicon = "/opt/homebrew/bin/brew"
        case intel = "/usr/local/bin/brew"
        case custom = ""
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.level = .popUpMenu
        NSApp.activate(ignoringOtherApps: true)

        // Identify the exact build under the window title, e.g.
        // "Version 1.8.0-2-g49b7c16" — useful when reporting issues.
        self.window?.subtitle = "Version \(Bundle.main.displayVersion)"
        
        // Update view with current preferences
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "includeDependencies") {
            includeDependencies.state = .on
        } else {
            includeDependencies.state = .off
        }
        
        let currentInterval = defaults.double(forKey: "updateInterval")
        if currentInterval == -1 {
            updateInterval.doubleValue = updateInterval.maxValue
        } else {
            let intervalIndex = (currentInterval / 3600) * 2
            updateInterval.doubleValue = intervalIndex
        }
        
        if defaults.bool(forKey: "shareAnalytics") {
            shareAnalytics.state = .on
        } else {
            shareAnalytics.state = .off
        }        
        
        autoUpgrade.state = defaults.bool(forKey: "autoUpgrade") ? .on : .off
        dontNotifyAvailable.state = defaults.bool(forKey: "dontNotify") ? .on : .off
        dontUpgradeCasks.state = defaults.bool(forKey: "dontUpgradeCasks") ? .on : .off

        // Reflect the real login-item state. SMAppService is the source of
        // truth, so there is no UserDefaults mirror to read. macOS 13+ only;
        // on older systems the option is hidden (see launchAtLoginChanged).
        if #available(macOS 13.0, *) {
            launchAtLogin.state = SMAppService.mainApp.status == .enabled ? .on : .off
        } else {
            launchAtLogin.isHidden = true
        }
        
        #if arch(arm64)
        let currentBrewPath = defaults.string(forKey: "brewPath") ?? HomebrewPath.appleSilicon.rawValue
        #elseif arch(x86_64)
        let currentBrewPath = defaults.string(forKey: "brewPath") ?? HomebrewPath.intel.rawValue
        #endif
        switch currentBrewPath {
        case HomebrewPath.intel.rawValue:
            intelSelected(nil)
        case HomebrewPath.appleSilicon.rawValue:
            appleSiliconSelected(nil)
        default:
            custom.state = .on
            brewPath.stringValue = currentBrewPath
        }
    }
    
    @IBAction func includeDependenciesPressed(_ sender: NSButton) {
        delegate?.includeDependenciesChanged(newState: sender.state)
    }
    
    @IBAction func shareAnalyticsPressed(_ sender: NSButton) {
        delegate?.shareAnalyticsChanged(newState: sender.state)
    }
    
    @IBAction func autoUpgradeChanged(_ sender: NSButton) {
        os_log("Update auto upgrade: %s", type: .info, sender.state == .on ? "on" : "off")
        UserDefaults.standard.set(sender.state == .on, forKey: "autoUpgrade")
    }
    
    @IBAction func notifyChanged(_ sender: NSButton) {
        os_log("Update don't notify: %s", type: .info, sender.state == .on ? "on" : "off")
        UserDefaults.standard.set(sender.state == .on, forKey: "dontNotify")
    }
    
    @IBAction func dontUpgradeCasksChanged(_ sender: NSButton) {
        os_log("Update don't upgrade casks: %s", type: .info, sender.state == .on ? "on" : "off")
        UserDefaults.standard.set(sender.state == .on, forKey: "dontUpgradeCasks")
    }

    @IBAction func launchAtLoginChanged(_ sender: NSButton) {
        // SMAppService requires macOS 13+; the control is hidden below that.
        guard #available(macOS 13.0, *) else { return }
        do {
            if sender.state == .on {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            os_log("Set launch at login: %s", type: .info, sender.state == .on ? "on" : "off")
        } catch {
            os_log("Failed to set launch at login: %s", type: .error, "\(error)")
            // Registration failed (e.g. the user must approve it in System
            // Settings › Login Items) — snap the checkbox back to reality.
            sender.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        }
    }

    @IBAction func updateIntervalChanged(_ sender: NSSlider) {
        
        var seconds: TimeInterval? = nil
        if sender.intValue == 10 {
            sender.toolTip = "Never"
        } else {
            let hours = sender.doubleValue * 0.5
            seconds = hours * 3600
            sender.toolTip = "\(hours) Hours"
        }
        
        delegate?.updateIntervalChanged(newInterval: seconds)
    }
    
    @IBAction func appleSiliconSelected(_ sender: Any?) {
        appleSilicon.state = .on
        intel.state = .off
        custom.state = .off
        brewPath.isEnabled = false
        let path = HomebrewPath.appleSilicon.rawValue
        brewPath.stringValue = path
        delegate?.brewPathChanged(newPath: path)
    }
    
    @IBAction func intelSelected(_ sender: Any?) {
        intel.state = .on
        appleSilicon.state = .off
        custom.state = .off
        brewPath.isEnabled = false
        let path = HomebrewPath.intel.rawValue
        brewPath.stringValue = path
        delegate?.brewPathChanged(newPath: path)
    }
    
    @IBAction func customSelected(_ sender: Any) {
        custom.state = .on
        appleSilicon.state = .off
        intel.state = .off
        brewPath.isEnabled = true
        delegate?.brewPathChanged(newPath: brewPath.stringValue)
    }
    
    @IBAction func brewPathChanged(_ sender: NSTextField) {
        // TODO: Validate that the path is valid
        delegate?.brewPathChanged(newPath: sender.stringValue)
    }
    
    override var windowNibName : String! {
        return "PreferencesController"
    }
    
}
