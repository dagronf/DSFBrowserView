//
//  DSFBrowserView.swift
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

@IBDesignable
public class DSFBrowserView: NSView {
	/// The header visibility
	public enum HeaderVisibility: Int {
		/// Show the headers, even if they are empty
		case show = 0
		/// Hide the headers
		case hide = 1
		/// Autohide the headers if ALL the headers are empty
		case autohide = 2
	}

	/// The delegate for the browser view
	public var delegate: DSFBrowserViewDelegate?

	/// A Boolean that indicates whether the scroll view automatically hides its
	/// scroll bars when they are not needed.
	@IBInspectable public var autohidesScrollers: Bool = false {
		didSet {
			self.updateAutohidesScrollers()
		}
	}

	/// A Boolean that indicates whether the scroll view automatically hides its
	/// scroll bars when they are not needed.
	@IBInspectable public var hideSeparators: Bool = true {
		didSet {
			self.browserStack.arrangedSubviews
				.compactMap { $0 as? NSBox }
				.forEach { $0.isHidden = self.hideSeparators }
		}
	}

	/// The visibility of the header.  Should only be used from interface builder
	@IBInspectable public var headerVisibilityValue: Int = 0 {
		didSet {
			self.headerVisibility = HeaderVisibility(rawValue: self.headerVisibilityValue) ?? .autohide
		}
	}

	// MARK: - Number of columns

	/// The initial number of columns for the browser. Should only be used from interface builder
	@IBInspectable public var numberOfColumns: Int = 3

	// MARK: - IB Titles

	@IBInspectable public var title1: String = "" {
		didSet {
			self.setHeaderText(self.title1, forColumn: 0)
		}
	}

	@IBInspectable public var allowsMultipleSelection1: Bool = false {
		didSet {
			self.setAllowsMultipleSelection(allowsMultipleSelection1, forColumn: 0)
		}
	}

	@IBInspectable public var title2: String = "" {
		didSet {
			self.setHeaderText(self.title2, forColumn: 1)
		}
	}

	@IBInspectable public var title3: String = "" {
		didSet {
			self.setHeaderText(self.title3, forColumn: 2)
		}
	}

	@IBInspectable public var title4: String = "" {
		didSet {
			self.setHeaderText(self.title4, forColumn: 3)
		}
	}

	@IBInspectable public var title5: String = "" {
		didSet {
			self.setHeaderText(self.title5, forColumn: 4)
		}
	}

	// MARK: - Header visibility

	/// The header visibility for the browser
	public var headerVisibility: HeaderVisibility = .autohide {
		didSet {
			self.updateAllColumnsForHeaderVisibility()
		}
	}

	/// The font to use for headings
	public var headerFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize) {
		didSet {
			self.syncHeaderFont()
		}
	}

	/// The number of columns in the browser view
	public var columnCount: Int {
		return self.columns.count
	}

	/// Returns the selections in browser
	public var columnSelections: [IndexSet] {
		return self.columns.map {
			$0.columnSelection
		}
	}

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()

		// If we're loading from a XIB, create the number of columns required
		self.preloadFromXIB()
	}

	// Privates

	private let browserStack = NSStackView()
	private var columns: [BrowserColumn] = []
}

// MARK: - Column definition

public extension DSFBrowserView {
	/// The definition of a column in the browser
	struct Column {
		let heading: String
		let allowMultipleSelection: Bool
		let allowEmptySelection: Bool

		/// Create a column definition
		/// - Parameters:
		///   - heading: The heading text to display
		///   - allowMultipleSelection: Does the column allow multiple selection?
		///   - allowEmptySelection: Does the column allow empty selection?
		public init(
			_ heading: String = "",
			allowMultipleSelection: Bool = false,
			allowEmptySelection: Bool = true
		) {
			self.heading = heading
			self.allowMultipleSelection = allowMultipleSelection
			self.allowEmptySelection = allowEmptySelection
		}
	}
}

// MARK: - Interface builder support

public extension DSFBrowserView {
	func preloadFromXIB() {
		(0 ..< self.numberOfColumns).forEach { index in
			switch index {
			case 0: self.addColumn(self.title1)
			case 1: self.addColumn(self.title2)
			case 2: self.addColumn(self.title3)
			case 3: self.addColumn(self.title4)
			case 4: self.addColumn(self.title5)
			default: self.addColumn("")
			}
		}
	}

	override func prepareForInterfaceBuilder() {
		self.setup()
		self.removeAllColumns()
		self.preloadFromXIB()
	}
}

// MARK: - Add Column

public extension DSFBrowserView {
	/// Add a column with an optional header
	/// - Parameter headerText: The title for the column (optional)
	@inlinable func addColumn(
		_ headerText: String = "",
		allowsMultipleSelection: Bool = false,
		allowsEmptySelection: Bool = false
	) {
		self.add(
			Column(headerText,
			       allowMultipleSelection: allowsMultipleSelection,
			       allowEmptySelection: allowsEmptySelection))
	}

	/// Add a column
	/// - Parameter column: The column definition
	func add(_ column: Column) {
		let c = BrowserColumn(parent: self, offset: columns.count)
		if self.columns.count == 0 {
			c.isActive = true
		}
		c.heading = column.heading
		c.tableView.allowsEmptySelection = column.allowEmptySelection
		c.tableView.allowsMultipleSelection = column.allowMultipleSelection

		if self.columns.count > 0 {
			let separator = NSBox(frame: NSRect(x: 0, y: 0, width: 5, height: 50))
			separator.translatesAutoresizingMaskIntoConstraints = false
			separator.boxType = .separator
			separator.setContentHuggingPriority(.defaultLow, for: .vertical)
			separator.setContentHuggingPriority(.required, for: .horizontal)

			separator.isHidden = self.hideSeparators

			self.browserStack.addArrangedSubview(separator)
		}

		c.parent = self
		c.label.font = self.headerFont
		self.columns.append(c)
		self.browserStack.addArrangedSubview(c.view())

		self.updateAllColumnsForHeaderVisibility()
		self.updateAutohidesScrollers()
	}

	/// Remove all the columns from the browser view
	func removeAllColumns() {
		self.columns.removeAll()
		self.browserStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}
}

// MARK: - Settings

public extension DSFBrowserView {
	/// Set the column the allow multiple selections
	func setAllowsMultipleSelection(_ allow: Bool, forColumn column: Int) {
		if let column = self.columns.at(column) {
			column.tableView.allowsMultipleSelection = allow
		}
	}

	/// Set the column the allow empty selections
	func setAllowsEmptySelection(_ allow: Bool, forColumn column: Int) {
		if let column = self.columns.at(column) {
			column.tableView.allowsEmptySelection = allow
		}
	}

	/// Set the column title
	func setHeaderText(_ headerText: String = "", forColumn column: Int) {
		if let column = self.columns.at(column) {
			column.heading = headerText
			self.updateAllColumnsForHeaderVisibility()
		}
	}

	/// Set settings for a particular column
	func set(_ headerText: String? = nil,
	         allowsMultipleSelection: Bool? = nil,
	         allowsEmptySelection: Bool? = nil,
	         forColumn column: Int)
	{
		if let h = headerText {
			self.setHeaderText(h, forColumn: column)
		}
		if let m = allowsMultipleSelection {
			self.setAllowsMultipleSelection(m, forColumn: column)
		}
		if let a = allowsEmptySelection {
			self.setAllowsEmptySelection(a, forColumn: column)
		}
	}
}

// MARK: - Reloading data

public extension DSFBrowserView {
	/// Reload the entire contents of the browser view
	func reloadData() {
		self.updateAllColumnsForHeaderVisibility()
		self.columns[0].reload()
	}

	/// Reload the contents of a particular column
	func reload(column: Int) {
		self.columns[column].reload()
	}
}

private extension DSFBrowserView {
	// Configure the base view
	private func setup() {
		self.browserStack.translatesAutoresizingMaskIntoConstraints = false
		self.browserStack.orientation = .horizontal
		self.browserStack.distribution = .fillEqually
		self.browserStack.spacing = 4

		self.addSubview(self.browserStack)

		NSLayoutConstraint.activate([
			self.browserStack.leftAnchor.constraint(equalTo: self.leftAnchor),
			self.browserStack.rightAnchor.constraint(equalTo: self.rightAnchor),
			self.browserStack.topAnchor.constraint(equalTo: self.topAnchor),
			self.browserStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
	}

	private func updateAutohidesScrollers() {
		self.columns
			.forEach { $0.scrollView.autohidesScrollers = self.autohidesScrollers }
	}

	private func updateAllColumnsForHeaderVisibility() {
		switch self.headerVisibility {
		case .show:
			self.columns.forEach { $0.hideHeading = false }
		case .hide:
			self.columns.forEach { $0.hideHeading = true }
		case .autohide:
			self.columns.forEach { $0.hideHeading = self.allHeadingsEmpty }
		}
	}

	// Push the header font setting down through the columns
	private func syncHeaderFont() {
		self.columns.forEach {
			$0.label.font = self.headerFont
			$0.contentStack.needsLayout = true
		}
	}

	// Are all the headings empty?
	private var allHeadingsEmpty: Bool {
		for column in self.columns {
			if !column.heading.isEmpty {
				return false
			}
		}
		return true
	}

	// Is the column index the last (leaf) column?
	private func isLeaf(column: Int) -> Bool {
		return column == self.columnCount - 1
	}

	// Called from the column
	private func selectionsDidChange(column: Int, rows: IndexSet) {
		if rows.isEmpty {
			((column + 1) ..< self.columnCount).forEach { index in
				self.columns[index].isActive = false
			}
		}
		else {
			if column < self.columnCount - 1 {
				self.columns[column + 1].isActive = true
			}
			if column < self.columnCount - 2 {
				(column + 2 ..< self.columnCount).forEach { index in
					self.columns[index].isActive = false
				}
			}
		}

		// Update the view
		self.delegate?.browserView(self, selectionDidChange: self.columnSelections)
	}
}

extension DSFBrowserView {
	// Internal browser column view
	class BrowserColumn: NSObject, NSTableViewDataSource, NSTableViewDelegate {
		let contentStack: NSStackView
		let label: NSTextField
		let tableView: NSTableView
		let scrollView: NSScrollView
		let offset: Int

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

		unowned var parent: DSFBrowserView!

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

			let tableView = NSTableView()
			tableView.translatesAutoresizingMaskIntoConstraints = false
			tableView.usesAutomaticRowHeights = true
			tableView.allowsEmptySelection = true
			tableView.allowsMultipleSelection = false
			if #available(macOS 11.0, *) {
				tableView.style = .inset
			}
			else {
				// Fallback on earlier versions
			}
			tableView.gridStyleMask = .dashedHorizontalGridLineMask

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

			let i = NSImageView(image: image)
			i.translatesAutoresizingMaskIntoConstraints = false
			i.setContentHuggingPriority(.required, for: .horizontal)
			return i
		}

		func numberOfRows(in _: NSTableView) -> Int {
			guard self.isActive else {
				return 0
			}

			guard let delegate = self.parent.delegate else { return 0 }
			return delegate.browserView(self.parent, numberOfRowsForColumn: self.offset)
		}

		func tableView(_: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
			guard self.isActive else { return nil }

			guard let delegate = self.parent.delegate else { return nil }
			guard let v = delegate.browserView(self.parent, viewForRow: row, inColumn: self.offset) else {
				return nil
			}

			if self.parent.isLeaf(column: self.offset) {
				return v
			}

			let stack = NSStackView()
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.orientation = .horizontal
			stack.distribution = .fillProportionally
			stack.spacing = 0

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
			return self.parent.delegate?.browserView(self.parent, pasteboardWriterForRow: row, column: self.offset)
		}
	}
}

#endif
