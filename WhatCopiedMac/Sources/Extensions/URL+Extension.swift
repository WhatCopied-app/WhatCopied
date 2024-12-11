//
//  URL+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/11.
//

import Foundation

extension URL {
  static var previewingDirectory: URL {
    let directory = temporaryDirectory.appendingPathComponent("QuickLook")
    let fileManager = FileManager.default

    if !fileManager.directoryExists(at: directory) {
      do {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: false)
      } catch {
        Logger.log(.error, "Failed to create previewing directory: \(error.localizedDescription)")
      }
    }

    return directory
  }
}
