//
//  Application+ES6Views.swift
//  
//
//  Created by Nikhil Nigade on 03/04/24.
//

import Foundation
import Vapor

extension Application.Views.Provider {
  public static var es6views: Self {
    .init {
      $0.views.use {
        $0.es6views.renderer as! (any ViewRenderer)
      }
    }
  }
}

extension Application {
  public var es6views: ES6Views {
    ES6Views(application: self)
  }
  
  /// The vapor provider
  public struct ES6Views {
    /// The application dependency
    public let application: Application
    
    internal struct CacheStorageKey: StorageKey {
      public typealias Value = ViewCache
    }
    
    /// The view cache
    public var cache: ViewCache {
      if let cache = self.application.storage[CacheStorageKey.self] {
        return cache
      }
      
      let cache = ViewCache()
      
      if application.environment.isRelease == false {
        cache.isEnabled = false
      }
      
      self.application.storage[CacheStorageKey.self] = cache
      
      return cache
    }
    
    /// The view renderer
    internal var renderer: ES6ViewRenderer {
      return .init(
        eventLoop: self.application.eventLoopGroup.next(),
        cache: self.cache,
        viewDirectory: self.application.directory.viewsDirectory
      )
    }
    
    /// Creates the provider
    public init(application: Application) {
      self.application = application
    }
  }
}

extension Request {
  /// Access to the view renderer
  public var es6viewsRenderer: ES6ViewRenderer {
    return ES6ViewRenderer(
      eventLoop: self.eventLoop,
      cache: self.application.es6views.cache,
      viewDirectory: self.application.directory.viewsDirectory
    )
  }
}
