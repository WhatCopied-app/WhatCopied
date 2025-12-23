//
//  PasteObserver.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

extension Notification.Name {
  static let pasteboardChanged = Self("pasteboardChanged")
}

/**
 Pasteboard observer that posts notifications whenever built-in pasteboards are updated.
 */
@MainActor
final class PasteObserver {
  static let `default` = PasteObserver()

  func startObserving() {
    let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let self else {
        return
      }

      Task { @MainActor in
        guard NSApp.keyWindow != nil else {
          return
        }

        self.checkChangeToken()
      }
    }

    self.timer = timer
    self.checkChangeToken()
    RunLoop.current.add(timer, forMode: .common)
  }

  // MARK: - Private

  private var timer: Timer?
  private var changeToken = NSPasteboard.changeToken

  private init() {
    // no-op
  }

  private func checkChangeToken() {
    Task.detached(priority: .background) {
      let newToken = NSPasteboard.changeToken
      guard await self.changeToken != newToken else {
        return
      }

      await MainActor.run {
        self.changeToken = newToken
        NotificationCenter.default.post(name: .pasteboardChanged, object: nil)
      }
    }
  }
}
