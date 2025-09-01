//
//  StatusView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import SwiftUI

/**
 Status view that displays byte count and data type.
 */
final class StatusView: NSView {
  private let view = StatusViewImpl()

  init() {
    super.init(frame: .zero)

    let wrapper = NSHostingView(rootView: view)
    wrapper.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func reloadData(_ data: DataWrapper?, dataType: String) {
    if let data {
      view.model.text = "\(data.byteCount): \(dataType)"
      view.model.style = .primary
    } else {
      view.model.text = Localized.ErrorState.data
      view.model.style = .secondary
    }
  }
}

// MARK: - Private

private struct StatusViewImpl: View {
  @Observable
  class Model {
    var text = ""
    var style: any ShapeStyle = .primary
  }

  @State fileprivate var model = Model()

  var body: some View {
    VStack(spacing: 0) {
      Divider()
      Text(model.text)
        .foregroundStyle(model.style)
        .font(.callout)
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, AppDesign.contentMargin)
    }
  }
}
