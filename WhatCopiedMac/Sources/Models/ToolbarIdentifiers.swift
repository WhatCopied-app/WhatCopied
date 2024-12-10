//
//  ToolbarIdentifiers.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

extension NSToolbarItem.Identifier {
  static let displayModeItem: Self = .withIdentifier("displayModeItem")
  static let quickLookItem: Self = .withIdentifier("quickLookItem")
  static let operationsItem: Self = .withIdentifier("operationsItem")
  static let saveToDiskItem: Self = .withIdentifier("saveToDiskItem")
}

// MARK: - Private

private extension NSToolbarItem.Identifier {
  static func withIdentifier(_ identifier: String) -> Self {
    Self("app.whatcopied.\(identifier)")
  }
}
