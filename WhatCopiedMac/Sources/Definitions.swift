//
//  Definitions.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

/**
 To make localization work, always use `String(localized:comment:)` directly and add to this file.

 Besides, we use `string catalogs` to do the translation work:
 https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog
 */
enum Localized {
  enum Toolbar {
    static let displayMode = String(localized: "Display Mode", comment: "Toolbar label: Display Mode")
    static let quickLook = String(localized: "Quick Look", comment: "Toolbar label: Quick Look")
    static let operations = String(localized: "Operations", comment: "Toolbar label: Operations")
    static let saveToDisk = String(localized: "Save to Disk", comment: "Toolbar label: Save to Disk")
  }

  enum Menu {
    static let clearAllPasteboards = String(localized: "Clear All Pasteboards", comment: "Menu item title: Clear All Pasteboards")
    static let clearCurrentPasteboard = String(localized: "Clear Current Pasteboard", comment: "Menu item title: Clear Current Pasteboard")
    static let clearOtherPasteboards = String(localized: "Clear Other Pasteboards", comment: "Menu item title: Clear Other Pasteboards")
    static let keepOnlyPlainText = String(localized: "Keep Only Plain Text", comment: "Menu item title: Keep Only Plain Text")
    static let keepOnlyImages = String(localized: "Keep Only Images", comment: "Menu item title: Keep Only Images")
    static let copyTypeName = String(localized: "Copy Type Name", comment: "Menu item title: Copy Type Name")
  }

  enum DisplayMode {
    static let text = String(localized: "Plain Text", comment: "Display mode: Plain Text")
    static let html = String(localized: "Rich Text (HTML)", comment: "Display mode: Rich Text (HTML)")
    static let rtf = String(localized: "Rich Text (RTF)", comment: "Display mode: Rich Text (RTF)")
    static let sourceCode = String(localized: "Source Code", comment: "Display mode: Source Code")
    static let image = String(localized: "Image", comment: "Display mode: Image")
    static let hex = String(localized: "Hexadecimal", comment: "Display mode: Hexadecimal")
  }

  enum ErrorState {
    static let pasteboard = String(localized: "(empty pasteboard)", comment: "Error state: (empty pasteboard)")
    static let data = String(localized: "(no data)", comment: "Error state: (no data)")
    static let preview = String(localized: "(no preview)", comment: "Error state: (no view)")
    static let limitedAccess = String(localized: "Limited Access", comment: "Error state: Limited Access")
  }
}

// Icon set used in the app: https://developer.apple.com/sf-symbols/
//
// Note: double check availability and deployment target before adding new icons
enum Icons {
  static let eye = "eye"
  static let handRaisedSlash = "hand.raised.slash"
  static let squareAndArrowDown = "square.and.arrow.down"
  static let wandAndSparkles = "wand.and.sparkles"
}
