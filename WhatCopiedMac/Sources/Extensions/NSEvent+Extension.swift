//
//  NSEvent+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2025/12/24.
//

import AppKit

extension NSEvent {
  var deviceIndependentFlags: NSEvent.ModifierFlags {
    modifierFlags.intersection(.deviceIndependentFlagsMask)
  }
}
