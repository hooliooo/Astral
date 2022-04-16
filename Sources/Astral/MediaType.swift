//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 Representation of a Media Type for HTTP requests.
 */
public enum MediaType: Hashable {

  /**
   Application type with a custom subtype as an associated String value.
   */
  case application(String)

  /**
   Media type of application/json.
   */
  case applicationJSON

  /**
   Media type of application/x-www-form-urlencoded.
   */
  case applicationURLEncoded

  /**
   Multipart type with a custom subtype as an associated String value.
   */
  case multipart(String)

  /**
   Media type of multipart/form-data with a boundary parameter as an associated String value.
   */
  case multipartFormData(String)

  /**
   A representation of a custom type and subtype as associated String values with top level type on the left hand side and
   sub type on the right hand side.
   */
  case custom(String, String)

  /**
   String representation of the Media type.
   */
  public var stringValue: String {
    switch self {
      case .application(let subtype):
        return "application/\(subtype)"

      case .applicationJSON:
        return "application/json"

      case .applicationURLEncoded:
        return "application/x-www-form-urlencoded"

      case .multipart(let subtype):
        return "multipart/\(subtype)"

      case .multipartFormData(let boundary):
        return "multipart/form-data; boundary=\(boundary)"

      case let .custom(type, subtype):
        return "\(type)/\(subtype)"
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.stringValue)
  }

  public static func == (lhs: MediaType, rhs: MediaType) -> Bool {
    switch (lhs, rhs) {
      case (.application, .application): return lhs.stringValue == rhs.stringValue
      case (.applicationJSON, .applicationJSON): return true
      case (.applicationURLEncoded, .applicationURLEncoded): return true
      case (.multipart, .multipart): return lhs.stringValue == rhs.stringValue
      case (.multipartFormData, .multipartFormData): return lhs.stringValue == rhs.stringValue
      case (.custom, .custom): return lhs.stringValue == rhs.stringValue
      default: return false
    }
  }
}
