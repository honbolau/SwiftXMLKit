//
//  XMLElement.swift
//  SwiftXMLKit
//
//  Created by 刘洪宝 on 2025/2/19.
//

import Foundation
import libxml2

public class XMLElement: XMLNode {
    public override var nodeType: NodeType {
        return .element
    }
    
    // MARK: - Attributes
    
    public func attribute(forName name: String) -> String? {
        guard let nodePtr = nodePtr,
              let attr = xmlGetProp(nodePtr, name) else { return nil }
        defer { xmlFree(attr) }
        return String(cString: attr)
    }
    
    public func setAttribute(_ value: String, forName name: String) {
        guard let nodePtr = nodePtr else { return }
        xmlSetProp(nodePtr, name, value)
    }
    
    public func removeAttribute(forName name: String) {
        guard let nodePtr = nodePtr else { return }
        xmlUnsetProp(nodePtr, name)
    }
    
    public var attributes: [String: String] {
        var result: [String: String] = [:]
        guard let nodePtr = nodePtr else { return result }
        
        var attr = nodePtr.pointee.properties
        while let currentAttr = attr {
            if let name = currentAttr.pointee.name {
                let nameStr = String(cString: name)
                if let value = xmlGetProp(nodePtr, name) {
                    result[nameStr] = String(cString: value)
                    xmlFree(value)
                }
            }
            attr = currentAttr.pointee.next
        }
        
        return result
    }
    
    // MARK: - Child Elements
    
    public func addChild(_ element: XMLElement) {
        guard let nodePtr = nodePtr,
              let childPtr = element.nodePtr else { return }
        xmlAddChild(nodePtr, childPtr)
    }
    
    public func removeFromParent() {
        guard let nodePtr = nodePtr else { return }
        xmlUnlinkNode(nodePtr)
    }
    
    public func elements(forName name: String) -> [XMLElement] {
        var result: [XMLElement] = []
        guard let nodePtr = nodePtr,
              let child = nodePtr.pointee.children else { return result }
        
        var currentNode: xmlNodePtr? = child
        while let node = currentNode {
            if node.pointee.type == XML_ELEMENT_NODE,
               let nodeName = node.pointee.name,
               String(cString: nodeName) == name {
                result.append(XMLElement(nodePtr: node, document: document))
            }
            currentNode = node.pointee.next
        }
        
        return result
    }
    
    // MARK: - Element Creation
    
    public func addChild(name: String) -> XMLElement {
        guard let nodePtr = nodePtr,
              let newNode = xmlNewChild(nodePtr, nil, name, nil) else {
            fatalError("Failed to create new child element")
        }
        return XMLElement(nodePtr: newNode, document: document)
    }
    
    public func addText(_ text: String) {
        guard let nodePtr = nodePtr else { return }
        xmlNodeAddContent(nodePtr, text)
    }
}

// MARK: - Convenience Initializers
extension XMLElement {
    public convenience init(name: String) {
        let nodePtr = xmlNewNode(nil, name)
        self.init(nodePtr: nodePtr, document: nil)
    }
    
    public convenience init(name: String, stringValue: String) {
        self.init(name: name)
        self.addText(stringValue)
    }
} 
