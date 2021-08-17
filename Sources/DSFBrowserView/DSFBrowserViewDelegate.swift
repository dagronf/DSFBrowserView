//
//  DSFBrowserViewDelegate.swift
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

/// The delegate protocol for the browser view
public protocol DSFBrowserViewDelegate {
	/// Retrieve the root item for the browser
	func rootItemFor(_ browser: DSFBrowserView) -> Any?

	/// Retrieve the number of children for the specified item
	func browserView(_ browser: DSFBrowserView, numberOfChildrenOfItem item: Any?) -> Int

	/// Return the child at index of the item
	func browserView(_ browser: DSFBrowserView, child index: Int, ofItem item: Any?) -> Any

	/// Returns the view that will display the item
	func browserView(_ browser: DSFBrowserView, viewForItem item: Any?) -> NSView?

	/// Called when the user changes the selection within the control
	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet])

	/// Called when the user starts dragging item(s) in a column
	func browserView(_ browser: DSFBrowserView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting?
}

// Default implementations
extension DSFBrowserViewDelegate {
	// Default implementation which does nothing
	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet]) { }

	// Default implementation which does nothing
	func browserView(_: DSFBrowserView, pasteboardWriterForRow _: Int, column _: Int) -> NSPasteboardWriting? {
		return nil
	}
}

#endif
