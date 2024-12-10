//
//  CodeView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/6.
//

import AppKit
import WebKit
import os.log

/**
 Code view with syntax highlighting based on https://highlightjs.org/.
 */
public final class CodeView: NSView {
  private let htmlView = HtmlView()

  public init() {
    super.init(frame: .zero)

    htmlView.loadHtml(indexHtml ?? "")
    htmlView.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func loadCode(_ code: String) {
    guard let data = try? JSONSerialization.data(withJSONObject: ["code": code]) else {
      return os.Logger().log(level: .error, "Invalid JSON object for: \(code)")
    }

    guard let payload = String(data: data, encoding: .utf8) else {
      return os.Logger().log(level: .error, "Invalid JSON string for: \(data)")
    }

    htmlView.evaluateJavaScript("loadCode(\(payload))")
  }

  override public func layout() {
    super.layout()
    wantsLayer = true

    // GitHub color schemes
    layer?.backgroundColor = NSColor.theme(light: .white, dark: NSColor(hexCode: 0x0d1117)).cgColor
  }
}

// MARK: - Private

private extension CodeView {
  var indexHtml: String? {
    guard let path = Bundle.module.url(forResource: "index", withExtension: "html") else {
      assertionFailure("Missing index.html to continue")
      return nil
    }

    guard let data = try? Data(contentsOf: path) else {
      assertionFailure("Invalid file data was found at \(path)")
      return nil
    }

    guard let html = String(data: data, encoding: .utf8) else {
      assertionFailure("Invalid data encoding was found at \(path)")
      return nil
    }

    return html
  }
}
