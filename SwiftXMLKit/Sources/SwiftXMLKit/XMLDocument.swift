//
//  XMLDocument.swift
//  SwiftXMLKit
//
//  Created by 刘洪宝 on 2025/2/19.
//

import Foundation
import libxml2

public class XMLDocument {
    internal var docPtr: xmlDocPtr?
    
    public enum Error: Swift.Error {
        case parsingFailed
        case invalidXMLString
        case invalidXMLData
        case serializationFailed
    }
    
    public init() {
        docPtr = xmlNewDoc("1.0")
    }
    
    public convenience init(xmlString: String) throws {
        self.init()
        try parse(xmlString: xmlString)
    }
    
    public convenience init(data: Data) throws {
        self.init()
        try parse(data: data)
    }
    
    deinit {
        if let docPtr = docPtr {
            xmlFreeDoc(docPtr)
        }
    }
    
    // MARK: - Parsing
    
    private func parse(xmlString: String) throws {
        guard let data = xmlString.data(using: .utf8) else {
            throw Error.invalidXMLString
        }
        try parse(data: data)
    }
    
    private func parse(data: Data) throws {
        // Free existing document if any
        if let oldDoc = docPtr {
            xmlFreeDoc(oldDoc)
            docPtr = nil
        }
        
        // Parse the new document
        docPtr = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> xmlDocPtr? in
            guard let baseAddress = ptr.baseAddress else { return nil }
            return xmlReadMemory(
                baseAddress.assumingMemoryBound(to: Int8.self),
                Int32(data.count),
                nil,
                nil,
                Int32(XML_PARSE_RECOVER.rawValue | XML_PARSE_NOBLANKS.rawValue)
            )
        }
        
        guard docPtr != nil else {
            throw Error.parsingFailed
        }
    }
    
    // MARK: - Document Properties
    
    public var rootElement: XMLElement? {
        guard let docPtr = docPtr,
              let rootPtr = xmlDocGetRootElement(docPtr) else { return nil }
        return XMLElement(nodePtr: rootPtr, document: self)
    }
    
    public func setRootElement(_ element: XMLElement) {
        guard let docPtr = docPtr,
              let nodePtr = element.nodePtr else { return }
        xmlDocSetRootElement(docPtr, nodePtr)
    }
    
    // MARK: - Serialization
    
    public func xmlString(options: Int32 = 0) throws -> String {
        guard let docPtr = docPtr else {
            throw Error.serializationFailed
        }
        
        var bufferPtr: UnsafeMutablePointer<xmlChar>?
        var bufferSize: Int32 = 0
        
        xmlDocDumpFormatMemoryEnc(docPtr, &bufferPtr, &bufferSize, "UTF-8", 1)
        
        guard let buffer = bufferPtr else {
            throw Error.serializationFailed
        }
        
        defer { xmlFree(buffer) }
        
        guard let result = String(bytes: UnsafeBufferPointer(start: buffer, count: Int(bufferSize)),
                                encoding: .utf8) else {
            throw Error.serializationFailed
        }
        
        return result
    }
    
    // MARK: - XPath Support
    
    public func nodes(forXPath xpath: String) throws -> [XMLNode] {
        guard let docPtr = docPtr else { return [] }
        
        let context = xmlXPathNewContext(docPtr)
        defer { xmlXPathFreeContext(context) }
        
        guard let xpathObj = xmlXPathEvalExpression(xpath, context) else {
            return []
        }
        defer { xmlXPathFreeObject(xpathObj) }
        
        guard let nodeSet = xpathObj.pointee.nodesetval else {
            return []
        }
        
        var result: [XMLNode] = []
        let nodeCount = Int(nodeSet.pointee.nodeNr)
        
        if let nodeTab = nodeSet.pointee.nodeTab {
                    for i in 0..<nodeCount {
                        if let node = nodeTab[i] {
                            // Create the appropriate node type based on the node type
                            if node.pointee.type == XML_ELEMENT_NODE {
                                result.append(XMLElement(nodePtr: node, document: self))
                            } else {
                                result.append(XMLNode(nodePtr: node, document: self))
                            }
                        }
                    }
                }
        
        return result
    }
} 
