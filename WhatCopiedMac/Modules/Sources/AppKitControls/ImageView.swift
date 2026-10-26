//
//  ImageView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/4.
//

import AppKit

/**
 Displays images fitted to the visible viewport at 1x, with magnification for zooming in.
 */
public final class ImageView: NSScrollView {
  override public var contentInsets: NSEdgeInsets {
    didSet {
      needsLayout = true
    }
  }

  public var image: NSImage? {
    get {
      actualView.image
    }
    set {
      actualView.image = newValue
      magnification = 1.0
      needsLayout = true
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

    // Clip-view insets include toolbar and scroller space, in magnified coordinates
    let insets = contentView.contentInsets
    let viewport = contentView.bounds.size
    let size = NSSize(
      width: max(0, viewport.width - insets.left - insets.right) * magnification,
      height: max(0, viewport.height - insets.top - insets.bottom) * magnification
    )

    if actualView.frame.size != size {
      actualView.setFrameSize(size)
    }
  }

  // MARK: - Private

  private let actualView = NSImageView()
}
