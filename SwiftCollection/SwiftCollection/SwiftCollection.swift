//
//  SwiftCollection.swift
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

public struct SwiftCollection {
  
  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Bundle
   * -----------------------------------------------------------------------------------------------
   */

  /// Bundle Id for this framework.
  public static let bundleId = "com.wyz.SwiftCollection"

  /// Bundle for this framework.
  public static let bundle = Bundle(identifier: bundleId)!
  
  /// Name for this framework.
  public static var name: String {
    let info = bundle.infoDictionary!
    let name = info["CFBundleName"] as! String
    let version = info["CFBundleShortVersionString"] as! String
    return "\(name) v\(version)"
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Error
   * -----------------------------------------------------------------------------------------------
   */
  
  /// Errors that can be thrown for `SwiftCollection`.
  ///
  /// - missingId: There is no `id` for a document.
  /// - existingId:  A document with the `id` already exists in the collection.
  /// - generateId: Unable to generate a new unique id.
  /// - notFound: Object cannot be found.
  /// - invalidJson: Object can not be serialized to JSON.  Contains invalid properties.
  public enum Errors: Error {
    
    /// There is no `id` for a document.
    case missingId
    
    /// A document with the `id` already exists in the collection.
    case existingId
    
    /// Unable to generate a new unique id.
    case generateId
    
    /// Object cannot be found.
    case notFound
    
    /// Object can not be serialized to/from JSON.  Contains invalid properties.
    case invalidJson
    
    /// Missing key for JSON serialized object.
    case missingStorageKey
    
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Functions
   * -----------------------------------------------------------------------------------------------
   */
  
  /// Unwraps optional values.  `NSNull` is substituted for `nil` values.
  ///
  /// - Parameter any: Object to unwrap.
  /// - Returns: Original value if not optional, unwrapped value or `NSNull` when `nil`.
  public static func unwrap(any: Any) -> Any {
    let mirror = Mirror(reflecting: any)
    
    // return original if it is not optional
    if mirror.displayStyle != .optional { return any }
    
    // handle nil optional
    if mirror.children.count == 0 { return NSNull() }
    
    // otherwise return some value
    let (_, some) = mirror.children.first!
    return some
  }

  /*
   * -----------------------------------------------------------------------------------------------
   * MARK: - Notifications
   * -----------------------------------------------------------------------------------------------
   */

  public enum Notifications: String {
    
    /// Posted when properties of an object was changed.
    case didChange = "didChange"
    
    /// Returns a `Notification.Name` for this enumeration value.
    public var notification : Notification.Name  {
      return Notification.Name(rawValue: "\(SwiftCollection.bundleId).\(self.rawValue)" )
    }

    /// Posts a change using `NotificationCenter` for the specified object and corresponding
    /// actions.
    ///
    /// - Parameters:
    ///   - object: Collection or document that was changed.
    ///   - inserted: Items that were inserted into the object.
    ///   - updated: Items that were updated or moved in the object.
    ///   - deleted: Items that were removed from the the object.
    public static func postChange(_ object: Any, inserted: [Change]?, updated: [Change]?, deleted: [Change]?) {
      let notification = Notifications.didChange.notification
      var userInfo: [Keys: [Change]] = [:]
      if let inserted = inserted { userInfo[Keys.inserted] = inserted }
      if let updated = updated { userInfo[Keys.updated] = updated }
      if let deleted = deleted { userInfo[Keys.deleted] = deleted }
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: notification, object: object, userInfo: userInfo)
      }
    }
    
    /// Keys for the `userinfo` dictionary of a `Notification`.
    public enum Keys: String {
      
      /// Items that were inserted into a collection.
      case inserted = "inserted"
      
      /// Items that were replaced or moved in a collection.  Or document that was updated.
      case updated = "updated"
      
      /// Items that were removed from a collection.
      case deleted = "deleted"
      
    }
    
    /// Value for the `userinfo` dictionary of a `Notification`.
    public struct Change {
      
      /// New location for the change.
      public let index: Int?
      
      /// Document that inserted or removed.
      public let document: SCDocument?
      
      /// Property that was updated.
      public let property: String?

      /// Original value for property.
      public let oldValue: Any?

      /// New value for property.
      public let newValue: Any?

      /// Initializes a new `Change` object for a document in a collection.
      ///
      /// - Parameters:
      ///   - document: Document that was inserted or removed.
      ///   - index: Index in collection for document.
      public init(_ document: SCDocument?, atIndex index: Int?) {
        self.document = document
        self.index = index
        self.property = nil
        self.oldValue = nil
        self.newValue = nil
      }

      /// Initializes a new `Change` object for a property in a document.
      ///
      /// - Parameters:
      ///   - property: Property that was updated.
      ///   - oldValue: Original value for property.
      ///   - newValue: New value for property.
      public init(_ property: String?, oldValue: String?, newValue: String?) {
        self.document = nil
        self.index = nil
        self.property = property
        self.oldValue = oldValue
        self.newValue = newValue
      }

    }
    
  }

}
