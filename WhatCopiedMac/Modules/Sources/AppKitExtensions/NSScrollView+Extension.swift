//
//  NSScrollView+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

public extension NSScrollView {
  var monospacedText: String {
    get {
      attributedText.string
    }
    set {
      attributedText = NSAttributedString(string: newValue, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
        .foregroundColor: NSColor.labelColor,
      ])
    }
  }

  var attributedText: NSAttributedString {
    get {
      textView?.attributedString() ?? NSAttributedString()
    }
    set {
      textView?.textStorage?.setAttributedString(newValue)
      contentView.scroll(to: .zero)
      magnification = 1.0
    }
  }
}

// MARK: - Private

private extension NSScrollView {
  var textView: NSTextView? {
    documentView as? NSTextView
  }
}
