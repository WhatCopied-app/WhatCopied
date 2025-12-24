//
//  AppDelegate.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var modernCheckForUpdatesItem: NSMenuItem?
  @IBOutlet weak var modernQuickLookItem: NSMenuItem?
  @IBOutlet weak var modernSaveToDiskItem: NSMenuItem?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // "Populating a menu window that is already visible"
    NSMenu.swizzleIsUpdatedExcludingContentTypesOnce

    if AppDesign.menuIconEvolution {
      normalizeMainMenuIcons()
    }

    let silentlyCheckUpdates: @Sendable () -> Void = {
      Task {
        await AppUpdater.checkForUpdates(explicitly: false)
      }
    }

    // Check for updates on launch with a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: silentlyCheckUpdates)

    // Check for updates on a weekly basis, for users who never quit apps
    Timer.scheduledTimer(withTimeInterval: 7 * 24 * 60 * 60, repeats: true) { _ in
      silentlyCheckUpdates()
    }

    // Run a observer to refresh the pasteboard repeatedly
    PasteObserver.default.startObserving()
  }

  func applicationWillTerminate(_ notification: Notification) {
    try? FileManager.default.removeItem(at: .previewingDirectory)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

// MARK: - Action Handlers

extension AppDelegate {
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

// MARK: - Private

private extension AppDelegate {
  func normalizeMainMenuIcons() {
    let icon: (String) -> NSImage? = {
      NSImage(systemSymbolName: $0, accessibilityDescription: nil)
    }

    modernCheckForUpdatesItem?.image = icon("arrow.trianglehead.2.clockwise.rotate.90.circle")
    modernQuickLookItem?.image = icon("eye")
    modernSaveToDiskItem?.image = icon("square.and.arrow.down")
  }
}
