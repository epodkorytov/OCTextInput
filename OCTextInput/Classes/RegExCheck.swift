
import Foundation

public enum RegExCheckError: Error {
    case empty
    case validationError(String)
}

public struct RegExCheck {
    public var expression      : String
    public var errorMessage    : String?
    
    public init(expression      : String, errorMessage    : String?) {
        self.expression = expression
        self.errorMessage = errorMessage
    }
}
