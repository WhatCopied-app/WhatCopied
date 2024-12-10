//
//  StaticText.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

import AppKit
import AppKitExtensions
import SwiftUI

/**
 Simple SwiftUI.Text wrapper to display static text.
 */
public final class StaticText: NSView {
  public init(_ text: String, style: any ShapeStyle = .secondary) {
    super.init(frame: .zero)

    let wrapper = NSHostingView(rootView: Text(text)
        .foregroundStyle(style)
        .frame(maxWidth: .infinity, maxHeight: .infinity))

    wrapper.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
