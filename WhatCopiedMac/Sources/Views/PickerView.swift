//
//  PickerView.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

/**
 Picker view used to select pasteboard and data type.
 */
final class PickerView: NSView {
  private let view: PickerViewImpl

  init(
    pasteboardChanged: @escaping ((NSPasteboard) -> Void),
    dataTypeChanged: @escaping ((String) -> Void)
  ) {
    self.view = PickerViewImpl(pasteboardChanged, dataTypeChanged)
    super.init(frame: .zero)

    let wrapper = NSHostingView(rootView: view)
    wrapper.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func shouldReselect(types: [String]) -> Bool {
    types != view.model.types
  }

  func reloadTypes(_ types: [String]) {
    view.model.types = types
  }

  func selectType(at index: Int) {
    guard index >= 0 && index < view.model.types.count else {
      return Logger.log(.info, "Invalid index: \(index) of types: \(self.view.model.types)")
    }

    let type = view.model.types[index]
    view.model.selection = type
    view.dataTypeChanged(type)
  }
}

// MARK: - Private

private struct PickerViewImpl: View {
  @Observable
  class Model {
    var types = [String]()
    var selection = ""
  }

  @State fileprivate var model = Model()
  @State fileprivate var pasteboardName = NSPasteboard.pasteboards.first?.readableName ?? ""

  fileprivate let pasteboardChanged: ((NSPasteboard) -> Void)
  fileprivate let dataTypeChanged: ((String) -> Void)

  init(
    _ pasteboardChanged: @escaping ((NSPasteboard) -> Void),
    _ dataTypeChanged: @escaping ((String) -> Void)
  ) {
    self.pasteboardChanged = pasteboardChanged
    self.dataTypeChanged = dataTypeChanged
  }

  var body: some View {
    VStack(spacing: 0) {
      Picker(selection: $pasteboardName) {
        ForEach(NSPasteboard.pasteboards.map { $0.readableName }, id: \.self) {
          Text($0)
        }
      } label: {
        // no-op
      }
      .padding(10)
      .onChange(of: pasteboardName) {
        if let pasteboardObject {
          pasteboardChanged(pasteboardObject)
        }
      }

      Divider()

      if model.types.isEmpty {
        Text(Localized.EmptyState.pasteboard)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollViewReader { scrollView in
          let selection = Binding(
            get: { model.selection },
            set: { model.selection = $0 }
          )

          List(model.types, id: \.self, selection: selection) { type in
            VStack(alignment: .leading, spacing: 3) {
              Text(type)
                .font(.headline)

              // Human-friendly name based on its UTI
              if let readableName = UTType(type)?.localizedDescription {
                Text(readableName)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
            .help(type)
            .contextMenu {
              Button(Localized.Menu.copyTypeName) {
                NSPasteboard.general.string = type
              }
            }
          }
          .listStyle(SidebarListStyle())
          .onChange(of: model.selection) {
            dataTypeChanged(model.selection)
          }
          .onChange(of: model.types) {
            scrollView.scrollTo(model.selection, anchor: .bottom)
          }
        }
      }
    }
  }
}

// MARK: - Private

private extension PickerViewImpl {
  var pasteboardObject: NSPasteboard? {
    let pasteboard = (NSPasteboard.pasteboards.first { $0.readableName == pasteboardName })
    Logger.assert(pasteboard != nil, "Invalid pasteboard: \(pasteboardName)")

    return pasteboard
  }
}
