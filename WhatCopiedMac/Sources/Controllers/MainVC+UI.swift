//
//  MainVC+UI.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import AppKitExtensions
import QuickLookUI

extension MainVC {
  func addChildViews() {
    splitView.isVertical = true
    splitView.dividerStyle = .thin

    let sidebarItem = NSSplitViewItem(sidebarWithViewController: NSViewController())
    sidebarItem.minimumThickness = Constants.sidebarMinWidth
    sidebarItem.maximumThickness = Constants.sidebarMaxWidth
    addSplitViewItem(sidebarItem)

    let detailPaneItem = NSSplitViewItem(viewController: NSViewController())
    addSplitViewItem(detailPaneItem)

    let sidebar = AppDesign.modernEffectView.init()
    (sidebar as? NSVisualEffectView)?.material = .titlebar
    sidebar.fillView(sidebarItem.viewController.view)
    pickerView.fillView(sidebar)

    let detailPane = NSView()
    detailPane.fillView(detailPaneItem.viewController.view)

    dataViewer.translatesAutoresizingMaskIntoConstraints = false
    detailPane.addSubview(dataViewer)

    statusView.translatesAutoresizingMaskIntoConstraints = false
    detailPane.addSubview(statusView)

    NSLayoutConstraint.activate([
      dataViewer.leadingAnchor.constraint(equalTo: detailPane.leadingAnchor),
      dataViewer.trailingAnchor.constraint(equalTo: detailPane.trailingAnchor),
      dataViewer.topAnchor.constraint(equalTo: detailPane.topAnchor),
      dataViewer.bottomAnchor.constraint(equalTo: statusView.topAnchor),

      statusView.leadingAnchor.constraint(equalTo: detailPane.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: detailPane.trailingAnchor),
      statusView.bottomAnchor.constraint(equalTo: detailPane.bottomAnchor),
      statusView.heightAnchor.constraint(equalToConstant: 26),
    ])
  }

  func handleMouseMoved(with event: NSEvent) {
    guard view.window?.isKeyWindow == true, NSCursor.current != .arrow else {
      return
    }

    let boundary = view.bounds.height - view.safeAreaInsets.top
    let location = event.locationInWindow.y

    // NSTextView makes the cursor "I-beam" in its safe area
    if location > boundary && location < view.frame.height {
      NSCursor.arrow.push()
    }
  }

  @objc func didSelectViewer(_ sender: NSToolbarItemGroup) {
    displayMode = DisplayMode.allCases[sender.selectedIndex]
    reloadViewer()
  }

  @IBAction func copyTypeName(_ sender: Any?) {
    NSPasteboard.general.string = dataType
  }

  @IBAction func presentQuickLook(_ sender: Any?) {
    do {
      try selectedData?.write(to: previewingFileURL, options: .atomic)
    } catch {
      Logger.log(.error, "Failed to create file for preview: \(error)")
    }

    let previewPanel: QLPreviewPanel? = .shared()
    Logger.assert(previewPanel != nil, "Missing preview panel")

    // The preview pane initially appears in the left-bottom corner,
    // resetting it with a small rect resolves this issue.
    if previewPanel?.frame.origin == .zero, let screenRect = view.window?.screen?.visibleFrame {
      let panelSize = CGSize(width: 480, height: 320)
      let panelOrigin = CGPoint(
        x: screenRect.midX - panelSize.width * 0.5,
        y: screenRect.midY - panelSize.height * 0.5
      )

      previewPanel?.setFrame(CGRect(origin: panelOrigin, size: panelSize), display: true)
    }

    previewPanel?.reloadData()
    previewPanel?.makeKeyAndOrderFront(nil)
  }

  @IBAction func saveToDisk(_ sender: Any?) {
    let savePanel = NSSavePanel()
    savePanel.title = Localized.Toolbar.saveToDisk
    savePanel.nameFieldStringValue = suggestedFileName
    savePanel.isExtensionHidden = false
    savePanel.titlebarAppearsTransparent = true

    savePanel.begin { [weak self] response in
      Task { @MainActor in
        guard response == .OK, let data = self?.selectedData, let url = savePanel.url else {
          return Logger.log(.info, "Skipped saving")
        }

        do {
          try data.write(to: url, options: .atomic)
        } catch {
          Logger.log(.error, "Failed to save the file")
        }
      }
    }
  }
}

// MARK: - QLPreviewPanelDataSource

extension MainVC: @preconcurrency QLPreviewPanelDataSource {
  func numberOfPreviewItems(in panel: QLPreviewPanel?) -> Int {
    1
  }

  func previewPanel(_ panel: QLPreviewPanel?, previewItemAt index: Int) -> (any QLPreviewItem)? {
    previewingFileURL as NSURL
  }
}

// MARK: - Private

private extension MainVC {
  enum Constants {
    static let sidebarMinWidth: Double = 200
    static let sidebarMaxWidth: Double = 400
  }
}
