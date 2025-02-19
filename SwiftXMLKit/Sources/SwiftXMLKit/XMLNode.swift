//
//  XMLNode.swift
//  SwiftXMLKit
//
//  Created by 刘洪宝 on 2025/2/19.
//

import Foundation
import libxml2

public class XMLNode {
    internal var nodePtr: xmlNodePtr?
    internal weak var document: XMLDocument?
    
    public enum NodeType {
        case element
        case attribute
        case text
        case cdata
        case entityReference
        case entity
        case processingInstruction
        case comment
        case document
        case documentType
        case documentFragment
        case notation
        case dtd
        case elementDeclaration
        case attributeDeclaration
        case unknown
        
        internal init(xmlType: xmlElementType) {
            switch xmlType {
            case XML_ELEMENT_NODE: self = .element
            case XML_ATTRIBUTE_NODE: self = .attribute
            case XML_TEXT_NODE: self = .text
            case XML_CDATA_SECTION_NODE: self = .cdata
            case XML_ENTITY_REF_NODE: self = .entityReference
            case XML_ENTITY_NODE: self = .entity
            case XML_PI_NODE: self = .processingInstruction
            case XML_COMMENT_NODE: self = .comment
            case XML_DOCUMENT_NODE: self = .document
            case XML_DOCUMENT_TYPE_NODE: self = .documentType
            case XML_DOCUMENT_FRAG_NODE: self = .documentFragment
            case XML_NOTATION_NODE: self = .notation
            case XML_DTD_NODE: self = .dtd
            case XML_ELEMENT_DECL: self = .elementDeclaration
            case XML_ATTRIBUTE_DECL: self = .attributeDeclaration
            default: self = .unknown
            }
        }
    }
    
    public var nodeType: NodeType {
        guard let nodePtr = nodePtr else { return .unknown }
        return NodeType(xmlType: nodePtr.pointee.type)
    }
    
    public var name: String? {
        guard let nodePtr = nodePtr else { return nil }
        return String(cString: nodePtr.pointee.name)
    }
    
    public var stringValue: String? {
        guard let nodePtr = nodePtr else { return nil }
        let content = xmlNodeGetContent(nodePtr)
        defer { xmlFree(content) }
        guard let content = content else { return nil }
        return String(cString: content)
    }
    
    internal init(nodePtr: xmlNodePtr?, document: XMLDocument?) {
        self.nodePtr = nodePtr
        self.document = document
    }
    
    deinit {
        // Note: We don't free the node here as it's managed by the document
    }
    
    public var parent: XMLNode? {
        guard let nodePtr = nodePtr,
              let parentPtr = nodePtr.pointee.parent else { return nil }
        return XMLNode(nodePtr: parentPtr, document: document)
    }
    
    public var children: [XMLNode] {
        var result: [XMLNode] = []
        guard let nodePtr = nodePtr,
              let child = nodePtr.pointee.children else { return result }
        
        var currentNode: xmlNodePtr? = child
        while let node = currentNode {
            result.append(XMLNode(nodePtr: node, document: document))
            currentNode = node.pointee.next
        }
        
        return result
    }
    
    public var nextSibling: XMLNode? {
        guard let nodePtr = nodePtr,
              let next = nodePtr.pointee.next else { return nil }
        return XMLNode(nodePtr: next, document: document)
    }
    
    public var previousSibling: XMLNode? {
        guard let nodePtr = nodePtr,
              let prev = nodePtr.pointee.prev else { return nil }
        return XMLNode(nodePtr: prev, document: document)
    }
}

// MARK: - CustomStringConvertible
//extension XMLNode: CustomStringConvertible {
//    public var description: String {
//        return "\(type(of: self))(name: \(name ?? "nil"), type: \(nodeType), value: \(stringValue ?? "nil"))"
//    }
//} 
