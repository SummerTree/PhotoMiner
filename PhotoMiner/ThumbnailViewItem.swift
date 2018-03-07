//
//  ThumbnailViewItem.swift
//  PhotoMiner
//
//  Created by Gergely Sánta on 30/12/2016.
//  Copyright © 2016 TriKatz. All rights reserved.
//

import Cocoa

protocol ThumbnailViewItemDelegate {
	func thumbnailClicked(_ thumbnail: ThumbnailViewItem, with event: NSEvent)
	func thumbnailRightClicked(_ thumbnail: ThumbnailViewItem, with event: NSEvent)
}

class ThumbnailViewItem: NSCollectionViewItem {
	
	var delegate:ThumbnailViewItemDelegate? = nil
	
	private static let unselectedFrameColor = NSColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)
	private static let selectedFrameColor = NSColor(red:0.27, green:0.65, blue:0.88, alpha:1.00)
	private static let unselectedBorderColor = NSColor(red:1.00, green:0.85, blue:0.88, alpha:1.00)
	private static let selectedBorderColor = NSColor(red:0.25, green:0.58, blue:0.78, alpha:1.00)
	private static let unselectedTextColor = NSColor.darkGray
	private static let selectedTextColor = NSColor.white
	private static let dragStartsAtDistance:CGFloat = 5.0
	
	override var isSelected:Bool {
		didSet {
			updateBackground()
		}
	}
	
	private(set) var hasBorder = false {
		didSet {
			updateBackground()
		}
	}
	
	override var representedObject:Any? {
		didSet {
			if let object = representedObject as? ImageData {
				object.setThumbnail()
				hasBorder = Configuration.shared.highlightPicturesWithoutExif ? !object.hasExif : false
				
				self.textField?.stringValue = object.imageName
				if Configuration.shared.creationDateAsLabel {
					let formatter = DateFormatter()
					formatter.dateStyle = .medium
					formatter.timeStyle = .short
					self.textField?.stringValue = formatter.string(from: object.creationDate)
				}
				self.imageView?.bind(NSBindingName(rawValue: "value"), to: object, withKeyPath: "imageThumbnail", options: nil)
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.wantsLayer = true
		view.layer?.backgroundColor = ThumbnailViewItem.unselectedFrameColor.cgColor
		view.layer?.cornerRadius = 4.0
		
		// We re-set the representedObject for the case it was set before this function call
		let object = self.representedObject
		self.representedObject = object
		
		updateBackground()
    }
	
	func updateBackground() {
		if isSelected {
			view.layer?.backgroundColor = ThumbnailViewItem.selectedFrameColor.cgColor
			view.layer?.borderColor = ThumbnailViewItem.selectedBorderColor.cgColor
			if let textField = textField {
				textField.textColor = ThumbnailViewItem.selectedTextColor
			}
		}
		else {
			view.layer?.backgroundColor = ThumbnailViewItem.unselectedFrameColor.cgColor
			view.layer?.borderColor = ThumbnailViewItem.unselectedBorderColor.cgColor
			if let textField = textField {
				textField.textColor = ThumbnailViewItem.unselectedTextColor
			}
		}
		view.layer?.borderWidth = hasBorder ? 2.0 : 0.0
	}
	
	// MARK: - Mouse events
	//
	
	override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)
		self.delegate?.thumbnailClicked(self, with: event)
	}
	
	override func rightMouseDown(with event: NSEvent) {
		super.rightMouseDown(with: event)
		self.delegate?.thumbnailRightClicked(self, with: event)
	}
	
}
