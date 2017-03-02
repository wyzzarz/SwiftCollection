//
//  SCArray.swift
//
//  Copyright 2017 Warner Zee
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// `SCArray` holds document objects conforming to `SCDocumentProtocol`.
///
/// Documents added to this collection include a primary key.
///
/// The collection automatically arranges elements by the sort keys.
///
public struct SCArray<Element: SCDocumentProtocol> {

  // Holds an array of elements.
  fileprivate var elements: [Element] = []

  // Holds an array of ids that corresponds to each element in elements.
  fileprivate var ids: [SwiftCollection.Id] = []
 
  // Temporarily holds a set of ids for elements that have been created, but have not been added to 
  // elements.
  fileprivate var createdIds: Set<SwiftCollection.Id> = []

  
  /// Creates an instance of `SCArray`.
  public init() {
    // nothing to do
  }
  
  /// Creates an instance of `SCArray` populated by documents in the collection.
  ///
  /// - Parameter collection: Documents to be added.
  /// - Throws: `missingId` if a document has no id.
  public init<C: Collection>(_ collection: C) throws where C.Iterator.Element == Element {
    for element in collection {
      try append(document: element)
    }
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document
   * -----------------------------------------------------------------------------------------------
   */
  
  /// Creates a document stub with a valid id.  The id will be randomly generated and unique for
  /// documents in the collection.
  ///
  /// The document will not be added to the collection.  It can be added later once the details
  /// have been updated.
  ///
  /// - Parameter id: Optional id to be applied to the document.
  /// - Returns: A document that can be added to the collection.
  /// - Throws: `existingId` if a document has no id.  `generateId` if an id could not be generated.
  public mutating func createDocument(withId id: SwiftCollection.Id? = nil) throws -> Element {
    let existing = Set<SwiftCollection.Id>(ids).union(Set<SwiftCollection.Id>(createdIds))
    var theId = id
    if theId != nil {
      // check if this id already exists
      if existing.contains(theId!) { throw SwiftCollection.Errors.existingId }
    } else {
      // get a new id
      var i: Int = Int.max / 10
      repeat {
        let r = SwiftCollection.Id.random()
        if !existing.contains(r) {
          theId = r
          break
        }
        i -= 1
      } while i > 0
    }
    guard theId != nil else { throw SwiftCollection.Errors.generateId }
    
    // remember this id until the document is stored in this collection
    self.createdIds.insert(theId!)
    
    // done
    return Element(id: theId!)
  }
  
  /// Returns the last document from the collection.
  public var last: Iterator.Element? {
    return elements.last
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document Id
   * -----------------------------------------------------------------------------------------------
   */
  
  /// Returns a document from the collection.
  ///
  /// - Parameter id: `id` of document to return.
  /// - Returns: A document with the specified id.
  public func document(withId id: SwiftCollection.Id?) -> Element? {
    guard let id = id else { return nil }
    guard let i = ids.index(of: id) else { return nil }
    return elements[i]
  }
  
  /// Returns the first document id in the collection.
  public var firstId: SwiftCollection.Id? {
    return ids.first
  }
  
  /// Returns the last document id in the collection.
  public var lastId: SwiftCollection.Id? {
    return ids.last
  }
  
  /// The next document id in the collection after the specified id.
  ///
  /// - Parameter id: `id` of document to be located.
  /// - Returns: `id` of next document.  Or `nil` if this is the last document.
  public func id(after id: SwiftCollection.Id?) -> SwiftCollection.Id? {
    guard let id = id else { return nil }
    guard let i = ids.index(of: id) else { return nil }
    let ni = ids.index(after: i)
    return ni < ids.count ? ids[ni] : nil
  }

  /// The previous document id in the collection before the specified id.
  ///
  /// - Parameter id: `id` of document to be located.
  /// - Returns: `id` of previous document.  Or `nil` if this is the first document.
  public func id(before id: SwiftCollection.Id?) -> SwiftCollection.Id? {
    guard let id = id else { return nil }
    guard let i = ids.index(of: id) else { return nil }
    let pi = ids.index(before: i)
    return pi >= 0 ? ids[pi] : nil
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Add
   * -----------------------------------------------------------------------------------------------
   */
  
  /// Adds the document to the collection at the specified index.  Existing documents are ignored.
  ///
  /// - Parameters:
  ///   - document: Document to be added.
  ///   - i: Position to insert the document.  `i` must be a valid index into the collection.
  /// - Throws: `missingId` if the document has no id.
  mutating func insert(document: Element, at i: Int) throws {
    // ensure the document has an id
    guard document.hasId() else { throw SwiftCollection.Errors.missingId }
    guard !ids.contains(document.id) else { return }
    elements.insert(document, at: i)
    ids.insert(document.id, at: i)
    createdIds.remove(document.id)
  }
  
  /// Adds the documents to the end of the collection.
  ///
  /// - Parameters:
  ///   - newDocuments: Documents to be added.
  ///   - i: Position to insert the documents.  `i` must be a valid index into the collection.
  /// - Throws: `missingId` if a document has no id.
  mutating func insert<C : Collection>(contentsOf newDocuments: C, at i: Int) throws where C.Iterator.Element == Element {
    let newTotal = ids.count + Int(newDocuments.count.toIntMax())
    elements.reserveCapacity(newTotal)
    ids.reserveCapacity(newTotal)
    for d in newDocuments.reversed() {
      try self.insert(document: d, at: i)
    }
  }

  
  /// Adds the document to the end of the collection.
  ///
  /// - Parameter document: Document to be added.
  /// - Throws: `missingId` if the document has no id.
  public mutating func append(document: Element) throws {
    // ensure the document has an id
    guard document.hasId() else { throw SwiftCollection.Errors.missingId }
    guard !ids.contains(document.id) else { return }
    elements.append(document)
    ids.append(document.id)
    createdIds.remove(document.id)
  }
  
  /// Adds documents to the end of the collection.  Existing documents are ignored.
  ///
  /// - Parameter newDocuments: A collection of documents to be added.
  /// - Throws: `missingId` if a document has no id.
  public mutating func append<C : Collection>(contentsOf newDocuments: C) throws where C.Iterator.Element == Element {
    let newTotal = ids.count + Int(newDocuments.count.toIntMax())
    elements.reserveCapacity(newTotal)
    ids.reserveCapacity(newTotal)
    for d in newDocuments {
      if ids.contains(d.id) { continue }
      try self.append(document: d)
    }
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Remove
   * -----------------------------------------------------------------------------------------------
   */

  /// Removes the document from the collection.
  ///
  /// - Parameter document: Document to be removed.
  public mutating func remove(document: Element) {
    if let i = index(of: document) {
      elements.remove(at: i.index)
      ids.remove(at: i.index)
    }
    createdIds.remove(document.id)
  }
 
  /// Removes documents from the collection.
  ///
  /// - Parameter newDocuments: A collection of documents to be removed.
  /// - Throws: `missingId` if a document has no id.
  public mutating func remove<C : Collection>(contentsOf newDocuments: C) where C.Iterator.Element == Element {
    for d in newDocuments {
      if let i = index(of: d) {
        elements.remove(at: i.index)
        ids.remove(at: i.index)
        createdIds.remove(d.id)
      }
    }
  }

  /// Removes all documents from the collection.
  public mutating func removeAll() {
    elements.removeAll()
    ids.removeAll()
    createdIds.removeAll()
  }

}

extension SCArray: CustomStringConvertible {
  
  public var description: String {
    return String(describing: ids)
  }
  
}

extension SCArray: ExpressibleByArrayLiteral {

  public init(arrayLiteral elements: Element...) {
    self.init()
    try? append(contentsOf: elements)
  }
  
}

/*
 * -----------------------------------------------------------------------------------------------
 * MARK: - Sequence
 * -----------------------------------------------------------------------------------------------
 */

extension SCArray: Sequence {

  public typealias Iterator = AnyIterator<Element>
  
  public func makeIterator() -> Iterator {
    var iterator = elements.makeIterator()
    return AnyIterator { return iterator.next() }
  }
}

/*
 * -----------------------------------------------------------------------------------------------
 * MARK: - Collection
 * -----------------------------------------------------------------------------------------------
 */

public struct SCArrayIndex<Element: Hashable>: Comparable {
  
  fileprivate let index: Int
  
  fileprivate init(_ index: Int) {
    self.index = index
  }
  
  public static func == (lhs: SCArrayIndex, rhs: SCArrayIndex) -> Bool {
    return lhs.index == rhs.index
  }
  
  public static func < (lhs: SCArrayIndex, rhs: SCArrayIndex) -> Bool {
    return lhs.index < rhs.index
  }
  
}

extension SCArray: BidirectionalCollection {

  public typealias Index = SCArrayIndex<Element>
  
  public var startIndex: Index {
    return SCArrayIndex(elements.startIndex)
  }
  
  public var endIndex: Index {
    return SCArrayIndex(elements.endIndex)
  }
  
  public func index(after i: Index) -> Index {
    return Index(elements.index(after: i.index))
  }

  public func index(before i: Index) -> Index {
    return Index(elements.index(before: i.index))
  }

  public subscript (position: Index) -> Iterator.Element {
    return elements[position.index]
  }
  
}
