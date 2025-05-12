//
//  NSPasteboard+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit
import UniformTypeIdentifiers

public extension NSPasteboard {
  var string: String? {
    get {
      string(forType: .string)
    }
    set {
      guard let newValue else {
        return
      }

      declareTypes([.string], owner: nil)
      setString(newValue, forType: .string)
    }
  }

  /**
   Human-friendly names, not necessary to localize since these are technical terms.
   */
  var readableName: String {
    switch name {
    case .general: return "General"
    case .font: return "Font"
    case .ruler: return "Ruler"
    case .find: return "Find"
    case .drag: return "Drag"
    default:
      assertionFailure("Unexpected pasteboard name: \(name)")
      return "Unknown"
    }
  }

  /**
   Types in a human-friendly order, image first, then plain text, then rich text, then others.
   */
  var sortedTypes: [NSPasteboard.PasteboardType] {
    (types ?? []).sorted { lhs, rhs in
      let lhsType = lhs.uttype
      let rhsType = rhs.uttype

      var lhsValue: Int = 0
      var rhsValue: Int = 0

      let addValue: (UTType, Int) -> Void = { type, value in
        lhsValue += lhsType.conforms(to: type) ? value : 0
        rhsValue += rhsType.conforms(to: type) ? value : 0
      }

      addValue(.image, 1 << 3)
      addValue(.plainText, 1 << 2)
      addValue(.text, 1 << 1)
      addValue(.utf16ExternalPlainText, -(1 << 1)) // Deprioritize public.utf16-external-plain-text

      return rhsValue < lhsValue
    }
  }

  var hasLimitedAccess: Bool {
    guard #available(macOS 15.4, *) else {
      return false
    }

    return accessBehavior != .alwaysAllow
  }

  /**
   Default pasteboards we care about.
   */
  static var pasteboards: [NSPasteboard] {
    [
      Self(name: .general),
      Self(name: .font),
      Self(name: .ruler),
      Self(name: .find),
      Self(name: .drag),
    ]
  }

  /**
   Change count of all pasteboards as a stable identifier.
   */
  static var changeToken: String {
    pasteboards.map { "\($0.changeCount)" }.description
  }

  static func clearPasteboards() {
    pasteboards.forEach { $0.clearContents() }
  }

  func clearOtherPasteboards() {
    for pasteboard in NSPasteboard.pasteboards where pasteboard.name != name {
      pasteboard.clearContents()
    }
  }

  func keepDataType(_ type: UTType) {
    let items = getDataItems().filter {
      $0.key.uttype.conforms(to: type) == true
    }

    setDataItems(items)
  }
}

// MARK: - Private

private extension NSPasteboard {
  func getDataItems() -> [NSPasteboard.PasteboardType: Data] {
    (types ?? []).reduce(into: [NSPasteboard.PasteboardType: Data]()) { items, type in
      items[type] = data(forType: type)
    }
  }

  func setDataItems(_ items: [NSPasteboard.PasteboardType: Data]) {
    declareTypes(Array(items.keys), owner: nil)

    for (type, data) in items {
      setData(data, forType: type)
    }
  }
}

private extension NSPasteboard.PasteboardType {
  var uttype: UTType {
    UTType(rawValue) ?? .data
  }
}
