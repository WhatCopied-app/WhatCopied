//
//  main.swift
//  WhatCopied
//
//  Created by cyan on 2026/7/2.
//

import AppKit

// Apple introduced "floating sidebar" in macOS 26 and deprecated that in macOS 27,
// disable manually to keep the experience consistent.
//
// MUST be overridden before the app is initialized.
UserDefaults.standard.set(false, forKey: "NSSplitViewItemSidebarDefaultsToFloatingAppearance")

// "Populating a menu window that is already visible"
NSMenu.swizzleIsUpdatedExcludingContentTypesOnce

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
