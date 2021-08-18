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

		browserView.addColumn("Heading 1", allowMultipleSelection: false, allowEmptySelection: true)
		browserView.addColumn("Heading 2", allowMultipleSelection: false, allowEmptySelection: true)
		browserView.addColumn("Heading 3", allowMultipleSelection: true, allowEmptySelection: true)

		browserView.autohidesScrollers = true
		browserView.hideSeparators = false
		browserView.reloadData()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	var reloadCount = 0
	@IBAction func userPressedReset(_ sender: Any) {
		reloadCount += 1
		browserView.reloadData()
	}

	var reloadColumn1Count = 0
	@IBAction func reloadOne(_ sender: Any) {
		reloadColumn1Count += 1
		browserView.reloadData(column: 1)
	}


}

extension ViewController: DSFBrowserViewDelegate {
	func rootItem(for browser: DSFBrowserView) -> Any? {
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
		fatalError()
	}

	// Only useful for macOS 10.12 and lower.
	func browserView(_ browser: DSFBrowserView, heightOfViewForItem item: Any?) -> CGFloat {
		48
	}

	func browserView(_ browser: DSFBrowserView, viewForItem item: Any?, column: Int, row: Int) -> NSView? {
		if let i = item as? SimpleData {

			let title: String = {
				if column == 1 {
					return "Title '\(i.name)' (\(self.reloadCount)) [\(reloadColumn1Count)]"
				}
				return "Title '\(i.name)' (\(self.reloadCount))"
			}()

			let body =
			VStack(spacing: 2, alignment: .leading, distribution: .fillProportionally) {
				Label(title)
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

	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [[Any]]) {
		Swift.print("Did select [\(selections)]")
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
