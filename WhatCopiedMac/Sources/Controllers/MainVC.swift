//
//  MainVC.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import QuickLookUI

final class MainVC: NSSplitViewController {
  var pasteboard = NSPasteboard.general
  var dataType = ""
  var displayMode = DisplayMode.text

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

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(pasteboardChanged),
      name: .pasteboardChanged,
      object: nil
    )

    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      // Kill the app immediately on Cmd-Q to work around a known hang issue
      if event.deviceIndependentFlags == .command && event.keyCode == 0x0C {
        NSApp.terminate(nil)
        return nil
      }

      // Close the keyWindow on Cmd-W to work around a known hang issue
      if event.deviceIndependentFlags == .command && event.keyCode == 0x0D {
        NSApp.keyWindow?.close()
        return nil
      }

      // Press spacebar to quick look, just like Finder
      if let self, self.view.window?.isKeyWindow == true, event.keyCode == 0x31 {
        self.presentQuickLook(nil)
        return nil
      }

      return event
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    splitView.setPosition(200, ofDividerAt: 0)
    configureToolbar()
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    reloadTypes()
  }

  override func mouseMoved(with event: NSEvent) {
    super.mouseMoved(with: event)
    handleMouseMoved(with: event)
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
    // no-op
  }
}

// MARK: - Line Wrapping

extension MainVC: NSMenuItemValidation {
  private var supportedModes: [DisplayMode] {
    [.sourceCode]
  }

  func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if menuItem.action == #selector(toggleLineWrapping(_:)) {
      return supportedModes.contains(displayMode)
    }

    return true
  }

  @IBAction func toggleLineWrapping(_ sender: Any?) {
    let isEnabled = !AppPreferences.Viewer.lineWrapping
    AppPreferences.Viewer.lineWrapping = isEnabled

    supportedModes.forEach {
      dataViewer.setLineWrapping(isEnabled, mode: $0)
    }
  }
}
