//
//  NSColor+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/7.
//

import AppKit

public extension NSColor {
  convenience init(hexCode: UInt32, alpha: Double = 1.0) {
    let red = Double((hexCode & 0xFF0000) >> 16) / 255.0
    let green = Double((hexCode & 0x00FF00) >> 8) / 255.0
    let blue = Double(hexCode & 0x0000FF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  static func theme(light: NSColor, dark: NSColor) -> NSColor {
    NSColor(name: nil) { $0.isDarkMode ? dark : light }
  }
}
