//
//  util.swift
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

internal final class FlippedClipView: NSClipView {
	override var isFlipped: Bool {
		return true
	}
}

internal extension NSView {
	// Pin 'self' within 'other' view
	func pinEdges(to other: NSView, offset: CGFloat = 0, animate: Bool = false) {
		let target = animate ? animator() : self
		target.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: offset).isActive = true
		target.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -offset).isActive = true
		target.topAnchor.constraint(equalTo: other.topAnchor, constant: offset).isActive = true
		target.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -offset).isActive = true
	}
}

internal extension NSView {
	func padded(_ edgeInsets: NSEdgeInsets) -> NSView {
		let v = NSView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.addSubview(self)
		self.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: edgeInsets.left).isActive = true
		self.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -edgeInsets.right).isActive = true
		self.topAnchor.constraint(equalTo: v.topAnchor, constant: edgeInsets.top).isActive = true
		self.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -edgeInsets.bottom).isActive = true
		return v
	}
}

internal extension Array {
	@inlinable func at(_ index: Int) -> Element? {
		if index >= 0 && index < self.count {
			return self[index]
		}
		return nil
	}
}

#endif
