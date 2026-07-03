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
  private let model = PickerViewImpl.Model()
  private let view: PickerViewImpl

  init(
    pasteboardChanged: @escaping ((NSPasteboard) -> Void),
    dataTypeChanged: @escaping ((String) -> Void)
  ) {
    self.view = PickerViewImpl(model, pasteboardChanged, dataTypeChanged)
    super.init(frame: .zero)

    let wrapper = NSHostingView(rootView: view)
    wrapper.fillView(self)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func shouldReselect(types: [String]) -> Bool {
    types != model.types
  }

  func reloadTypes(_ types: [String]) {
    model.types = types
  }

  func selectType(at index: Int) {
    guard index >= 0 && index < model.types.count else {
      return Logger.log(.info, "Invalid index: \(index) of types: \(self.model.types)")
    }

    let type = model.types[index]
    model.selection = type
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

  fileprivate let model: Model
  @State fileprivate var pasteboardName = NSPasteboard.pasteboards.first?.readableName ?? ""

  fileprivate let pasteboardChanged: ((NSPasteboard) -> Void)
  fileprivate let dataTypeChanged: ((String) -> Void)

  init(
    _ model: Model,
    _ pasteboardChanged: @escaping ((NSPasteboard) -> Void),
    _ dataTypeChanged: @escaping ((String) -> Void)
  ) {
    self.model = model
    self.pasteboardChanged = pasteboardChanged
    self.dataTypeChanged = dataTypeChanged
  }

  var body: some View {
    VStack(spacing: 0) {
      Picker(selection: $pasteboardName) {
        ForEach(NSPasteboard.pasteboards, id: \.readableName) { pasteboard in
          HStack(alignment: .center) {
            Image(systemName: pasteboard.iconName)
            Text(spacedTitle(pasteboard.readableName))
          }
          .tag(pasteboard.readableName)
        }
      } label: {
        // no-op
      }
      .controlSize(.large)
      .modifier(FlexibleButtonSize())
      .padding(10)
      .onChange(of: pasteboardName) {
        if let pasteboardObject {
          pasteboardChanged(pasteboardObject)
        }
      }

      if model.types.isEmpty {
        Text(Localized.ErrorState.pasteboard)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        // Optically center
        Spacer(minLength: 40)
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

      if NSPasteboard.general.hasLimitedAccess {
        Button {
          NSWorkspace.shared.safelyOpenURL(string: "https://github.com/WhatCopied-app/WhatCopied/wiki#limited-access")
        } label: {
          Label(Localized.ErrorState.limitedAccess, systemImage: Icons.handRaisedSlash)
        }
        .padding()
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

  /**
   Prefix the title with three thin spaces to align with the icon, only needed on macOS 26.
   */
  func spacedTitle(_ title: String) -> String {
    guard #available(macOS 26.0, *) else {
      return title
    }

    guard #unavailable(macOS 27.0) else {
      return title
    }

    return "\u{2009}\u{2009}\u{2009}\(title)"
  }
}

private struct FlexibleButtonSize: ViewModifier {
  func body(content: Content) -> some View {
    if #available(macOS 26.0, *) {
      content.buttonSizing(.flexible)
    } else {
      content
    }
  }
}
