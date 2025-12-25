//
//  PasteObserver.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

/**
 Pasteboard observer that fires whenever built-in pasteboards are updated.
 */
@MainActor
final class PasteObserver {
  static let `default` = PasteObserver()

  private init() {}
  func changes(pasteboard: NSPasteboard = .general, interval: Duration = .seconds(0.5)) -> AsyncStream<Void> {
    AsyncStream { continuation in
      var lastCount = pasteboard.changeCount
      let mainTask = Task { @MainActor in
        while !Task.isCancelled {
          try await Task.sleep(for: interval)
          let newCount = pasteboard.changeCount
          if newCount != lastCount {
            lastCount = newCount
            continuation.yield()
          }
        }
      }

      continuation.onTermination = { _ in
        mainTask.cancel()
      }
    }
  }
}
