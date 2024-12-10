//
//  DataViewer.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import AppKitControls
import SwiftUI
import WebKit
import FoundationExtensions

/**
 Viewer to display the pasteboard data.
 */
final class DataViewer: NSView {
  private let textView: NSScrollView = {
    let view = NSTextView.scrollableTextView()
    view.allowsMagnification = true
    view.minMagnification = 1.0

    if let textView = view.documentView as? NSTextView {
      textView.isEditable = false
      textView.drawsBackground = false
      textView.isSelectable = true
      textView.usesFindPanel = true
      textView.textContainerInset = CGSize(width: 10, height: 10)
      textView.textContainer?.lineFragmentPadding = 0
    } else {
      Logger.assertFail("Unable to cast documentView as NSTextView")
    }

    return view
  }()

  private let htmlView = HtmlView()
  private let codeView = CodeView()
  private let imageView = ImageView()
  private let emptyView = StaticText(Localized.EmptyState.preview)

  init() {
    super.init(frame: .zero)
    wantsLayer = true

    textView.fillView(self)
    htmlView.fillView(self)
    codeView.fillView(self)
    imageView.fillView(self)
    emptyView.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
  }

  func reloadData(_ data: DataWrapper?, mode: DisplayMode) {
    guard let data else {
      return showEmptyView()
    }

    textView.isHidden = !mode.usesTextView
    textView.contentView.scroll(to: .zero)
    textView.allowsNonContiguousLayout = mode == .hex

    htmlView.isHidden = mode != .html
    codeView.isHidden = mode != .sourceCode
    imageView.isHidden = mode != .image
    emptyView.isHidden = true

    switch mode {
    // The below modes can always show something
    case .text:
      textView.monospacedText = data.plainText
    case .html:
      htmlView.loadHtml(data.plainText)
    case .sourceCode:
      codeView.loadCode(data.plainText)
    case .hex:
      textView.monospacedText = hexDump(data.rawData, 10)
    // RTF and Image modes can fail
    case .rtf:
      if let attributedText = data.attributedText {
        textView.attributedText = attributedText
      } else {
        showEmptyView()
      }
    case .image:
      if let image = data.imageObject {
        imageView.image = image
      } else {
        showEmptyView()
      }
    }
  }
}

// MARK: - Private

private extension DataViewer {
  func showEmptyView() {
    subviews.forEach {
      $0.isHidden = $0 != emptyView
    }
  }
}
