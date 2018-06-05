
import Foundation

public struct ObserverType {
    
    public enum ObserveType {
        case keep
        case pass
        case warn
    }
    
    public var type    : ObserveType
    public var info    : String?
    
    public init(type    : ObserveType, info    : String?) {
        self.type = type
        self.info = info
    }
}

public struct CharacterCounter {
    
    public enum VisibleState {
        case always
        case never
        case active
    }
    
    //
    public var min : Int = 0
    public var max : Int = 0
    public var visibleState : VisibleState? = .always
    public var observerType : ObserverType? = ObserverType(type: .pass, info: nil)
    
    public init(min : Int, max : Int = 0, visibleState : VisibleState?, observerType : ObserverType?) {
        self.min = min
        self.max = max
        self.visibleState = visibleState
        self.observerType = observerType
    }
}
