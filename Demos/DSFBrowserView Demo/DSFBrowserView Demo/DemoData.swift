//
//  DemoData.swift
//  DemoData
//
//  Created by Darren Ford on 17/8/21.
//

import Foundation

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
