//
//  PasteObserver.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

extension NSNotification.Name {
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

      DispatchQueue.main.async {
        let newToken = NSPasteboard.changeToken
        guard self.changeToken != newToken else {
          return
        }

        self.changeToken = newToken
        NotificationCenter.default.post(name: .pasteboardChanged, object: nil)
      }
    }

    self.timer = timer
    RunLoop.current.add(timer, forMode: .common)
    NotificationCenter.default.post(name: .pasteboardChanged, object: nil)
  }

  func stopObserving() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: - Private

  private var timer: Timer?
  private var changeToken = NSPasteboard.changeToken

  private init() {
    // no-op
  }
}
