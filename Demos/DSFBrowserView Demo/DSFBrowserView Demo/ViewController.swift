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

	let data: [(String, [(String, [String])])] = [

		("Item 0", [
			("Item 0:0", [
				"Item 0:0:0","Item 0:0:1","Item 0:0:2","Item 0:0:3","Item 0:0:4","Item 0:0:5"
			]),
			("Item 0:1", [
				"Item 0:1:0","Item 0:1:1","Item 0:1:2","Item 0:1:3","Item 0:1:4","Item 0:1:5"
			]),
			("Item 0:2", [
				"Item 0:2:0","Item 0:2:1","Item 0:2:2","Item 0:2:3","Item 0:2:4","Item 0:2:5"
			]),
			("Item 0:3", [
				"Item 0:3:0","Item 0:3:1","Item 0:3:2","Item 0:3:3","Item 0:3:4","Item 0:3:5"
			]),
			("Item 0:4", [
				"Item 0:4:0","Item 0:4:1","Item 0:4:2","Item 0:4:3","Item 0:4:4","Item 0:4:5"
			]),
			("Item 0:5", [
				"Item 0:5:0","Item 0:5:1","Item 0:5:2","Item 0:5:3","Item 0:5:4","Item 0:5:5"
			]),
		]),
	]

}

extension ViewController: DSFBrowserViewDelegate {
	func browserView(_ browser: DSFBrowserView, numberOfRowsForColumn: Int) -> Int {
		if numberOfRowsForColumn == 0 {
			return data.count
		}
		else if numberOfRowsForColumn == 1 {
			return data[0].1.count
		}
		else {
			return data[0].1[0].1.count
		}
	}

	func browserView(_ browser: DSFBrowserView, viewForRow row: Int, inColumn column: Int) -> NSView? {
		let title: String = {
			if column == 0 {
				return data[row].0
			}
			else if column == 1 {
				return data[row].1[column].0
			}
			else {
				return data[0].1[0].1.count
			}
		}()



		let body =
			VStack(spacing: 2, alignment: .leading, distribution: .fillProportionally) {
				Label("Title [\(column):\(row)]")
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

	func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [IndexSet]) {
		Swift.print("Did select [\(selections)]")
	}

	func browserView(_ browser: DSFBrowserView, pasteboardWriterForRow row: Int, column: Int) -> NSPasteboardWriting? {
		Swift.print("Attempt to drag row \(row) col \(column)")

		let item = NSPasteboardItem()
		item.setString(String("\(row)-\(column)"), forType: .string)
		return item

		//return nil
	}
}
