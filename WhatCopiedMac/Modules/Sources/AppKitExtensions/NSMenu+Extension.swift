//
//  NSMenu+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

public extension NSMenu {
  @discardableResult
  func addItem(withTitle string: String, action selector: Selector? = nil) -> NSMenuItem {
    addItem(withTitle: string, action: selector, keyEquivalent: "")
  }

  @MainActor
  @discardableResult
  func addItem(withTitle string: String, action: @escaping () -> Void) -> NSMenuItem {
    let item = addItem(withTitle: string, action: nil)
    item.addAction(action)
    return item
  }
}
