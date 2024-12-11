//
//  AppDelegate.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidBecomeKey(_:)),
      name: NSWindow.didBecomeKeyNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidResignKey(_:)),
      name: NSWindow.didResignKeyNotification,
      object: nil
    )

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

  @IBAction func openIssueTracker(_ sender: Any?) {
    NSWorkspace.shared.safelyOpenURL(string: "https://github.com/WhatCopied-app/WhatCopied/issues")
  }

  @IBAction func openVersionHistory(_ sender: Any?) {
    NSWorkspace.shared.safelyOpenURL(string: "https://github.com/WhatCopied-app/WhatCopied/releases")
  }
}

// MARK: - Private

@MainActor
private extension AppDelegate {
  @objc func windowDidBecomeKey(_ notification: Notification) {
    if shouldUpdateObserver(for: notification) {
      PasteObserver.default.startObserving()
    }
  }

  @objc func windowDidResignKey(_ notification: Notification) {
    if shouldUpdateObserver(for: notification) {
      PasteObserver.default.stopObserving()
    }
  }

  func shouldUpdateObserver(for notification: Notification) -> Bool {
    (notification.object as? NSWindow)?.contentViewController is MainVC
  }
}
