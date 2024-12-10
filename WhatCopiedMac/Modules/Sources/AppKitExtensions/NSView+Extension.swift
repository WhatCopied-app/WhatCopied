//
//  NSView+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

public extension NSView {
  func fillView(_ view: NSView, constant: Double = 0) {
    translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self)

    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant),
      leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
      trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant),
    ])
  }
}
