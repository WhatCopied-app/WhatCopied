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
  #if BUILD_WITH_SDK_26_OR_LATER
    guard #available(macOS 26.0, *) else {
      return false
    }

    return true
  #else
    // macOS Tahoe version number is 16.0 if the SDK is old
    guard #available(macOS 16.0, *) else {
      return false
    }

    // defaults write app.cyan.whatcopied com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck -bool true
    return UserDefaults.standard.bool(forKey: "com.apple.SwiftUI.IgnoreSolariumLinkedOnCheck")
  #endif
  }

  static var modernEffectView: NSView.Type {
    // [macOS 26] Change this to 26.0
    guard #available(macOS 16.0, *), modernStyle else {
      return NSVisualEffectView.self
    }

  #if BUILD_WITH_SDK_26_OR_LATER
    return NSGlassEffectView.self
  #else
    // Reflect a glass effect view when it's available
    return (NSClassFromString("NSGlassEffectView") as? NSView.Type) ?? NSVisualEffectView.self
  #endif
  }

  static var contentMargin: Double {
    modernStyle ? 15 : 10
  }

  /**
   Returns `true` to gradually add icons to the menu bar.

   It will be enabled as long as macOS Tahoe runs.
   */
  static var menuIconEvolution: Bool {
    isMacOSTahoe
  }
}

// MARK: - Private

private extension AppDesign {
  static var isMacOSTahoe: Bool {
    // [macOS 26] Change this to 26.0
    guard #available(macOS 16.0, *) else {
      return false
    }

    return true
  }
}
