//
//  ES6Views.swift
//  
//
//  Created by Nikhil Nigade on 01/12/22.
//

import Foundation
import Vapor

extension Application {
  /// Access to the vapor provider
  public var es6views: ES6Views {
    return .init(application: self)
  }
  
  /// The vapor provider
  public struct ES6Views {
    internal struct CacheStorageKey: StorageKey {
      public typealias Value = ViewCache
    }
    
    /// The view cache
    public var views: ViewCache {
      if let cache = self.application.storage[CacheStorageKey.self] {
        return cache
      }
      
      let cache = ViewCache()
      
      self.application.storage[CacheStorageKey.self] = cache
      
      return cache
    }
    
    /// The view renderer
    internal var renderer: ViewRenderer {
      return .init(
        eventLoop: self.application.eventLoopGroup.next(),
        cache: self.views,
        viewDirectory: self.application.directory.viewsDirectory
      )
    }
    
    /// The application dependency
    public let application: Application
    
    /// Creates the provider
    public init(application: Application) {
      self.application = application
    }
  }
}
