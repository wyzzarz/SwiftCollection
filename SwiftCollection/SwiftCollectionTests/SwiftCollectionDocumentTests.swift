//
//  SwiftCollectionTests+Document.swift
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

class SwiftCollectionDocumentTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Document
   * -----------------------------------------------------------------------------------------------
   */
  
  func testGuid() {
    XCTAssertEqual(SCDocument(id: 0x1).guid, "0000-0000-0000-0001")
    XCTAssertEqual(SCDocument(id: 0x10000).guid, "0000-0000-0001-0000")
    XCTAssertEqual(SCDocument(id: 0x100000000).guid, "0000-0001-0000-0000")
    XCTAssertEqual(SCDocument(id: 0x1000000000000).guid, "0001-0000-0000-0000")
    XCTAssertEqual(SCDocument(id: UInt.max).guid, "FFFF-FFFF-FFFF-FFFF")
    XCTAssertEqual(SCDocument(id: 0x1234567890abcdef).guid, "1234-5678-90AB-CDEF")
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

    let doc = SCDocument(id: 0x10000)
    defer {
      try? doc.remove(jsonStorage: .userDefaults, completion: nil)
    }
    
    let load = {
      let loaded = SCDocument()
      try! loaded.load(jsonStorage: .userDefaults, completion: { (success, json) in
        le.fulfill()
        XCTAssertEqual(doc.id, loaded.id)
      })
    }
    
    try! doc.save(jsonStorage: .userDefaults) { (success) in
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
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Notifications
   * -----------------------------------------------------------------------------------------------
   */
  
  class NotificationDocument: SCDocument {
    
    var a: String = "a"
    var b: String = "b"

    func update(dict: [String: String]) {
      var changes = Changes(self)
      for (k, v) in dict {
        switch k {
        case "a":
          changes.add(SwiftCollection.Notifications.Change(k, oldValue: a, newValue: v))
          a = v
        case "b":
          changes.add(SwiftCollection.Notifications.Change(k, oldValue: b, newValue: v))
          b = v
        default: break
        }
      }
      changes.post()
    }
    
  }
  
  func testNotifications() {
    let doc = NotificationDocument()
    
    var properties: [String: String] = ["a": "a1", "b": "b2"]
    expectation(forNotification: SwiftCollection.Notifications.didChange.notification.rawValue, object: nil) { (n) -> Bool in
      guard doc == n.object as? SCDocument else { return false }
      guard let changes = n.userInfo?[SwiftCollection.Notifications.Keys.updated] as? [SwiftCollection.Notifications.Change] else { return false }
      for change in changes {
        guard let property = change.property else { continue }
        guard let oldValue = change.oldValue as? String else { continue }
        guard let newValue = change.newValue as? String else { continue }
        if property == oldValue && properties[property] == newValue { properties.removeValue(forKey: property) }
      }
      return properties.count == 0
    }

    doc.update(dict: ["a": "a1", "b": "b2"])
    
    waitForExpectations(timeout: 60) { (error) in
      guard error == nil else { XCTFail(error!.localizedDescription); return }
    }
  }

}
