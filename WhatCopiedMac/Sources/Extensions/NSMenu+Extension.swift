//
//  NSMenu+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2025/9/5.
//

import AppKit

extension NSMenu {
  /**
   Hook this method to work around the **Populating a menu window that is already visible** crash.
   */
  static let swizzleIsUpdatedExcludingContentTypesOnce: () = {
    NSMenu.exchangeInstanceMethods(
      originalSelector: sel_getUid("_isUpdatedExcludingContentTypes:"),
      swizzledSelector: #selector(swizzled_isUpdatedExcludingContentTypes(_:))
    )
  }()
}

// MARK: - Private

private extension NSMenu {
  @objc func swizzled_isUpdatedExcludingContentTypes(_ contentTypes: Int) -> Bool {
    // The original implementation contains an invalid assertion that causes a crash.
    // Based on testing, it would return false anyway, so we simply return false to bypass the assertion.
    false
  }
}
