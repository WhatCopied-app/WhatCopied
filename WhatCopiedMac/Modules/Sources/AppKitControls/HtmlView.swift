//
//  HtmlView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

import WebKit

/**
 Simple WKWebView wrapper to render HTML.
 */
public final class HtmlView: WKWebView {
  public init() {
    class Configuration: WKWebViewConfiguration {
      // Clears the background so it doesn't flash in dark mode
      @objc func _drawsBackground() -> Bool { false }
    }

    let config = Configuration()
    if config.preferences.responds(to: sel_getUid("_developerExtrasEnabled")) {
      config.preferences.setValue(true, forKey: "developerExtrasEnabled")
    } else {
      assertionFailure("Missing developerExtrasEnabled to enable the developer tools")
    }

    super.init(frame: .zero, configuration: config)
    isInspectable = true
    allowsMagnification = true
    navigationDelegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func loadHtml(_ html: String, padding: Double? = nil) {
    let styleSheets = [
      defaultStyles,
      padding.map { "<style>body { padding: \($0)px; }</style>" },
    ].compactMap { $0 }

    loadHTMLString("\(html)\n\n\(styleSheets.joined(separator: "\n"))", baseURL: nil)
    magnification = 1.0
  }

  override public func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
    menu.items.forEach { item in
      // Hide the "Reload" item because it makes the content empty
      if item.identifier?.rawValue == "WKMenuItemIdentifierReload" {
        item.isHidden = true
      }
    }

    super.willOpenMenu(menu, with: event)
  }
}

// MARK: - WKNavigationDelegate

extension HtmlView: WKNavigationDelegate {
  public func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction
  ) async -> WKNavigationActionPolicy {
    // Instead of opening in place, open it with the default browser
    if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
      NSWorkspace.shared.open(url)
      return .cancel
    }

    return .allow
  }
}

// MARK: - Private

private extension HtmlView {
  /**
   Default styles to enable dark mode and default system fonts.
   */
  var defaultStyles: String {
    """
    <style>
      :root {
        color-scheme: light dark;
      }
      body {
        font-family: ui-monospace, system-ui;
        font-size: 13px;
      }
    </style>
    """
  }
}
