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

// The delegate protocol for the browser view
public protocol DSFBrowserViewDelegate {
	/// Request the number of rows to display in the specified column
	func browserView(_ browser: DSFBrowserView, numberOfRowsForColumn: Int) -> Int

	/// Return the view to be displayed for the specified row and column
	func browserView(_ browser: DSFBrowserView, viewForRow row: Int, inColumn column: Int) -> NSView?

	/// Called when the user changes the selection within the control
	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet])

	/// Called when the user starts to drag row(s) in a column
	func browserView(_ browser: DSFBrowserView, pasteboardWriterForRow row: Int, column: Int) -> NSPasteboardWriting?
}

extension DSFBrowserViewDelegate {
	// Default implementation which does nothing
	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet]) { }

	// Default implementation which does nothing
	func browserView(_: DSFBrowserView, pasteboardWriterForRow _: Int, column _: Int) -> NSPasteboardWriting? {
		return nil
	}
}

#endif
