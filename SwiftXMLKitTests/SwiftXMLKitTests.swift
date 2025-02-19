//
//  SwiftXMLKitTests.swift
//  SwiftXMLKitTests
//
//  Created by 刘洪宝 on 2025/2/19.
//

import XCTest
@testable import SwiftXMLKit

final class SwiftXMLKitTests: XCTestCase {
    func testBasicXMLCreation() throws {
        let doc = XMLDocument()
        let root = XMLElement(name: "root")
        doc.setRootElement(root)
        
        let child = XMLElement(name: "child", stringValue: "Hello World")
        child.setAttribute("id", forName: "1")
        root.addChild(child)
        
        let xmlString = try doc.xmlString()
        XCTAssertTrue(xmlString.contains("<root>"))
        XCTAssertTrue(xmlString.contains("<child 1=\"id\">Hello World</child>"))
    }
    
    func testXMLParsing() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <root>
            <child id="1">Hello</child>
            <child id="2">World</child>
        </root>
        """
        
        let doc = try XMLDocument(xmlString: xmlString)
        let root = doc.rootElement
        XCTAssertNotNil(root)
        XCTAssertEqual(root?.name, "root")
        
        let children = root?.elements(forName: "child")
        XCTAssertEqual(children?.count, 2)
        XCTAssertEqual(children?[0].attribute(forName: "id"), "1")
        XCTAssertEqual(children?[0].stringValue, "Hello")
        XCTAssertEqual(children?[1].attribute(forName: "id"), "2")
        XCTAssertEqual(children?[1].stringValue, "World")
    }
    
    func testXPath() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <bookstore>
            <book category="fiction">
                <title>Swift</title>
                <author>Apple</author>
                <price>29.99</price>
            </book>
            <book category="non-fiction">
                <title>Objectiv-C</title>
                <author>Apple</author>
                <price>39.99</price>
            </book>
        </bookstore>
        """
        
        let doc = try XMLDocument(xmlString: xmlString)
        
        // Test finding all books
        let books = try doc.nodes(forXPath: "//book")
        XCTAssertEqual(books.count, 2)
        XCTAssertTrue(books[0] is XMLElement)
        
        // Test finding fiction books
        let fictionBooks = try doc.nodes(forXPath: "//book[@category='fiction']")
        XCTAssertEqual(fictionBooks.count, 1)
        
        guard let fictionBook = fictionBooks[0] as? XMLElement else {
            XCTFail("Expected XMLElement for book node")
            return
        }
        
        let titles = fictionBook.elements(forName: "title")
        XCTAssertEqual(titles.count, 1, "Expected exactly one title element")
        
        guard let title = titles.first else {
            XCTFail("No title element found")
            return
        }
        
        XCTAssertEqual(title.stringValue, "Swift")
        
        // Test finding all prices
        let prices = try doc.nodes(forXPath: "//price")
        XCTAssertEqual(prices.count, 2)
        XCTAssertEqual(prices[0].stringValue, "29.99")
        XCTAssertEqual(prices[1].stringValue, "39.99")
    }
    
    func testNodeManipulation() throws {
        let doc = XMLDocument()
        let root = XMLElement(name: "root")
        doc.setRootElement(root)
        
        // Add children
        let child1 = XMLElement(name: "child")
        child1.setAttribute("1", forName: "id")
        root.addChild(child1)
        
        let child2 = XMLElement(name: "child")
        child2.setAttribute("2", forName: "id")
        root.addChild(child2)
        
        // Test removal
        child1.removeFromParent()
        
        let remainingChildren = root.elements(forName: "child")
        XCTAssertEqual(remainingChildren.count, 1)
        XCTAssertEqual(remainingChildren[0].attribute(forName: "id"), "2")
    }
}
