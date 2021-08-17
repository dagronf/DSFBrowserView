//
//  ViewController.swift
//  DSFBrowserView Demo
//
//  Created by Darren Ford on 16/8/21.
//

import Cocoa

import DSFAppKitBuilder
import DSFBrowserView

class ViewController: NSViewController {

	@IBOutlet weak var browserView: DSFBrowserView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		browserView.delegate = self

		browserView.set(allowsMultipleSelection: false, allowsEmptySelection: true, forColumn: 0)
		browserView.set(allowsMultipleSelection: false, allowsEmptySelection: true, forColumn: 1)
		browserView.set(allowsMultipleSelection: true, allowsEmptySelection: true, forColumn: 2)

		browserView.autohidesScrollers = true
		browserView.reloadData()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

extension ViewController: DSFBrowserViewDelegate {

	func rootItemFor(_ browser: DSFBrowserView) -> Any? {
		return sampleData
	}

	func browserView(_ browser: DSFBrowserView, numberOfChildrenOfItem item: Any?) -> Int {
		if let i = item as? SimpleData {
			return i.children.count
		}
		return 0
	}

	func browserView(_ browser: DSFBrowserView, child index: Int, ofItem item: Any?) -> Any {
		if let i = item as? SimpleData {
			return i.children[index]
		}
//		else if let i = item as? SimpleLeaf {
//			return nil
//		}
		fatalError()
	}

	func browserView(_ browser: DSFBrowserView, viewForItem item: Any?) -> NSView? {

		if let i = item as? SimpleData {
			let body =
			VStack(spacing: 2, alignment: .leading, distribution: .fillProportionally) {
				Label("Title '\(i.name)'")
					.lineBreakMode(.byTruncatingTail)
					.horizontalPriorities(hugging: 10, compressionResistance: 10)
				Label("The auto layout API only provides one way to calculate distances")
					.textColor(.placeholderTextColor)
					.font(NSFont.systemFont(ofSize: 11))
					.lineBreakMode(.byTruncatingTail)
					.horizontalPriorities(hugging: 10, compressionResistance: 10)
					.verticalPriorities(hugging: 999)
					.maxHeight(32)
					.additionalAppKitControlSettings { (field: NSTextField) in

						/// http://devetc.org/code/2014/07/07/auto-layout-and-views-that-wrap.html

						field.preferredMaxLayoutWidth = 250
						field.cell?.truncatesLastVisibleLine = true
						field.cell?.wraps = true
					}
			}
			.hugging(h: 10, v: 999)
			.edgeInsets(top: 4, bottom: 4)

			return body.view()
		}

		if let i = item as? SimpleLeaf {
			return HStack(alignment: .centerY, distribution: .fillProportionally) {
				ImageView(NSImage(named: "NSFolder")!).horizontalPriorities(hugging: .required, compressionResistance: .required)
				Label(i.name).horizontalPriorities(hugging: 10, compressionResistance: 10)
			}
			.height(48)
			.view()
		}

		return nil
	}

	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet]) {
		Swift.print("Did select [\(selections)]")
		let i = browser.selectedItems
		Swift.print(i)

		let l = browser.selectedLeafItems
		Swift.print(l)


	}

	func browserView(_ browser: DSFBrowserView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {

		if let i = item as? SimpleData {
			let item = NSPasteboardItem()
			item.setString("Data: \(i.name)", forType: .string)
			return item
		}

		if let i = item as? SimpleLeaf {
			let item = NSPasteboardItem()
			item.setString("Leaf: \(i.name)", forType: .string)
			return item
		}

		return nil
	}
}

class SimpleLeaf {
	let name: String
	init(_ name: String) {
		self.name = name
	}
}

class SimpleData: SimpleLeaf {
	let children: [SimpleLeaf]
	init(_ name: String, _ children: [SimpleLeaf] = []) {
		self.children = children
		super.init(name)
	}
}



let sampleData = SimpleData("", [
	SimpleData("Item 0", [
		SimpleData("Item 0:0", [
			SimpleLeaf("Item 0:0:0"), SimpleLeaf("Item 0:0:1"), SimpleLeaf("Item 0:0:2"), SimpleLeaf("Item 0:0:3"), SimpleLeaf("Item 0:0:4"), SimpleLeaf("Item 0:0:5")
		]),
		SimpleData("Item 0:1", [
			SimpleLeaf("Item 0:1:0"), SimpleLeaf("Item 0:1:1"), SimpleLeaf("Item 0:1:2"), SimpleLeaf("Item 0:1:3"), SimpleLeaf("Item 0:1:4"), SimpleLeaf("Item 0:1:5")
		]),
		SimpleData("Item 0:2", [
			SimpleLeaf("Item 0:2:0"), SimpleLeaf("Item 0:2:1"), SimpleLeaf("Item 0:2:2"), SimpleLeaf("Item 0:2:3"), SimpleLeaf("Item 0:2:4"), SimpleLeaf("Item 0:2:5")
		]),
		SimpleData("Item 0:3", [
			SimpleLeaf("Item 0:3:0"), SimpleLeaf("Item 0:3:1"), SimpleLeaf("Item 0:3:2"), SimpleLeaf("Item 0:3:3"), SimpleLeaf("Item 0:3:4"), SimpleLeaf("Item 0:3:5")
		]),
		SimpleData("Item 0:4", [
			SimpleLeaf("Item 0:4:0"), SimpleLeaf("Item 0:4:1"), SimpleLeaf("Item 0:4:2"), SimpleLeaf("Item 0:4:3"), SimpleLeaf("Item 0:4:4"), SimpleLeaf("Item 0:4:5")
		]),
		SimpleData("Item 0:5", [
			SimpleLeaf("Item 0:5:0"), SimpleLeaf("Item 0:5:1"), SimpleLeaf("Item 0:5:2"), SimpleLeaf("Item 0:5:3"), SimpleLeaf("Item 0:5:4"), SimpleLeaf("Item 0:5:5")
		]),
	]),
	SimpleData("Item 1", [
		SimpleData("Item 1:0", [
			SimpleLeaf("Item 1:0:0"), SimpleLeaf("Item 1:0:1"), SimpleLeaf("Item 1:0:2"), SimpleLeaf("Item 1:0:3"), SimpleLeaf("Item 1:0:4"), SimpleLeaf("Item 1:0:5")
		]),
		SimpleData("Item 1:1", [
			SimpleLeaf("Item 1:1:0"), SimpleLeaf("Item 1:1:1"), SimpleLeaf("Item 1:1:2"), SimpleLeaf("Item 1:1:3"), SimpleLeaf("Item 1:1:4"), SimpleLeaf("Item 1:1:5")
		]),
		SimpleData("Item 1:2", [
			SimpleLeaf("Item 1:2:0"), SimpleLeaf("Item 1:2:1"), SimpleLeaf("Item 1:2:2"), SimpleLeaf("Item 1:2:3"), SimpleLeaf("Item 1:2:4"), SimpleLeaf("Item 1:2:5")
		]),
		SimpleData("Item 1:3", [
			SimpleLeaf("Item 1:3:0"), SimpleLeaf("Item 1:3:1"), SimpleLeaf("Item 1:3:2"), SimpleLeaf("Item 1:3:3"), SimpleLeaf("Item 1:3:4"), SimpleLeaf("Item 1:3:5")
		]),
		SimpleData("Item 1:4", [
			SimpleLeaf("Item 1:4:0"), SimpleLeaf("Item 1:4:1"), SimpleLeaf("Item 1:4:2"), SimpleLeaf("Item 1:4:3"), SimpleLeaf("Item 1:4:4"), SimpleLeaf("Item 1:4:5")
		]),
		SimpleData("Item 1:5", [
			SimpleLeaf("Item 1:5:0"), SimpleLeaf("Item 1:5:1"), SimpleLeaf("Item 1:5:2"), SimpleLeaf("Item 1:5:3"), SimpleLeaf("Item 1:5:4"), SimpleLeaf("Item 1:5:5")
		]),
	]),
	SimpleData("Item 2", [
		SimpleData("Item 2:0", [
			SimpleLeaf("Item 2:0:0"), SimpleLeaf("Item 2:0:1"), SimpleLeaf("Item 2:0:2"), SimpleLeaf("Item 2:0:3"), SimpleLeaf("Item 2:0:4"), SimpleLeaf("Item 2:0:5")
		]),
		SimpleData("Item 2:1", [
			SimpleLeaf("Item 2:1:0"), SimpleLeaf("Item 2:1:1"), SimpleLeaf("Item 2:1:2"), SimpleLeaf("Item 2:1:3"), SimpleLeaf("Item 2:1:4"), SimpleLeaf("Item 2:1:5")
		]),
		SimpleData("Item 2:2", [
			SimpleLeaf("Item 2:2:0"), SimpleLeaf("Item 2:2:1"), SimpleLeaf("Item 2:2:2"), SimpleLeaf("Item 2:2:3"), SimpleLeaf("Item 2:2:4"), SimpleLeaf("Item 2:2:5")
		]),
		SimpleData("Item 2:3", [
			SimpleLeaf("Item 2:3:0"), SimpleLeaf("Item 2:3:1"), SimpleLeaf("Item 2:3:2"), SimpleLeaf("Item 2:3:3"), SimpleLeaf("Item 2:3:4"), SimpleLeaf("Item 2:3:5")
		]),
		SimpleData("Item 2:4", [
			SimpleLeaf("Item 2:4:0"), SimpleLeaf("Item 2:4:1"), SimpleLeaf("Item 2:4:2"), SimpleLeaf("Item 2:4:3"), SimpleLeaf("Item 2:4:4"), SimpleLeaf("Item 2:4:5")
		]),
		SimpleData("Item 2:5", [
			SimpleLeaf("Item 2:5:0"), SimpleLeaf("Item 2:5:1"), SimpleLeaf("Item 2:5:2"), SimpleLeaf("Item 2:5:3"), SimpleLeaf("Item 2:5:4"), SimpleLeaf("Item 2:5:5")
		]),
	])
])
