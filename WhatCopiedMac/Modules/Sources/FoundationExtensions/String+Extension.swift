//
//  String+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/5.
//

import Foundation

public extension String {
  static func decode(data: Data, encodings: [String.Encoding] = [.utf8]) -> Self {
    for encoding in encodings {
      if let string = Self(data: data, encoding: encoding) {
        return string
      }
    }

    return data.ascii()
  }
}

// MARK: - Private

private extension Data {
  func ascii(unsupported: Character = ".") -> String {
    reduce(into: "") { result, byte in
      if (byte >= 32 && byte < 127) || (byte >= 160 && byte < 255) || byte == 0x0A || byte == 0x09 {
        result.append(Character(UnicodeScalar(byte)))
      } else {
        result.append(unsupported)
      }
    }
  }
}
