//
//  Vapor+ES6Views.swift
//  
//
//  Created by Nikhil Nigade on 01/12/22.
//

import Foundation
import Vapor

extension Application.Views.Provider {  
  /// Access to the view renderer
  public static var es6views: Self {
    return .init {
      $0.views.use {
        $0.es6views.renderer
      }
    }
  }
}

extension Request {
  /// Access to the view renderer
  public var es6views: ViewRenderer {
    return .init(
      eventLoop: self.eventLoop,
      cache: self.application.es6views.renderer.cache,
      viewDirectory: self.application.directory.viewsDirectory
    )
  }
}
