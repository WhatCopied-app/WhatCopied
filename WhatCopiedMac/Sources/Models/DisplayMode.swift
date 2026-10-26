//
//  DisplayMode.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/6.
//

import Foundation

enum DisplayMode: CaseIterable, CustomStringConvertible {
  case text
  case html
  case rtf
  case sourceCode
  case image
  case hex

  var iconName: String {
    switch self {
    case .text: return "doc.plaintext"
    case .html: return "safari"
    case .rtf: return "doc.richtext"
    case .sourceCode: return "curlybraces"
    case .image: return "photo"
    case .hex: return "number"
    }
  }

  /**
   Whether to render with an NSTextView.
   */
  var usesTextView: Bool {
    switch self {
    case .text, .rtf, .hex: return true
    default: return false
    }
  }

  var description: String {
    switch self {
    case .text: return Localized.DisplayMode.text
    case .html: return Localized.DisplayMode.html
    case .rtf: return Localized.DisplayMode.rtf
    case .sourceCode: return Localized.DisplayMode.sourceCode
    case .image: return Localized.DisplayMode.image
    case .hex: return Localized.DisplayMode.hex
    }
  }
}
