//
//  ES6Layout.swift
//  
//
//  Created by Nikhil Nigade on 02/04/24.
//

import Foundation
import Vapor

public protocol ModelView {
  /// the HTML markup content
  var markup: String { get set }
  
  /// called when the the view has been instantiated and should parse its `data` into the `markup`.
  func parse() async throws
}

/// Base layout for using with `ES6ViewRenderer`
///
/// This must be extended to support `data`. See `README` for instructions.
open class ES6Layout: ModelView {
  public var renderPartial: String?
  
  public var markup: String = ""
  
  public required init(renderPartial: String?) {
    self.renderPartial = renderPartial
  }
  
  open func parse() async throws {
    assertionFailure("You should write your common layout logic in a subclass of Layout. When you're done, simply call super with your rendered interstetials.")
  }
}
