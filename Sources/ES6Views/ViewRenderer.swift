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
public class ViewRenderer {
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
  
  /// the path to ES6Views executable
  ///
  /// defaults to `/usr/local/bin/es6views`
  internal var executable: String = "/usr/local/bin/es6views"
  
  /// The event loop the view renderer is running on
  internal var eventLoop: EventLoop
  
  /// The cache of the view renderer
  internal var cache: ViewCache
  
  /// The directory storing all the view files
  internal var viewDirectory: String
  
  /// Creates the view renderer
  public init(eventLoop: EventLoop, cache: ViewCache, viewDirectory: String) {
    self.eventLoop = eventLoop
    self.cache = cache
    self.viewDirectory = viewDirectory
    
    if let executable = Environment.process.es6views {
      self.executable = executable
    }
  }
  
  /// Renders a layout and its context
  /// - Parameters:
  ///   - name: the file name
  ///   - context: data to pass to the view
  /// - Returns: buffer to render
  public func render(name: String, context: Encodable) -> EventLoopFuture<ByteBuffer> {
    let filePath = name.hasPrefix("/") ? name : [viewDirectory, name].joined(separator: "") + ".es6"
    
    var buffer = ByteBufferAllocator().buffer(capacity: 4096)
    
    do {
      guard FileManager.default.fileExists(atPath: filePath) else {
        throw RendererError.unkownLayout(name)
      }
      
      let json = try JSONSerialization.data(withJSONObject: context)
      let jsonString = String(data: json, encoding: .utf8)!
      
      let command = "-O -x \(jsonString) \(filePath)"
      let html = try safeShell(executable, ["-O", "-x", jsonString, filePath])
      buffer.writeString(html)
      
      return self.eventLoop.makeSucceededFuture(buffer)
    }
    catch {
      return self.eventLoop.makeFailedFuture(error)
    }
  }
  
  // MARK: Internal
  @discardableResult // Add to suppress warnings when you don't want/need a result
  private func safeShell(_ launchPath: String, _ commands: [String]) throws -> String {
    let task = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    task.standardOutput = outputPipe
    task.standardError = errorPipe
    task.arguments = commands
    task.launchPath = launchPath
    task.standardInput = nil
    task.environment?["PWD"] = viewDirectory
    task.environment?["PATH"] = "/usr/bin:/usr/local/bin"
    
    try task.run()
    
    if let errorData = try? errorPipe.fileHandleForReading.readToEnd(),
       !errorData.isEmpty,
       let errorOutput = String(data: errorData, encoding: .utf8) {
      throw RendererError.commandError(errorOutput.removingTrailingLinebreak())
    }
    
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output.removingTrailingLinebreak()
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

// MARK: - Vapor.ViewRenderer
extension ViewRenderer: Vapor.ViewRenderer {
  public func `for`(_ request: Request) -> Vapor.ViewRenderer {
    return request.es6views
  }
  
  public func render<E:Encodable>(_ name: String, _ context: E) -> EventLoopFuture<Vapor.View> {
    return self.render(name: name, context: context).map { buffer in
      return View(data: buffer)
    }
  }
}

extension ViewRenderer.RendererError: AbortError {
  @_implements(AbortError, reason)
  public var abortReason: String { self.description }
  
  public var status: HTTPResponseStatus { .internalServerError }
}

extension ViewRenderer.RendererError: DebuggableError {
  @_implements(DebuggableError, reason)
  public var debuggableReason: String { self.description }
}
