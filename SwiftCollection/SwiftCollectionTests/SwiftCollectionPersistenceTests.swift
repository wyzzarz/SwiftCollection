//
//  SwiftCollectionTests+Persistence.swift
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

class SwiftCollectionPersistenceTests: XCTestCase {

  let strKey = "str"
  let strValue = "string"

  let numKey = "num"
  let numValue = 11.1
  
  let arrKey = "arr"
  let arrValue = ["a", "b", "c"]
  
  let dictKey = "dict"
  let dictValue: [String: Any] = ["A": "a", "B": 10.1, "C": 88, "D": true, "E": false]

  let setKey = "set"
  let setValue = Set(["d", "e", "f"])
  
  let tupleKey = "tuple"
  let tupleValue = ("g", "h", "i")
  let tupleAsArray = ["g", "h", "i"]
  
  let nullKey = "null"
  let nullValue: AnyObject = NSNull()

  let anotherEnumKey = "anotherEnum"
  enum anotherEnum {
    case a
    case b
    case c
  }
  let anotherEnumValue: anotherEnum = .b

  let anotherEnumStringKey = "anotherEnumString"
  enum anotherEnumString: String {
    case a
    case b
    case c
  }
  let anotherEnumStringValue: anotherEnumString = .b
  let anotherEnumStringRawValue = (.b as anotherEnumString).rawValue

  let anotherEnumNumberKey = "anotherEnumNumber"
  enum anotherEnumNumber: Float {
    case a
    case b
    case c
  }
  let anotherEnumNumberValue: anotherEnumNumber = .b
  let anotherEnumNumberRawValue = (.b as anotherEnumNumber).rawValue
  
  let anotherOptionSetKey = "anotherOptionSet"
  struct AnotherOptionSet: OptionSet {
    let rawValue: Int
    static let first      = AnotherOptionSet(rawValue: 1 << 0)
    static let second     = AnotherOptionSet(rawValue: 1 << 1)
    static let third      = AnotherOptionSet(rawValue: 1 << 2)
    static let fourth     = AnotherOptionSet(rawValue: 1 << 3)
  }
  let anotherOptionSetValue: AnotherOptionSet = [.first, .third]
  let anotherOptionSetAsDictionary: [String: Int] = ["rawValue": 5]

  let anotherStructKey = "anotherStruct"
  struct AnotherStruct {
    let a = "1"
    let b = "2"
  }
  let anotherStructAsDictionary = ["a": "1", "b": "2"]

  let anotherClassKey = "anotherClass"
  class AnotherClass {
    let c = 3
    let d = "4"
    let anotherStruct = AnotherStruct()
  }
  let anotherClassAsDictionary: [String: Any] = ["c": 3, "d": "4", "anotherStruct": ["a": "1", "b": "2"]]
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
}

extension SwiftCollectionPersistenceTests {
  
  struct JsonStruct: SCJsonProtocol {

    let str = SwiftCollectionPersistenceTests().strValue
    let num = SwiftCollectionPersistenceTests().numValue
    let arr = SwiftCollectionPersistenceTests().arrValue
    let dict = SwiftCollectionPersistenceTests().dictValue
    let set = SwiftCollectionPersistenceTests().setValue
    let tuple = SwiftCollectionPersistenceTests().tupleValue
    let null = SwiftCollectionPersistenceTests().nullValue
    let anotherEnum = SwiftCollectionPersistenceTests().anotherEnumValue
    let anotherEnumString = SwiftCollectionPersistenceTests().anotherEnumStringValue
    let anotherEnumNumber = SwiftCollectionPersistenceTests().anotherEnumNumberValue
    let anotherOptionSet = SwiftCollectionPersistenceTests().anotherOptionSetValue
    let anotherStruct = AnotherStruct()
    let anotherClass = AnotherClass()

    func jsonObject(willSaveProperty label: String, value: Any) -> (newLabel: String, newValue: AnyObject?) {
      if label == SwiftCollectionPersistenceTests().anotherEnumStringKey {
        // reflection cannot be used to get the `rawValue` of an enum; special handling is required.
        let theValue = value as! SwiftCollectionPersistenceTests.anotherEnumString
        return (label, theValue.rawValue as AnyObject?)
      } else if label == SwiftCollectionPersistenceTests().anotherEnumNumberKey {
        // reflection cannot be used to get the `rawValue` of an enum; special handling is required.
          let theValue = value as! SwiftCollectionPersistenceTests.anotherEnumNumber
          return (label, theValue.rawValue as AnyObject?)
      }
      return (label, value as AnyObject)
    }
    
  }

  func testJsonStruct() {
    // get struct to test
    let obj = JsonStruct()
    
    // get JSON object
    guard let json = obj.jsonObject() else { XCTAssert(false); return }
    
    print(try! obj.jsonString())
    
    // ensure JSON is a dictionary
    XCTAssertTrue(json is NSDictionary)
    
    // get dictionary and keys
    let dict = json as! [String: Any]
    let keys = Array(dict.keys)
    XCTAssertEqual(keys.count, 11)
    
    // test string
    XCTAssertTrue(keys.contains(strKey))
    XCTAssertEqual(dict[strKey] as? String, strValue)
    
    // test number
    XCTAssertTrue(keys.contains(numKey))
    XCTAssertEqual(dict[numKey] as? Double, numValue)
    
    // test array
    XCTAssertTrue(keys.contains(arrKey))
    XCTAssertEqual((dict[arrKey] as? [String])!, arrValue)
    
    // test dictionary
    XCTAssertTrue(keys.contains(dictKey))
    XCTAssertTrue((dict[dictKey] as! NSDictionary).isEqual(to: dictValue))
    
    // test set
    XCTAssertTrue(keys.contains(setKey))
    XCTAssertTrue((dict[setKey] as! NSArray).isEqual(to: Array(setValue)))
    
    // test tuple (as array)
    XCTAssertTrue(keys.contains(tupleKey))
    XCTAssertEqual((dict[tupleKey] as? [String])!, tupleAsArray)
    
    // test null
    XCTAssertFalse(keys.contains(nullKey))
    
    // test enum
    XCTAssertFalse(keys.contains(anotherEnumKey))
    
    // test enum (string)
    XCTAssertTrue(keys.contains(anotherEnumStringKey))
    XCTAssertEqual(dict[anotherEnumStringKey] as? String, anotherEnumStringRawValue)
    
    // test enum (number)
    XCTAssertTrue(keys.contains(anotherEnumNumberKey))
    XCTAssertEqual(dict[anotherEnumNumberKey] as? Float, anotherEnumNumberRawValue)

    // test option set
    XCTAssertTrue(keys.contains(anotherOptionSetKey))
    XCTAssertTrue((dict[anotherOptionSetKey] as! NSDictionary).isEqual(to: anotherOptionSetAsDictionary))

    // test struct
    XCTAssertTrue(keys.contains(anotherStructKey))
    XCTAssertTrue((dict[anotherStructKey] as! NSDictionary).isEqual(to: anotherStructAsDictionary))
    
    // test class
    XCTAssertTrue(keys.contains(anotherClassKey))
    XCTAssertTrue((dict[anotherClassKey] as! NSDictionary).isEqual(to: anotherClassAsDictionary))
 }
  
}
