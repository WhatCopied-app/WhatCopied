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
    let sidebar = NSVisualEffectView()
    sidebar.material = .sidebar
    sidebar.blendingMode = .behindWindow
    sidebar.translatesAutoresizingMaskIntoConstraints = false
    pickerView.fillView(sidebar)

    let detailPane = NSView()
    detailPane.translatesAutoresizingMaskIntoConstraints = false

    dataViewer.translatesAutoresizingMaskIntoConstraints = false
    detailPane.addSubview(dataViewer)

    statusView.translatesAutoresizingMaskIntoConstraints = false
    detailPane.addSubview(statusView)

    splitView.addArrangedSubview(sidebar)
    splitView.addArrangedSubview(detailPane)
    splitView.fillView(view)

    NSLayoutConstraint.activate([
      dataViewer.leadingAnchor.constraint(equalTo: detailPane.leadingAnchor),
      dataViewer.trailingAnchor.constraint(equalTo: detailPane.trailingAnchor),
      dataViewer.topAnchor.constraint(equalTo: detailPane.topAnchor),
      dataViewer.bottomAnchor.constraint(equalTo: statusView.topAnchor),

      statusView.leadingAnchor.constraint(equalTo: detailPane.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: detailPane.trailingAnchor),
      statusView.bottomAnchor.constraint(equalTo: detailPane.bottomAnchor),
      statusView.heightAnchor.constraint(equalToConstant: 24),
    ])
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

// MARK: - NSSplitViewDelegate

/**
 These methods collectively achieve the following behaviors:

 1. The sidebar remains a fixed size during window resizing
 2. The sidebar resizes only when necessary, e.g., the window is too small
 3. Users can manually resize the sidebar using the divider
 4. Minimum widths are enforced for both the sidebar and detail pane
 */
extension MainVC: NSSplitViewDelegate {
  private enum Constants {
    static let sidebarMinWidth: Double = 120
    static let detailPaneMinWidth: Double = 440
  }

  func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: CGSize) {
    Logger.assert(splitView.subviews.count == 2, "Invalid splitView hierarchy of: \(splitView)")
    var leftRect = splitView.subviews[0].frame
    var rightRect = splitView.subviews[1].frame

    // Enforce minimum width for the left view
    leftRect.size.width = max(Constants.sidebarMinWidth, leftRect.size.width)
    leftRect.size.height = splitView.bounds.height

    // Right view re-positioning
    rightRect.size.width = splitView.bounds.width - leftRect.size.width
    rightRect.size.height = splitView.bounds.height
    rightRect.origin.x = leftRect.size.width

    // Enforce minimum width for the right view
    if rightRect.size.width < Constants.detailPaneMinWidth {
      let adjustment = Constants.detailPaneMinWidth - rightRect.size.width
      leftRect.size.width -= adjustment
      rightRect.size.width = Constants.detailPaneMinWidth
      rightRect.origin.x = leftRect.size.width
    }

    splitView.subviews[0].frame = leftRect
    splitView.subviews[1].frame = rightRect
  }

  func splitView(
    _ splitView: NSSplitView,
    constrainMinCoordinate proposedMinimumPosition: CGFloat,
    ofSubviewAt dividerIndex: Int
  ) -> CGFloat {
    dividerIndex == 0 ? Constants.sidebarMinWidth : proposedMinimumPosition
  }

  func splitView(
    _ splitView: NSSplitView,
    constrainMaxCoordinate proposedMaximumPosition: CGFloat,
    ofSubviewAt dividerIndex: Int
  ) -> CGFloat {
    dividerIndex == 0 ? splitView.bounds.width - Constants.detailPaneMinWidth : proposedMaximumPosition
  }
}
