//
//  NSWorkspace+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/7.
//

import AppKit

public extension NSWorkspace {
  @discardableResult
  func safelyOpenURL(string: String) -> Bool {
    guard let url = URL(string: string) else {
      assertionFailure("Failed to create the URL: \(string)")
      return false
    }

    return open(url)
  }
}
