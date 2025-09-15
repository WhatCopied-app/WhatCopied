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
      textView.drawsBackground = false
      textView.isEditable = false
      textView.isSelectable = true
      textView.usesFindPanel = true
      textView.textContainer?.lineFragmentPadding = 0

      // We avoid using width in textContainerInset as it disrupts the cursor style
      textView.textContainerInset = CGSize(
        width: 0,
        height: Constants.textContainerInset
      )

      // Instead, we use a tail indent and adjust the leading position to achieve the same effect
      textView.defaultParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.tailIndent = -textView.textContainerInset.height
        return style
      }()
    } else {
      Logger.assertFail("Unable to cast documentView as NSTextView")
    }

    return view
  }()

  private let htmlView = HtmlView()
  private let codeView = CodeView(margin: AppDesign.contentMargin)
  private let imageView = ImageView()
  private let emptyView = StaticText(Localized.ErrorState.preview)

  init() {
    super.init(frame: .zero)
    wantsLayer = true

    textView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(textView)

    NSLayoutConstraint.activate([
      textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.textContainerInset),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor),
      textView.topAnchor.constraint(equalTo: topAnchor),
      textView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

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

    if !AppDesign.modernStyle {
      layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
    }
  }

  func reloadData(_ data: DataWrapper?, mode: DisplayMode) {
    guard let data else {
      return showEmptyView()
    }

    textView.isHidden = !mode.usesTextView
    htmlView.isHidden = mode != .html
    codeView.isHidden = mode != .sourceCode
    imageView.isHidden = mode != .image
    emptyView.isHidden = true

    switch mode {
    // The below modes can always show something
    case .text:
      textView.monospacedText = data.plainText
    case .html:
      htmlView.loadHtml(data.plainText, padding: AppDesign.modernStyle ? 7.0 : nil)
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
  enum Constants {
    @MainActor static let textContainerInset = AppDesign.contentMargin
  }

  func showEmptyView() {
    subviews.forEach {
      $0.isHidden = $0 != emptyView
    }
  }
}
