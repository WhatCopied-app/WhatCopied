//
//  AppVersion.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import Foundation

/**
 [GitHub Releases API](https://api.github.com/repos/WhatCopied-app/WhatCopied/releases/latest)
 */
struct AppVersion: Decodable {
  let name: String
  let body: String
  let htmlUrl: String
}
