# DSFBrowserView

A modern-ish NSBrowser-style control allowing complex row views.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFBrowserView" />
    <img src="https://img.shields.io/badge/macOS-10.11+-red" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a>
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

<p align="center">
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFBrowserView/main.gif?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFBrowserView/main.gif?raw=true" alt="Swift Package Manager" width="400"/></a>
   </a>
</p>

## Why?

I use an NSBrowser for one of my apps and got frustrated with the limitations of what could be displayed within the browser columns.  Well, you CAN tweak the output BUT you have to do a lot of your own drawing code in a custom NSCell. Boo!

This implementation follows the model of the modern NSTableView, using `NSView`s to display browser cells and allowing the user to customise the cell views depending on need.

## Installation

Use Swift Package Manager.

Add `https://github.com/dagronf/DSFBrowserView` to your project.

## Usage

You can find a basic demo in the `Demos` subfolder.

### Creation

The basic behaviour of the control is similar to NSBrowser. Assign a delegate and provide the data when asked.

```swift
let browserView = DSFBrowserView()  // Or load from XIB

// Add columns to the browser
browserView.addColumn("Heading 1", allowMultipleSelection: false, allowEmptySelection: true)
browserView.addColumn("Heading 2", allowMultipleSelection: false, allowEmptySelection: true)
browserView.addColumn("Heading 3", allowMultipleSelection: true, allowEmptySelection: true)

// Some additional visual stuff...
browserView.autohidesScrollers = true
browserView.hideSeparators = false

// And tell the browser to update itself
browserView.reloadData()
```

### Providing data to the control

The delegate is asked for content to display in the control.

#### Data Source

```swift
func rootItem(for browser: DSFBrowserView) -> Any?
```

Return the root element of the browser view. This might be an array of objects (for example)

```swift
func browserView(_ browser: DSFBrowserView, numberOfChildrenOfItem item: Any?) -> Int
```

Return the number of children for `item`.

```swift
func browserView(_ browser: DSFBrowserView, child index: Int, ofItem item: Any?) -> Any
```

Return the child item at index `index` for `item`.

```swift
func browserView(_ browser: DSFBrowserView, viewForItem item: Any?, column: Int, row: Int) -> NSView?
```

Return a view that represents `item`.  Row and column are provided for informational purposes only.

#### Delegate

```swift
func browserView(_ browser: DSFBrowserView, selectionDidChange selections: [[Any]])
```

Called when the selection changes within the control. 

```swift
func browserView(_ browser: DSFBrowserView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting?
```
Called when the user starts to drag an item within a column. Return `nil` to cancel the drag

#### Legacy (10.12 and earlier)

```swift
func browserView(_ browser: DSFBrowserView, heightOfViewForItem item: Any?) -> CGFloat
```

If you are targeting 10.12 or earlier, AutoLayout isn't supported for table view cells. You will need to provide a height to use for the view being displayed for `item`.

## Screenshots

<p align="center">
   <a href="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFBrowserView/moviedb.jpg?raw=true">
      <img src="https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFBrowserView/moviedb.jpg?raw=true" alt="Swift Package Manager" width="700"/></a>
   </a>
</p>

# License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
