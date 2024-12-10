//
//  DataWrapper.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

import AppKit

/**
 Wrapper of the pasteboard data that can be viewed as text, image or hex, etc.
 */
@MainActor
struct DataWrapper {
  let rawData: Data // Keep this because hex dump is slow
  let byteCount: String

  let plainText: String
  let attributedText: NSAttributedString?
  let imageObject: NSImage?

  init?(_ data: Data?) {
    guard let data else {
      return nil
    }

    self.rawData = data
    self.byteCount = Constants.byteFormatter.string(fromByteCount: Int64(data.count))

    self.plainText = .decode(data: data)
    self.attributedText = NSAttributedString(rtf: data, documentAttributes: nil)
    self.imageObject = NSImage(data: data)
  }
}

// MARK: - Private

private extension DataWrapper {
  enum Constants {
    @MainActor static let byteFormatter: ByteCountFormatter = {
      let formatter = ByteCountFormatter()
      formatter.allowedUnits = .useAll
      formatter.countStyle = .file

      return formatter
    }()
  }
}
