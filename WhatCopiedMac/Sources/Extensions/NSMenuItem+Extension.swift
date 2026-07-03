//
//  NSMenuItem+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2026/7/3.
//

import AppKit

extension NSMenuItem {
  @available(macOS 27.0, *)
  static let swizzlePreferredImageVisibilityOnce: () = {
    NSMenuItem.exchangeInstanceMethods(
      originalSelector: {
      #if canImport(FoundationModels, _version: 2)
        #selector(getter: preferredImageVisibility)
      #else
        sel_getUid("preferredImageVisibility")
      #endif
      }(),
      swizzledSelector: #selector(getter: swizzled_preferredImageVisibility)
    )
  }()
}

// MARK: - Private

private extension NSMenuItem {
  @available(macOS 27.0, *)
  @objc var swizzled_preferredImageVisibility: Int {
    // [macOS 27] Apple bug: they incorrectly removed images from SwiftUI.Picker
    guard (menu?.items.allSatisfy { $0.className.hasSuffix("SwiftUIMenuItem") }) ?? false else {
      return self.swizzled_preferredImageVisibility
    }

  #if canImport(FoundationModels, _version: 2)
    return Self.ImageVisibility.visible.rawValue
  #else
    return 1 // .visible
  #endif
  }
}
