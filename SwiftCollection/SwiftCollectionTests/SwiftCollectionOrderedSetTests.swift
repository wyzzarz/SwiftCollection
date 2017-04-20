//
//  SwiftCollectionOrderedSetTests.swift
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

class SwiftCollectionOrderedSetTests: XCTestCase {
  
  // documents
  let docNone = SCDocument(id: 0x0)
  let docA = SCDocument(id: 0x1)
  let docB = SCDocument(id: 0xA)
  let docC = SCDocument(id: 0xF)
  let docD = SCDocument(id: 0xFF)

  // persisted sets
  final class PersistedSet: SCOrderedSet<SCDocument> {
    
    override func load(jsonObject json: AnyObject) throws -> AnyObject? {
      if let array = json as? [AnyObject] {
        for item in array {
          try? append(SCDocument(json: item))
        }
      }
      return json
    }
    
  }
  var set1 = PersistedSet()
  var set2 = PersistedSet()

  
  // delegate sets
  final class DelegateSet: SCOrderedSet<SCDocument> {
    var willCount: Int = 0
    var didCount: Int = 0
    var successes: Int = 0
    var failures: Int = 0
    func resetCounts() {
      willCount = 0
      didCount = 0
      successes = 0
      failures = 0
    }
    override func willInsert(_ document: Document, at index: Int) {
      willCount += 1
    }
    override func didInsert(_ document: Document, at index: Int, success: Bool) {
      didCount += 1
      if success { successes += 1 } else { failures += 1 }
    }
    override func willAppend(_ document: Document) {
      willCount += 1
    }
    override func didAppend(_ document: Document, success: Bool) {
      didCount += 1
      if success { successes += 1 } else { failures += 1 }
    }
    override func willRemove(_ document: Document) {
      willCount += 1
    }
    override func didRemove(_ document: Document, at index: Int, success: Bool) {
      didCount += 1
      if success { successes += 1 } else { failures += 1 }
    }
    override func willRemoveAll() {willCount += 1 }
    override func didRemoveAll() { didCount += 1 }
  }

  override func setUp() {
    super.setUp()
    set1.removeAll()
    set2.removeAll()
  }
  
  override func tearDown() {
    try? set1.remove(jsonStorage: .userDefaults, completion: nil)
    super.tearDown()
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document
   * -----------------------------------------------------------------------------------------------
   */

  func testCreateDocument() {
    let doc1 = try! set1.create()
    XCTAssertNotNil(doc1)
    XCTAssertGreaterThan(doc1.id, 0)
    XCTAssertThrowsError(try set1.create(withId: doc1.id))
    let doc2 = try! set1.create(withId: 2)
    XCTAssertEqual(doc2.id, 2)
  }
  
  func testRegisterDocument() {
    // register an empty document
    let doc1 = SCDocument()
    XCTAssertEqual(doc1.id, 0)
    try? set1.register(doc1)
    XCTAssertGreaterThan(doc1.id, 0)
    
    // register a document with an existing id
    let doc2 = SCDocument(id: doc1.id > 1000 ? 1000 : 1001)
    try? set1.register(doc2)
    
    // register a document with a hint for an existing id
    let doc3 = SCDocument()
    XCTAssertEqual(doc3.id, 0)
    try? set1.register(doc3, hint: doc2.id)
    XCTAssertNotEqual(doc3.id, doc2.id)
  }
  
  func testRegisterNonExistingHint() {
    // register an empty document
    let doc1 = SCDocument()
    try? set1.register(doc1)
    
    // register a document with a hint for a new id
    let id2: SwiftCollection.Id = doc1.id > 1000 ? 1000 : 1001
    let doc2 = SCDocument()
    try? set1.register(doc2, hint: id2)
    XCTAssertEqual(doc2.id, id2)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document Id
   * -----------------------------------------------------------------------------------------------
   */

  func testId() {
    try! set1.append(contentsOf: [docA, docB, docC])
    XCTAssertEqual(set1.firstId, docA.id)
    XCTAssertEqual(set1.id(after: set1.firstId), docB.id)
    XCTAssertEqual(set1.id(before: set1.lastId), docB.id)
    XCTAssertEqual(set1.lastId, docC.id)
    
  }

  func testContainsId() {
    try! set1.append(contentsOf: [docA, docB, docC])
    XCTAssertTrue(set1.contains(id: docA.id))
    XCTAssertFalse(set1.contains(id: docD.id))
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Sequence
   * -----------------------------------------------------------------------------------------------
   */
  
  func testSequence() {
    let arr = try! SCOrderedSet<SCDocument>([docA, docB, docC])
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
    let arr = try! SCOrderedSet<SCDocument>([docA, docB, docC])
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
    XCTAssertThrowsError(try set1.append(docNone))
  }

  func testAppendDocument() {
    try! set1.append(docA)
    try! set1.append(docB)
    XCTAssertEqual(set1.count, 2)
    XCTAssertEqual(set1.first, docA)
    XCTAssertEqual(set1.last, docB)
  }

  func testAppendDocuments() {
    try! set1.append(docA)
    try! set1.append(contentsOf: [docB, docC])
    XCTAssertEqual(set1.count, 3)
    XCTAssertEqual(set1.first, docA)
    XCTAssertEqual(set1[set1.index(set1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(set1.last, docC)
  }
  
  func testInsertDocument() {
    try! set1.insert(docC, at: 0)
    try! set1.insert(docB, at: 0)
    try! set1.insert(docA, at: 0)
    XCTAssertEqual(set1.count, 3)
    XCTAssertEqual(set1.first, docA)
    XCTAssertEqual(set1[set1.index(set1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(set1.last, docC)
  }
  
  func testInsertDocuments() {
    try! set1.insert(docC, at: 0)
    try! set2.insert(docB, at: 0)
    try! set2.insert(docA, at: 0)
    try! set1.insert(contentsOf: set2, at: 0)
    XCTAssertEqual(set1.count, 3)
    XCTAssertEqual(set2.count, 2)
    XCTAssertEqual(set1.first, docA)
    XCTAssertEqual(set1[set1.index(set1.startIndex, offsetBy: 1)], docB)
    XCTAssertEqual(set1.last, docC)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Remove
   * -----------------------------------------------------------------------------------------------
   */
  
  func testRemoveDocument() {
    let set = try! SCOrderedSet<SCDocument>([docA, docB, docC])
    XCTAssertEqual(set.count, 3)
    set.remove(docB)
    XCTAssertEqual(set.count, 2)
  }

  func testRemoveDocuments() {
    let set = try! SCOrderedSet<SCDocument>([docA, docB, docC])
    XCTAssertEqual(set.count, 3)
    set.remove(contentsOf: [docA, docC])
    XCTAssertEqual(set.count, 1)
    XCTAssertEqual(set.last, docB)
  }

  func testRemoveAllDocuments() {
    let set = try! SCOrderedSet<SCDocument>([docA, docB, docC])
    XCTAssertEqual(set.count, 3)
    set.removeAll()
    XCTAssertEqual(set.count, 0)
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Combine
   * -----------------------------------------------------------------------------------------------
   */

  func testUnion() {
    try! set1.append(contentsOf: [docA, docB, docC])
    try! set2.append(contentsOf: [docC, docD])
    let set = try! set1.union(set2)
    XCTAssertEqual(set.count, 4)
    XCTAssertEqual(set.first, docA)
    XCTAssertEqual(set.last, docD)
  }

  func testInterset() {
    try! set1.append(contentsOf: [docA, docB, docC])
    try! set2.append(contentsOf: [docC, docB, docD])
    set1.intersect(set2)
    XCTAssertEqual(set1.count, 2)
    XCTAssertEqual(set1.first, docB)
    XCTAssertEqual(set1.last, docC)
  }

  func testMinus() {
    try! set1.append(contentsOf: [docA, docB, docC])
    try! set2.append(contentsOf: [docC, docD])
    set1.minus(set2)
    XCTAssertEqual(set1.count, 2)
    XCTAssertEqual(set1.first, docA)
    XCTAssertEqual(set1.last, docB)
  }
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Delegate
   * -----------------------------------------------------------------------------------------------
   */

  func testInsertDelegate() {
    let set = DelegateSet()
    
    try! set.insert(docA, at: 0)
    XCTAssertEqual(set.willCount, 1)
    XCTAssertEqual(set.didCount, 1)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 0)
    
    try! set.insert(docA, at: 0)
    XCTAssertEqual(set.willCount, 2)
    XCTAssertEqual(set.didCount, 2)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 1)
  }

  func testAppendDelegate() {
    let set = DelegateSet()

    try! set.append(docA)
    XCTAssertEqual(set.willCount, 1)
    XCTAssertEqual(set.didCount, 1)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 0)

    try! set.append(docA)
    XCTAssertEqual(set.willCount, 2)
    XCTAssertEqual(set.didCount, 2)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 1)
  }
  
  func testRemoveDelegate() {
    let set = DelegateSet()

    try! set.append(contentsOf: [docA, docB, docC, docD])
    XCTAssertEqual(set.willCount, 4)
    XCTAssertEqual(set.didCount, 4)
    XCTAssertEqual(set.successes, 4)
    XCTAssertEqual(set.failures, 0)

    set.resetCounts()
    XCTAssertEqual(set.willCount, 0)
    XCTAssertEqual(set.didCount, 0)
    XCTAssertEqual(set.successes, 0)
    XCTAssertEqual(set.failures, 0)

    set.remove(docA)
    XCTAssertEqual(set.willCount, 1)
    XCTAssertEqual(set.didCount, 1)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 0)
    
    set.remove(docA)
    XCTAssertEqual(set.willCount, 2)
    XCTAssertEqual(set.didCount, 2)
    XCTAssertEqual(set.successes, 1)
    XCTAssertEqual(set.failures, 1)
  }
  
  func testRemoveAllDelegate() {
    let set = DelegateSet()
    
    try! set.append(contentsOf: [docA, docB, docC, docD])
    XCTAssertEqual(set.willCount, 4)
    XCTAssertEqual(set.didCount, 4)
    XCTAssertEqual(set.successes, 4)
    XCTAssertEqual(set.failures, 0)
    
    set.resetCounts()
    XCTAssertEqual(set.willCount, 0)
    XCTAssertEqual(set.didCount, 0)
    XCTAssertEqual(set.successes, 0)
    XCTAssertEqual(set.failures, 0)

    set.removeAll()
    XCTAssertEqual(set.willCount, 1)
    XCTAssertEqual(set.didCount, 1)
    XCTAssertEqual(set.successes, 0)
    XCTAssertEqual(set.failures, 0)
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Persistence
   * -----------------------------------------------------------------------------------------------
   */
  
  func testPersistence() {
    // create expectations
    let se = expectation(description: "Save Failed.")
    let le = self.expectation(description: "Load Failed.")
    
    try! set1.append(contentsOf: [docA, docB, docC])
    
    let load = {
      XCTAssertEqual(self.set2.count, 0)
      try! self.set2.load(jsonStorage: .userDefaults, completion: { (success, json) in
        le.fulfill()
        XCTAssertEqual(self.set2.count, 3)
        XCTAssertEqual(self.set2.first, self.docA)
        XCTAssertEqual(self.set2.last, self.docC)
      })
    }
    
    try! set1.save(jsonStorage: .userDefaults) { (success) in
      se.fulfill()
      XCTAssertTrue(success)
      if (success) {
        load()
      }
    }
    
    // wait for save and load
    waitForExpectations(timeout: 60) { (error) in
      if let error = error {
        XCTFail("Save Failed: \(error.localizedDescription)")
      }
    }
  }

}
