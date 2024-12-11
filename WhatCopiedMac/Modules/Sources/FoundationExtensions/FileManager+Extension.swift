//
//  FileManager+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/11.
//

import Foundation

public extension FileManager {
  func directoryExists(at url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    let fileExists = fileExists(atPath: url.path, isDirectory: &isDirectory)
    return fileExists && isDirectory.boolValue
  }
}
