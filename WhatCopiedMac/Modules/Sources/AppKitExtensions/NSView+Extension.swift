//
//  NSView+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

public extension NSView {
  var layerBackgroundColor: NSColor? {
    get {
      guard wantsLayer, let cgColor = layer?.backgroundColor else {
        return nil
      }

      return NSColor(cgColor: cgColor)
    }
    set {
      wantsLayer = true
      layer?.backgroundColor = newValue?.resolvedColor(with: effectiveAppearance).cgColor
    }
  }

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
