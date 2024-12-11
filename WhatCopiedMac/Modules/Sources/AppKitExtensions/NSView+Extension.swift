//
//  NSView+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

public extension NSView {
  func fillView(_ view: NSView) {
    translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self)

    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor),
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}
