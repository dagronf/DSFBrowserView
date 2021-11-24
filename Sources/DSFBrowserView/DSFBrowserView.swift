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
		/// Hide the header if ALL the headers are empty
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
			self.hSplitView.showsSplitter = !self.hideSeparators
			self.hSplitView.needsLayout = true
		}
	}

	/// The autosave name for the control.
	///
	/// Set an autosave name to remember the positioning of the splitters
	@IBInspectable public var autosaveName: String? {
		get { self.hSplitView.autosaveName }
		set { self.hSplitView.autosaveName = newValue }
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
				self.delegate?.browserView(self, child: selection, ofItem: column.item)
			}
		}
	}

	/// Returns the selected leaf items
	public var selectedLeafItems: [Any] {
		guard
			let leafSels = self.columnSelections.last,
			leafSels.count > 0,
			let lastColumn = self.columns.last,
			let lastColumnItem = lastColumn.item else
		{
			return []
		}

		return leafSels.compactMap { selection in
			self.delegate?.browserView(self, child: selection, ofItem: lastColumnItem)
		}
	}

	// MARK: - Creation and deletion

	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	deinit {
		self.hSplitView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.columns.removeAll()
	}

	// Privates
	class BrowserSplitView: NSSplitView {
		var splitterColor: NSColor = .gridColor
		var showsSplitter = true {
			didSet {
				splitterColor = showsSplitter ? .gridColor : .clear
			}
		}

		override var dividerColor: NSColor {
			self.splitterColor
		}
	}

	private let hSplitView: BrowserSplitView = {
		let v = BrowserSplitView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.isVertical = true
		v.dividerStyle = .thin
		return v
	}()

	private var columns: [BrowserColumn] = []
}

// MARK: - Add Column

public extension DSFBrowserView {
	/// Add a column with an optional header
	/// - Parameter headerText: The title for the column (optional)
	@inlinable func addColumn(
		_ headerText: String = "",
		allowMultipleSelection: Bool = false,
		allowEmptySelection: Bool = false
	) {
		self.add(
			Column(headerText,
			       allowMultipleSelection: allowMultipleSelection,
			       allowEmptySelection: allowEmptySelection))
	}

	/// Add a column
	/// - Parameter column: The column definition
	func add(_ column: Column) {
		let c = BrowserColumn(parent: self, columnIndex: columns.count)
		if self.columns.count == 0 {
			c.isActive = true
		}
		c.heading = column.heading
		c.tableView.allowsEmptySelection = column.allowEmptySelection
		c.tableView.allowsMultipleSelection = column.allowMultipleSelection

		c.parent = self
		c.label.font = self.headerFont
		self.columns.append(c)
		
		self.hSplitView.addArrangedSubview(c.view())

		self.updateAllColumnsForHeaderVisibility()
		self.updateAutohidesScrollers()
	}

	/// Remove all the columns from the browser view
	func removeAllColumns() {
		self.columns.removeAll()
		self.hSplitView.arrangedSubviews.forEach { $0.removeFromSuperview() }
	}
}

// MARK: - Column sizing

public extension DSFBrowserView {
	/// Make all the columns the same width
	func makeEqualWidths() {
		let w = self.hSplitView.frame.width / CGFloat(self.hSplitView.arrangedSubviews.count)
		var pos = w
		for i in 0 ..< self.hSplitView.arrangedSubviews.count - 1 {
			self.hSplitView.setPosition(pos, ofDividerAt: i)
			pos += w
		}
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
		forColumn column: Int
	) {
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

		self.columns[0].tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
		self.columns[0].item = self.delegate?.rootItem(for: self)
		self.columns[0].reload()
	}

	/// Reload the contents of a particular column
	func reloadData(column: Int) {
		// let column = self.columns[column]
		self.columns[column].reload()
	}
}

internal extension DSFBrowserView {
	// Configure the base view
	private func setup() {
		self.addSubview(self.hSplitView)

		NSLayoutConstraint.activate([
			self.hSplitView.leftAnchor.constraint(equalTo: self.leftAnchor),
			self.hSplitView.rightAnchor.constraint(equalTo: self.rightAnchor),
			self.hSplitView.topAnchor.constraint(equalTo: self.topAnchor),
			self.hSplitView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
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
		self.delegate?.browserView(self, selectionDidChange: self.selectedItems)
	}
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

// MARK: - Keyboard handling

internal extension DSFBrowserView {
	func moveForward(_ column: BrowserColumn) {
		if column.columnIndex >= self.columnCount - 1 {
			return
		}

		let nextColumn = self.columns[column.columnIndex + 1]
		if nextColumn.tableView.numberOfRows > 0 {
			self.window?.makeFirstResponder(nextColumn.tableView)
		}

		if nextColumn.tableView.selectedRowIndexes.count == 0 {
			// Select the first row
			nextColumn.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
		}
	}

	func moveBack(_ column: BrowserColumn) {
		if column.columnIndex == 0 {
			return
		}

		let prevColumn = self.columns[column.columnIndex - 1]
		self.window?.makeFirstResponder(prevColumn.tableView)

		if column.tableView.allowsEmptySelection {
			column.tableView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
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

// MARK: - Saving/loading from user defaults

public extension DSFBrowserView {

	/// Load the layout from the user defaults.
	func loadFromDefaults(userDefaults: UserDefaults = UserDefaults.standard) -> Bool {
		guard
			let autosaveName = self.autosaveName,
			let settings = userDefaults.dictionary(forKey: autosaveName)
		else {
			return false
		}

		if let widths = settings["dividerPositions"] as? [CGFloat] {
			for w in widths.enumerated() {
				self.hSplitView.setPosition(w.1, ofDividerAt: w.0)
			}
		}

		let hideSeparators = settings["hideSeparators"] as? Bool ?? true
		self.hideSeparators = hideSeparators

		let headerVisibility = settings["headerVisibility"] as? Int ?? 0
		if let e = HeaderVisibility(rawValue: headerVisibility) {
			self.headerVisibility = e
		}

		return true
	}

	/// Save the current layout to the user defaults
	func saveToDefaults(userDefaults: UserDefaults = UserDefaults.standard) {
		guard let autosaveName = self.autosaveName else { return }

		let def = NSMutableDictionary()
		let dividerCount = self.hSplitView.arrangedSubviews.count - 1
		var pos: CGFloat = 0
		let widths: [CGFloat] = (0 ..< dividerCount).map {
			pos += self.hSplitView.arrangedSubviews[$0].frame.width
			return pos
		}
		def["dividerPositions"] = widths
		def["hideSeparators"] = self.hideSeparators
		def["headerVisibility"] = self.headerVisibility.rawValue

		userDefaults.set(def, forKey: autosaveName)
	}
}

#endif
