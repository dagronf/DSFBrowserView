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
	public var autohidesScrollers: Bool = false {
		didSet {
			self.updateAutohidesScrollers()
		}
	}

	/// A Boolean that indicates whether the scroll view automatically hides its
	/// scroll bars when they are not needed.
	public var hideSeparators: Bool = true {
		didSet {
			self.browserStack.arrangedSubviews
				.compactMap { $0 as? NSBox }
				.forEach { $0.isHidden = self.hideSeparators }
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

	// MARK: - Selections

	/// Returns the selections in browser
	public var columnSelections: [IndexSet] {
		return self.columns.map {
			$0.columnSelection
		}
	}

	/// Returns ALL selected items in all columns
	public var selectedItems: [[Any]] {
		let s = self.columnSelections
		return self.columns.enumerated().map {
			// The index of the column
			let index = $0.offset

			// The column
			let column = $0.element

			// All the selections in the column
			let selections = s[index]

			return selections.compactMap { selection in
				return self.delegate?.browserView(self, child: selection, ofItem: column.item)
			}
		}
	}

	/// Returns the selected leaf items
	public var selectedLeafItems: [Any] {
		guard
			let leafSels = self.columnSelections.last,
			leafSels.count > 0,
			let lastColumn = self.columns.last,
			let lastColumnItem = lastColumn.item else {
				return []
			}

		return leafSels.compactMap { selection in
			self.delegate?.browserView(self, child: selection, ofItem: lastColumnItem)
		}
	}

	// MARK: - Creation

	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
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
	override func prepareForInterfaceBuilder() {
		self.setup()
		self.removeAllColumns()
		
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
	func set(
		_ headerText: String? = nil,
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

		self.columns[0].item = self.delegate?.rootItemFor(self)

		self.columns[0].reload()
	}

	/// Reload the contents of a particular column
	func reload(column: Int) {
		self.columns[column].reload()
	}
}

internal extension DSFBrowserView {
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
	func isLeaf(column: Int) -> Bool {
		return column == self.columnCount - 1
	}

	// Called from the column
	func selectionsDidChange(column: Int, rows: IndexSet) {
		if rows.isEmpty {
			((column + 1) ..< self.columnCount).forEach { index in
				self.columns[index].isActive = false
			}
		}
		else {
			if column < self.columnCount - 1 {
				// Get the item for the column that changed
				let item = self.columns[column].item

				// Ask the delegate for the rootItem for the NEXT column
				let nextColumnRootItem = self.delegate?.browserView(self, child: rows.first!, ofItem: item)

				self.columns[column + 1].item = nextColumnRootItem
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

// MARK: - Keyboard handling

internal extension DSFBrowserView {

	func moveForward(_ column: BrowserColumn) {
		if column.offset >= self.columnCount - 1 {
			return
		}

		let nextColumn = self.columns[column.offset + 1]
		if nextColumn.tableView.numberOfRows > 0 {
			self.window?.makeFirstResponder(nextColumn.tableView)
		}

		if nextColumn.tableView.selectedRowIndexes.count == 0 {
			// Select the first row
			nextColumn.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
		}

	}

	func moveBack(_ column: BrowserColumn) {
		if column.offset == 0 {
			return
		}

		let prevColumn = self.columns[column.offset - 1]
		self.window?.makeFirstResponder(prevColumn.tableView)

		if column.tableView.allowsEmptySelection {
			column.tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
		}
	}

}

#endif
