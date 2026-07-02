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
  private let model = StatusViewImpl.Model()
  private let view: StatusViewImpl

  init() {
    self.view = StatusViewImpl(model: model)
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
      model.text = "\(data.byteCount): \(dataType)"
      model.style = .primary
    } else {
      model.text = Localized.ErrorState.data
      model.style = .secondary
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

  fileprivate let model: Model

  init(model: Model) {
    self.model = model
  }

  var body: some View {
    VStack(spacing: 0) {
      Divider()
      Text(model.text)
        .foregroundStyle(model.style)
        .font(.callout)
        .lineLimit(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, AppDesign.contentMargin)
    }
  }
}
