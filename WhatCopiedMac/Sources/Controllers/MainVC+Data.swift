//
//  MainVC+Data.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import UniformTypeIdentifiers

extension MainVC {
  var selectedData: Data? {
    pasteboard.data(forType: NSPasteboard.PasteboardType(rawValue: dataType))
  }

  var suggestedFileName: String {
    guard let uttype = UTType(dataType) else {
      return dataType
    }

    let suffix = uttype.conforms(to: .plainText) ? "txt" : uttype.preferredFilenameExtension
    guard let suffix, !dataType.hasSuffix("." + suffix) else {
      return dataType
    }

    return dataType.appending("." + suffix)
  }

  var previewingFileURL: URL {
    .previewingDirectory.appendingPathComponent(suggestedFileName)
  }

  func reloadTypes() {
    let types = pasteboard.sortedTypes.compactMap { $0.rawValue }
    let reselect = pickerView.shouldReselect(types: types)
    pickerView.reloadTypes(types)

    if reselect {
      pickerView.selectType(at: 0)
    }

    reloadViewer()
  }

  func reloadViewer(detectType: Bool = false) {
    let data = DataWrapper(selectedData)
    if detectType {
      let preferredMode = preferredDisplayMode(
        ofData: data,
        dataType: dataType
      )

      if preferredMode != displayMode {
        Logger.log(.info, "Switching to preferred mode: \(preferredMode)")
        displayMode = preferredMode

        // Reselect the toolbar popup button
        if let item = (currentToolbar?.items.first {
          $0.itemIdentifier == .displayModeItem
        }) as? NSToolbarItemGroup, let index = DisplayMode.allCases.firstIndex(of: preferredMode) {
          item.selectedIndex = index
        }
      }
    }

    dataViewer.reloadData(data, mode: displayMode)
    statusView.reloadData(data, dataType: dataType)
  }

  @objc func pasteboardChanged() {
    Logger.log(.info, "Reloading data after pasteboard changed")
    reloadTypes()
  }

  // MARK: - Action Handlers

  func didSelectPasteboard(_ newValue: NSPasteboard) {
    Logger.log(.info, "didSelectPasteboard: \(newValue.name)")
    pasteboard = newValue
    reloadTypes()
  }

  func didSelectDataType(_ newValue: String) {
    Logger.log(.info, "didSelectDataType: \(newValue)")
    dataType = newValue
    reloadViewer(detectType: true)
  }
}

// MARK: - Private

private extension MainVC {
  func preferredDisplayMode(ofData data: DataWrapper?, dataType: String) -> DisplayMode {
    let mapping: [UTType: DisplayMode] = [
      .html: .html,
      .sourceCode: .sourceCode,
      .rtf: .rtf,
      .image: .image,
    ]

    if let preferred = (mapping.first { UTType(dataType)?.conforms(to: $0.key) == true }) {
      return preferred.value
    }

    return data?.imageObject != nil ? .image : .text
  }
}
