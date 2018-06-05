import UIKit

public protocol OCTextInputStyle {
    var activeColor: UIColor { get }
    var inactiveColor: UIColor { get }
    var invisibleColor: UIColor { get }
    var lineInactiveColor: UIColor { get }
    var errorColor: UIColor { get }
    var textInputFont: UIFont { get }
    var textInputFontColor: UIColor { get }
    var placeholderMinFontSize: CGFloat { get }
    var counterLabelFont: UIFont? { get }
    var marginInsets : UIEdgeInsets { get }
    var yHintPositionOffset: CGFloat { get }
    var yPlaceholderPositionOffset: CGFloat { get }
    var counterRightMargin: CGFloat { get }
}

public struct OCTextInputStyleDefault: OCTextInputStyle {
    
    public let activeColor = UIColor.blue.withAlphaComponent(0.5)
    public let inactiveColor = UIColor.gray.withAlphaComponent(0.5)
    public let invisibleColor = UIColor.clear
    public let lineInactiveColor = UIColor.gray.withAlphaComponent(0.2)
    public let errorColor = UIColor.red
    public let textInputFont = UIFont.systemFont(ofSize: 14)
    public let textInputFontColor = UIColor.black
    public let placeholderMinFontSize: CGFloat = 9
    public let counterLabelFont: UIFont? = UIFont.systemFont(ofSize: 9)
    public let marginInsets: UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 20.0, bottom: 3.0, right: 0.0)
    public let yHintPositionOffset: CGFloat = 5
    public let yPlaceholderPositionOffset: CGFloat = 5
    public let counterRightMargin: CGFloat = 20
    
    public init() { }
}
