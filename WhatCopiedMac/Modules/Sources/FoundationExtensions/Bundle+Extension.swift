//
//  Bundle+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/7.
//

import Foundation

public extension Bundle {
  var shortVersionString: String? {
    infoDictionary?["CFBundleShortVersionString"] as? String
  }
}
