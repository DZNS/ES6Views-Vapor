//
//  ViewRenderer.swift
//  
//
//  Created by Nikhil Nigade on 01/12/22.
//

import Foundation
import Vapor

// MARK: - ViewRenderer

/// The view renderer for ES6Views
public class ES6ViewRenderer {
  let logger = Logger(label: "ES6Views")
  
  /// A enumeration of possible errors of the view renderer
  public enum RendererError: Error {
    case unkownLayout(String)
    case commandError(String)
    
    public var description: String {
      switch self {
      case .unkownLayout(let path):
        return "Layout with the path '\(path)' could not be found."
      case .commandError(let string):
        return string
      }
    }
  }
  
  /// The event loop the view renderer is running on
  internal var eventLoop: EventLoop
  
  /// The cache of the view renderer
  internal var cache: ViewCache
  
  /// The directory storing all the view files
  internal var viewDirectory: String
  
  private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()
  
  /// Creates the view renderer
  public init(eventLoop: EventLoop, cache: ViewCache, viewDirectory: String) {
    self.eventLoop = eventLoop
    self.cache = cache
    self.viewDirectory = viewDirectory
  }
  
  /// Renders a layout and its context
  /// - Parameters:
  ///   - name: the file name
  ///   - context: data to pass to the view
  /// - Returns: buffer to render
  public func renderView<T: ES6Layout>(view: T.Type, context: Encodable) async throws -> View {
    var buffer = ByteBufferAllocator().buffer(capacity: 4096)

    let view = view.init(renderPartial: nil)
    try await view.parse()
    buffer.writeString(view.markup)
    
    return View(data: buffer)
  }
}

private extension String {
  func removingTrailingLinebreak() -> String {
    if !isEmpty, hasSuffix("\n") {
      let lastIndex = self.index(before: self.endIndex)
      return String(self[self.startIndex ..< lastIndex])
    }
    
    return self
  }
}

extension ES6ViewRenderer.RendererError: AbortError {
  @_implements(AbortError, reason)
  public var abortReason: String { self.description }
  
  public var status: HTTPResponseStatus { .internalServerError }
}

extension ES6ViewRenderer.RendererError: DebuggableError {
  @_implements(DebuggableError, reason)
  public var debuggableReason: String { self.description }
}
