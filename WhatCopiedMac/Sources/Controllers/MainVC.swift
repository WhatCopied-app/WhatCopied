//
//  MainVC.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import QuickLookUI

final class MainVC: NSViewController {
  var pasteboard = NSPasteboard.general
  var dataType = ""
  var displayMode = DisplayMode.text

  lazy var splitView: NSSplitView = {
    let view = NSSplitView()
    view.isVertical = true
    view.dividerStyle = .thin
    view.delegate = self

    return view
  }()

  lazy var pickerView: PickerView = {
    let view = PickerView(
      pasteboardChanged: { [weak self] in
        self?.didSelectPasteboard($0)
      },
      dataTypeChanged: { [weak self] in
        self?.didSelectDataType($0)
      }
    )

    return view
  }()

  let dataViewer = DataViewer()
  let statusView = StatusView()

  override func viewDidLoad() {
    super.viewDidLoad()
    addChildViews()
    reloadTypes()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(pasteboardChanged),
      name: .pasteboardChanged,
      object: nil
    )
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    splitView.setPosition(200, ofDividerAt: 0)
    configureToolbar()
  }

  // MARK: - QLPreviewPanel

  override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel?) -> Bool {
    true
  }

  override func beginPreviewPanelControl(_ panel: QLPreviewPanel?) {
    Task { @MainActor in
      panel?.dataSource = self
    }
  }

  override func endPreviewPanelControl(_ panel: QLPreviewPanel?) {
    Task { @MainActor in
      try? FileManager.default.removeItem(at: previewingFileURL)
    }
  }
}
