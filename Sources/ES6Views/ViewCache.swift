//
//  ViewCache.swift
//  
//
//  Created by Nikhil Nigade on 01/12/22.
//

import Foundation
import Vapor

/// The cache
public class ViewCache {
  
  /// The cache storage
  ///
  /// Name: html contents
  internal var storage: [String: String]
  
  /// whether the cache is enabled
  ///
  /// disabled when running in non-release mode
  internal var isEnabled: Bool = true
  
  /// Creates the cache
  internal init() {
    self.storage = [:]
  }
  
  /// Retrieves a formula from the storage
  internal func retrieve(name: String, on loop: EventLoop) -> EventLoopFuture<String?> {
    if let cache = self.storage[name] {
      return loop.makeSucceededFuture(cache)
    }
    else {
      return loop.makeSucceededFuture(nil)
    }
  }
  
  /// Sets or updates a formula at the storage
  internal func upsert(name: String, html: String) {
    self.storage.updateValue(html, forKey: name)
  }
  
  /// Removes a formula from the storage
  internal func remove(name: String) {
    self.storage.removeValue(forKey: name)
  }
}
