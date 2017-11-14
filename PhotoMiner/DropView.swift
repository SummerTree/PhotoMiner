//
//  DropView.swift
//  PhotoMiner
//
//  Created by Gergely Sánta on 14/03/2017.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import Cocoa

class DropView: NSView {

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor(calibratedWhite: 1.0, alpha: 0.9).setFill()
		dirtyRect.fill()
		super.draw(dirtyRect)
	}
	
	func show() {
		self.animator().alphaValue = 1.0
	}
	
	func hide() {
		self.animator().alphaValue = 0.0
	}
	
	private func initialize() {
		// Unregister from dragging all components
		for view in subviews {
			view.unregisterDraggedTypes()
		}
		// Register this view for handling fileURLs
		self.registerForDraggedTypes([NSPasteboard.PasteboardType.init(rawValue: kUTTypeFileURL as String)])
	}
	
	private func getDirPaths(fromPasteboard pasteboard: NSPasteboard) -> [URL] {
		var urls = [URL]()
		if let pboardUrls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
			for url in pboardUrls {
				var isDirectory:ObjCBool = false
				if FileManager.default.fileExists(atPath: url.path, isDirectory:&isDirectory) {
					if isDirectory.boolValue {
						urls.append(url)
					}
				}
			}
		}
		return urls
	}
	
	// MARK: NSDraggingDestination methods
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		super.draggingEntered(sender)
		let validDrop = (getDirPaths(fromPasteboard: sender.draggingPasteboard()).count > 0) ? true : false
		if validDrop {
			show()
			return .copy
		}
		return NSDragOperation()
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		super.draggingExited(sender)
		if let appDelegate = NSApp.delegate as? AppDelegate {
			if appDelegate.imageCollection.count > 0 {
				hide()
			}
		}
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		super.performDragOperation(sender)
		let urls = getDirPaths(fromPasteboard: sender.draggingPasteboard())
		var paths = [String]()
		for url in urls {
			paths.append(url.path)
		}
		if Configuration.shared.setLookupDirectories(paths),
			let mainWindowController = self.window?.windowController as? MainWindowController
		{
			mainWindowController.startScan()
		}
		return true
	}
	
}
