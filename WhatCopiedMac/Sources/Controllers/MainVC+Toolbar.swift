//
//  MainVC+Toolbar.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit
import UniformTypeIdentifiers

extension MainVC {
  var currentToolbar: NSToolbar? {
    view.window?.toolbar
  }

  func configureToolbar() {
    guard let window = view.window else {
      return Logger.assertFail("Missing window to set up the toolbar")
    }

    let toolbar = NSToolbar(identifier: "MainToolbar")
    toolbar.displayMode = .iconOnly
    toolbar.allowsUserCustomization = true
    toolbar.autosavesConfiguration = true
    toolbar.delegate = self

    window.toolbar = toolbar
    window.toolbar?.validateVisibleItems()
    window.acceptsMouseMovedEvents = true

    // Uncomment the below code to take screenshots
    // DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //   if let screen = NSScreen.main {
    //     let frame = CGRect(
    //       x: 50,
    //       y: screen.frame.maxY - 482, // 400 + 50 + 32
    //       width: 600,
    //       height: 400
    //     )
    //     window.setFrame(frame, display: true, animate: true)
    //   }
    // }
  }
}

// MARK: - NSToolbarDelegate

extension MainVC: NSToolbarDelegate {
  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    let item: NSToolbarItem? = {
      switch itemIdentifier {
      case .displayModeItem: return displayModeItem
      case .quickLookItem: return quickLookItem
      case .operationsItem: return operationsItem
      case .saveToDiskItem: return saveToDiskItem
      default: return nil
      }
    }()

    item?.toolTip = item?.label
    item?.isBordered = true
    return item
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    toolbarDefaultItemIdentifiers(toolbar) + [.space, .flexibleSpace]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [
      .toggleSidebar, .sidebarTrackingSeparator,
      .displayModeItem, .quickLookItem, .operationsItem, .saveToDiskItem,
    ]
  }
}

// MARK: - Private

private extension MainVC {
  var displayModeItem: NSToolbarItem {
    let titles = DisplayMode.allCases.map(\.description)
    let item = NSToolbarItemGroup(
      itemIdentifier: .displayModeItem,
      titles: titles,
      selectionMode: .selectOne,
      labels: titles,
      target: self,
      action: #selector(didSelectViewer(_:))
    )

    item.label = Localized.Toolbar.displayMode
    item.controlRepresentation = .collapsed
    item.selectionMode = .selectOne
    item.selectedIndex = 0
    return item
  }

  var quickLookItem: NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: .quickLookItem)
    item.image = NSImage(systemSymbolName: Icons.eye, accessibilityDescription: nil)
    item.label = Localized.Toolbar.quickLook

    item.addAction { [weak self] in
      self?.presentQuickLook(nil)
    }

    return item
  }

  var operationsItem: NSToolbarItem {
    let item = NSMenuToolbarItem(itemIdentifier: .operationsItem)
    item.label = Localized.Toolbar.operations
    item.image = NSImage(systemSymbolName: Icons.wandAndSparkles, accessibilityDescription: nil)

    let menu = NSMenu()
    menu.addItem(withTitle: Localized.Menu.clearAllPasteboards) {
      NSPasteboard.clearPasteboards()
    }

    menu.addItem(withTitle: Localized.Menu.clearCurrentPasteboard) { [weak self] in
      self?.pasteboard.clearContents()
    }

    menu.addItem(withTitle: Localized.Menu.clearOtherPasteboards) { [weak self] in
      self?.pasteboard.clearOtherPasteboards()
    }

    menu.addItem(.separator())

    menu.addItem(withTitle: Localized.Menu.keepOnlyPlainText) { [weak self] in
      self?.pasteboard.keepDataType(.plainText)
    }

    menu.addItem(withTitle: Localized.Menu.keepOnlyImages) { [weak self] in
      self?.pasteboard.keepDataType(.image)
    }

    item.menu = menu
    return item
  }

  var saveToDiskItem: NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: .saveToDiskItem)
    item.image = NSImage(systemSymbolName: Icons.squareAndArrowDown, accessibilityDescription: nil)
    item.label = Localized.Toolbar.saveToDisk

    item.addAction { [weak self] in
      self?.saveToDisk(nil)
    }

    return item
  }
}
