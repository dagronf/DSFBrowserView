//
//  DSFBrowserView+Column.swift
//
//  Created by Darren Ford on 17/08/21
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if os(macOS)

import AppKit

internal extension DSFBrowserView {
	// Internal browser column view
	class BrowserColumn: NSObject, NSTableViewDataSource, NSTableViewDelegate {
		unowned var parent: DSFBrowserView!

		let contentStack: NSStackView
		let label: NSTextField
		let tableView: NSTableView
		let scrollView: NSScrollView
		let offset: Int

		/// The item that defines the content for the column
		var item: Any?

		deinit {
			self.item = nil
			self.parent = nil

			self.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		}

		var heading: String = "" {
			didSet {
				self.label.stringValue = self.heading
			}
		}

		var hideHeading: Bool = false {
			didSet {
				self.label.isHidden = self.hideHeading
				self.label.superview?.isHidden = self.hideHeading
			}
		}

		internal func view() -> NSView { return self.contentStack }

		var isActive: Bool = false {
			didSet {
				self.updateBackground()
				self.tableView.reloadData()
			}
		}

		var columnSelection: IndexSet {
			return self.isActive ? self.tableView.selectedRowIndexes : IndexSet()
		}

		func updateBackground() {
			if self.isActive {
				self.scrollView.drawsBackground = false
			}
			else {
				self.scrollView.drawsBackground = true
				self.scrollView.backgroundColor = .underPageBackgroundColor
			}
			self.scrollView.needsDisplay = true
		}

		init(parent: DSFBrowserView, offset: Int) {
			self.parent = parent
			self.offset = offset

			let stack = NSStackView()
			self.contentStack = stack
			stack.orientation = .vertical
			stack.alignment = .leading
			stack.distribution = .fillProportionally
			stack.spacing = 0
			stack.setHuggingPriority(.defaultHigh, for: .vertical)
			stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
			stack.detachesHiddenViews = true

			let label = NSTextField()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.setContentHuggingPriority(.defaultLow, for: .horizontal)
			label.setContentHuggingPriority(.defaultHigh, for: .vertical)
			label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
			label.isEditable = false
			label.isBordered = false
			label.drawsBackground = false
			label.isHidden = self.heading.isEmpty
			label.stringValue = self.heading
			self.label = label

			let paddedLabel = label.padded(NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))

			self.contentStack.addArrangedSubview(paddedLabel)

			let tableView = BrowserColumnTableView()
			tableView.translatesAutoresizingMaskIntoConstraints = false
			if #available(macOSApplicationExtension 10.13, *) {
				tableView.usesAutomaticRowHeights = true
			}
			else {
				// Fallback on earlier versions
			}
			tableView.allowsEmptySelection = true
			tableView.allowsMultipleSelection = false
			if #available(macOS 11.0, *) {
				tableView.style = .inset
			}
			else {
				// Fallback on earlier versions
			}
			// tableView.gridStyleMask = .dashedHorizontalGridLineMask

			let column = NSTableColumn()
			tableView.addTableColumn(column)
			tableView.headerView = nil
			self.tableView = tableView

			let scrollView = NSScrollView()
			self.scrollView = scrollView

			scrollView.translatesAutoresizingMaskIntoConstraints = false
			scrollView.borderType = .noBorder
			scrollView.drawsBackground = true

			scrollView.autohidesScrollers = false
			scrollView.hasVerticalScroller = true
			scrollView.borderType = .noBorder

			let clipView = FlippedClipView()
			clipView.drawsBackground = false
			scrollView.contentView = clipView
			clipView.translatesAutoresizingMaskIntoConstraints = false
			clipView.drawsBackground = false

			clipView.pinEdges(to: scrollView)

			scrollView.documentView = tableView

			NSLayoutConstraint.activate([
				tableView.leftAnchor.constraint(equalTo: clipView.leftAnchor),
				tableView.topAnchor.constraint(equalTo: clipView.topAnchor),
				tableView.rightAnchor.constraint(equalTo: clipView.rightAnchor),
				// NOTE: No need for bottomAnchor
			])

			self.contentStack.addArrangedSubview(self.scrollView)

			super.init()

			self.updateBackground()

			tableView.parent = self
			tableView.delegate = self
			tableView.dataSource = self
		}

		func reload() {
			self.tableView.reloadData()
		}

		private func ArrowImage() -> NSImageView {
			let image = (self.parent.userInterfaceLayoutDirection == .rightToLeft)
				? NSImage(named: "NSGoLeftTemplate")!
				: NSImage(named: "NSGoRightTemplate")!

			let i = NSImageView()
			i.image = image
			i.translatesAutoresizingMaskIntoConstraints = false
			i.setContentHuggingPriority(.required, for: .horizontal)
			return i
		}

		func numberOfRows(in _: NSTableView) -> Int {
			guard self.isActive else {
				return 0
			}

			guard let delegate = self.parent.delegate else { return 0 }
			return delegate.browserView(self.parent, numberOfChildrenOfItem: self.item)
		}

		func tableView(_: NSTableView, heightOfRow row: Int) -> CGFloat {
			if #available(macOS 10.13, *) {
				return 24
			}

			guard let delegate = self.parent.delegate else { return 24 }
			let child = delegate.browserView(self.parent, child: row, ofItem: self.item)
			return delegate.browserView(self.parent, heightOfViewForItem: child)
		}

		func tableView(_: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
			guard self.isActive else { return nil }

			guard let delegate = self.parent.delegate else { return nil }

			let theItem = delegate.browserView(self.parent, child: row, ofItem: self.item)
			guard let v = delegate.browserView(self.parent, viewForItem: theItem) else {
				return nil
			}

			if self.parent.isLeaf(column: self.offset) {
				return v
			}

			let stack = NSStackView()
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.orientation = .horizontal
			stack.distribution = .fillProportionally
			stack.spacing = 8

			stack.addArrangedSubview(v)

			stack.addArrangedSubview(self.ArrowImage())

			stack.needsLayout = true
			stack.layout()

			return stack
		}

		func tableViewSelectionDidChange(_: Notification) {
			self.parent.selectionsDidChange(column: self.offset, rows: self.columnSelection)
		}

		/// When a table row has begun to be dragged
		func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
			if let item = self.parent.delegate?.browserView(self.parent, child: row, ofItem: self.item) {
				return self.parent.delegate?.browserView(self.parent, pasteboardWriterForItem: item)
			}
			return nil
		}
	}
}

// MARK: - Keyboard handling

internal extension DSFBrowserView.BrowserColumn {
	func moveForward() {
		self.parent.moveForward(self)
	}

	func moveBack() {
		self.parent.moveBack(self)
	}
}

private class BrowserColumnTableView: NSTableView {
	// This tableview WILL NOT outlive the column which contains it
	unowned var parent: DSFBrowserView.BrowserColumn!

	deinit {
		self.parent = nil // Unnecessary due to unowned, but lets be a good citizen
	}

	override func keyDown(with event: NSEvent) {
		if event.keyCode == 0x7C { // kVK_RightArrow
			self.parent.moveForward()
		}
		else if event.keyCode == 0x7B { // kVK_LeftArrow
			self.parent.moveBack()
		}
		else {
			super.keyDown(with: event)
		}
	}
}

#endif
