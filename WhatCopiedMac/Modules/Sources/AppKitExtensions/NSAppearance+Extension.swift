//
//  NSAppearance+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/7.
//

import AppKit

public extension NSAppearance {
  var isDarkMode: Bool {
    switch name {
    case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
      return true
    default:
      return false
    }
  }
}
