//
//  NSControl+Extension.swift
//  WhatCopied
//
//  Created by cyan on 2024/12/3.
//

import AppKit

/**
 Closure-based handlers to replace target-action.
 */
@MainActor
public protocol ClosureActionable: AnyObject {
  var target: AnyObject? { get set }
  var action: Selector? { get set }
}

public extension ClosureActionable {
  func addAction(_ action: @escaping () -> Void) {
    let target = Handler(action)
    objc_setAssociatedObject(self, UUID().uuidString, target, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

    self.target = target
    self.action = #selector(Handler.invoke)
  }
}

extension NSMenuItem: ClosureActionable {}
extension NSToolbarItem: ClosureActionable {}

// MARK: - Private

private class Handler: NSObject {
  private let action: () -> Void

  init(_ action: @escaping () -> Void) {
    self.action = action
  }

  @objc func invoke() {
    action()
  }
}
