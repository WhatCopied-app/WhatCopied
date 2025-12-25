//
//  AppDelegate.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var lineWrappingItem: NSMenuItem?
  @IBOutlet weak var mainUpdateItem: NSMenuItem?
  @IBOutlet weak var presentUpdateItem: NSMenuItem?
  @IBOutlet weak var postponeUpdateItem: NSMenuItem?
  @IBOutlet weak var ignoreUpdateItem: NSMenuItem?
  private var changeObserver: Task<Void, Never>?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // "Populating a menu window that is already visible"
    NSMenu.swizzleIsUpdatedExcludingContentTypesOnce

    let silentlyCheckUpdates: @Sendable () -> Void = {
      Task {
        await AppUpdater.checkForUpdates(explicitly: false)
      }
    }

    // Check for updates on launch with a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.presentUpdateItem?.title = Localized.Updater.viewReleasePage
      self.postponeUpdateItem?.title = Localized.Updater.remindMeLater
      self.ignoreUpdateItem?.title = Localized.Updater.skipThisVersion
      silentlyCheckUpdates()
    }

    // Check for updates on a weekly basis, for users who never quit apps
    Timer.scheduledTimer(withTimeInterval: 7 * 24 * 60 * 60, repeats: true) { _ in
      silentlyCheckUpdates()
    }
  }

  func applicationWillBecomeActive(_ notification: Notification) {
    let notifyChanges = {
      NotificationCenter.default.post(name: .pasteboardChanged, object: nil)
    }

    changeObserver?.cancel()
    notifyChanges()

    changeObserver = Task { @MainActor in
      for await _ in PasteObserver.default.changes() {
        notifyChanges()
      }
    }
  }

  func applicationDidResignActive(_ notification: Notification) {
    changeObserver?.cancel()
  }

  func applicationWillTerminate(_ notification: Notification) {
    try? FileManager.default.removeItem(at: .previewingDirectory)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
  func menuNeedsUpdate(_ menu: NSMenu) {
    guard let displayMode = (NSApp.keyWindow?.contentViewController as? MainVC)?.displayMode else {
      return Logger.log(.error, "Unexpected nil for displayMode")
    }

    if displayMode.usesTextView {
      // Always on and cannot change
      lineWrappingItem?.state = .on
    } else if displayMode != .sourceCode {
      // Always off and cannot change
      lineWrappingItem?.state = .off
    } else {
      // Depends on the user setting
      lineWrappingItem?.state = AppPreferences.Viewer.lineWrapping ? .on : .off
    }
  }
}

// MARK: - Action Handlers

extension AppDelegate {
  // Workaround: customized to ensure the icon renders correctly
  @IBAction func hideWhatCopied(_ sender: Any?) {
    NSApp.hide(sender)
  }

  // Workaround: customized to ensure the icon renders correctly
  @IBAction func hideOthers(_ sender: Any?) {
    NSApp.hideOtherApplications(sender)
  }

  // Workaround: customized to ensure the icon renders correctly
  @IBAction func quitWhatCopied(_ sender: Any?) {
    NSApp.terminate(sender)
  }

  @IBAction func checkForUpdates(_ sender: Any?) {
    Task {
      await AppUpdater.checkForUpdates(explicitly: true)
    }
  }

  @IBAction func showHelp(_ sender: Any?) {
    NSWorkspace.shared.safelyOpenURL(string: "https://github.com/WhatCopied-app/WhatCopied/wiki")
  }

  @IBAction func openVersionHistory(_ sender: Any?) {
    NSWorkspace.shared.safelyOpenURL(string: "https://github.com/WhatCopied-app/WhatCopied/releases")
  }
}
