//
//  SwiftCollectionTests+Array.swift
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

import XCTest
@testable import SwiftCollection

class SwiftCollectionArrayTests: XCTestCase {
  
  // documents
  let docNone = SCDocument(id: 0x0)
  let docA = SCDocument(id: 0x1)
  let docB = SCDocument(id: 0xA)
  let docC = SCDocument(id: 0xF)

  // arrays
  var array1 = SCArray<SCDocument>()
  var array2 = SCArray<SCDocument>()

  override func setUp() {
    super.setUp()
    array1.removeAll()
    array2.removeAll()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document
   * -----------------------------------------------------------------------------------------------
   */

  func testCreateDocument() {
    let doc1 = try! array1.createDocument()
    XCTAssertNotNil(doc1)
    XCTAssertGreaterThan(doc1.id, 0)
    XCTAssertThrowsError(try array1.createDocument(withId: doc1.id))
    let doc2 = try! array1.createDocument(withId: 2)
    XCTAssertEqual(doc2.id, 2)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document Id
   * -----------------------------------------------------------------------------------------------
   */

  func testId() {
    try! array1.append(contentsOf: [docA, docB, docC])
    XCTAssertEqual(array1.firstId, docA.id)
    XCTAssertEqual(array1.id(after: array1.firstId), docB.id)
    XCTAssertEqual(array1.id(before: array1.lastId), docB.id)
    XCTAssertEqual(array1.lastId, docC.id)
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Sequence
   * -----------------------------------------------------------------------------------------------
   */
  
  func testSequence() {
    let arr = SCArray(arrayLiteral: docA, docB, docC)
    XCTAssertEqual(arr.count, 3)
    for (i, e) in arr.enumerated() {
      switch i {
      case 0: XCTAssertEqual(e, docA)
      case 1: XCTAssertEqual(e, docB)
      case 2: XCTAssertEqual(e, docC)
      default: break
      }
    }
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Collection
   * -----------------------------------------------------------------------------------------------
   */

  func testCollection() {
    let arr = SCArray(arrayLiteral: docA, docB, docC)
    XCTAssertEqual(arr[arr.startIndex], docA)
    XCTAssertEqual(arr[arr.index(arr.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(arr[arr.index(arr.startIndex, offsetBy: 2)], docC)
    XCTAssertEqual(arr[arr.index(arr.endIndex, offsetBy: -1)], docC)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Add
   * -----------------------------------------------------------------------------------------------
   */
  
  func testEmptyDocument() {
    XCTAssertThrowsError(try array1.append(document: docNone))
  }

  func testAppendDocument() {
    try! array1.append(document: docA)
    try! array1.append(document: docB)
    XCTAssertEqual(array1.count, 2)
    XCTAssertEqual(array1.first, docA)
    XCTAssertEqual(array1.last, docB)
  }

  func testAppendDocuments() {
    try! array1.append(document: docA)
    try! array1.append(contentsOf: [docB, docC])
    XCTAssertEqual(array1.count, 3)
    XCTAssertEqual(array1.first, docA)
    XCTAssertEqual(array1[array1.index(array1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(array1.last, docC)
  }
  
  func testInsertDocument() {
    try! array1.insert(document: docC, at: 0)
    try! array1.insert(document: docB, at: 0)
    try! array1.insert(document: docA, at: 0)
    XCTAssertEqual(array1.count, 3)
    XCTAssertEqual(array1.first, docA)
    XCTAssertEqual(array1[array1.index(array1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(array1.last, docC)
  }
  
  func testInsertDocuments() {
    try! array1.insert(document: docC, at: 0)
    try! array2.insert(document: docB, at: 0)
    try! array2.insert(document: docA, at: 0)
    try! array1.insert(contentsOf: array2, at: 0)
    XCTAssertEqual(array1.count, 3)
    XCTAssertEqual(array2.count, 2)
    XCTAssertEqual(array1.first, docA)
    XCTAssertEqual(array1[array1.index(array1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(array1.last, docC)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Remove
   * -----------------------------------------------------------------------------------------------
   */
  
  func testRemoveDocument() {
    let array = try! SCArray<SCDocument>([docA, docB, docC])
    XCTAssertEqual(array.count, 3)
    array.remove(document: docB)
    XCTAssertEqual(array.count, 2)
  }

  func testRemoveDocuments() {
    let array = try! SCArray<SCDocument>([docA, docB, docC])
    XCTAssertEqual(array.count, 3)
    array.remove(contentsOf: [docA, docC])
    XCTAssertEqual(array.count, 1)
    XCTAssertEqual(array.last, docB)
  }

  func testRemoveAllDocuments() {
    let array = try! SCArray<SCDocument>([docA, docB, docC])
    XCTAssertEqual(array.count, 3)
    array.removeAll()
    XCTAssertEqual(array.count, 0)
  }

}
