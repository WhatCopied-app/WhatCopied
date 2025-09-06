//
//  ImageView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

/**
 Simple NSScrollView wrapper to display scalable images.
 */
public final class ImageView: NSScrollView {
  public var image: NSImage? {
    get {
      actualView.image
    }
    set {
      actualView.image = newValue
      contentView.scroll(to: CGPoint(x: 0, y: safeAreaInsets.top))
      magnification = 1.0
    }
  }

  public init() {
    super.init(frame: .zero)
    drawsBackground = false
    documentView = actualView

    hasHorizontalScroller = true
    hasVerticalScroller = true

    allowsMagnification = true
    minMagnification = 1.0
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layout() {
    super.layout()
    actualView.frame = bounds
  }

  // MARK: - Private

  private let actualView = NSImageView()
}
