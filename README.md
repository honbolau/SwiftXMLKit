# SwiftXMLKit

SwiftXMLKit is a lightweight XML parsing and manipulation framework for Swift, inspired by KissXML. It provides a simple and intuitive API for working with XML documents while leveraging the power and efficiency of libxml2.

## Features

- Simple and intuitive API
- Based on libxml2 for performance
- Support for XML parsing and creation
- XPath query support
- XML node manipulation
- Namespace support
- Memory management handled automatically

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add SwiftXMLKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/honbolau/SwiftXMLKit", from: "1.0.0")
]
```

## Usage

### Creating XML Documents

```swift
// Create a new document
let doc = XMLDocument()
let root = XMLElement(name: "root")
doc.setRootElement(root)

// Add child elements
let child = XMLElement(name: "child", stringValue: "Hello World")
child.setAttribute("id", forName: "1")
root.addChild(child)

// Convert to string
let xmlString = try doc.xmlString()
```

### Parsing XML

```swift
let xmlString = """
<?xml version="1.0" encoding="UTF-8"?>
<root>
    <child id="1">Hello</child>
    <child id="2">World</child>
</root>
"""

let doc = try XMLDocument(xmlString: xmlString)
let root = doc.rootElement

// Access children
let children = root?.elements(forName: "child")
let firstChild = children?[0]
let id = firstChild?.attribute(forName: "id")
let value = firstChild?.stringValue
```

### Using XPath

```swift
let doc = try XMLDocument(xmlString: xmlString)

// Find all elements with a specific tag
let elements = try doc.nodes(forXPath: "//tagname")

// Find elements with specific attributes
let filtered = try doc.nodes(forXPath: "//element[@attribute='value']")

// Complex queries
let results = try doc.nodes(forXPath: "//book[author='John Doe']/title")
```

### Modifying Documents

```swift
// Add new elements
let newElement = XMLElement(name: "new")
root.addChild(newElement)

// Set attributes
newElement.setAttribute("key", forName: "value")

// Remove elements
newElement.removeFromParent()

// Modify content
newElement.addText("New content")
```

## Thread Safety

SwiftXMLKit is not thread-safe by default. If you need to use it across multiple threads, make sure to implement proper synchronization.

## Memory Management

SwiftXMLKit handles memory management of the underlying libxml2 objects automatically. You don't need to worry about manually freeing memory.

## License

SwiftXMLKit is available under the MIT license. 
