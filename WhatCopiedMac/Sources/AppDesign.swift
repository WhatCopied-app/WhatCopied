//
//  AppDesign.swift
//  WhatCopied
//
//  Created by cyan on 2025/6/26.
//

import AppKit

@MainActor
enum AppDesign {
  /**
    Returns `true` to adopt the new design language in macOS Tahoe.
   */
  static var modernStyle: Bool {
    isMacOSTahoe
  }

  static var modernEffectView: NSView.Type {
    guard #available(macOS 26.0, *), modernStyle else {
      return NSVisualEffectView.self
    }

    return NSGlassEffectView.self
  }

  static var contentMargin: Double {
    modernStyle ? 15 : 10
  }
}

// MARK: - Private

private extension AppDesign {
  static var isMacOSTahoe: Bool {
    guard #available(macOS 26.0, *) else {
      return false
    }

    return true
  }
}
