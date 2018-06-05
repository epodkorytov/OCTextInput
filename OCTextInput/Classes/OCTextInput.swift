import Foundation
import UIKit

public protocol OCTextInputDelegate: class {
    func OCTextInputDidBeginEditing(_ OCTextInput: OCTextInput)
    func OCTextInputDidEndEditing(_ OCTextInput: OCTextInput)
    func OCTextInputDidChange(_ OCTextInput: OCTextInput)
    func OCTextInputShouldChangeCharacters(_ OCTextInput: OCTextInput, inRange range: NSRange, replacementString string: String) -> Bool
    func OCTextInputShouldBeginEditing(_ OCTextInput: OCTextInput) -> Bool
    func OCTextInputShouldEndEditing(_ OCTextInput: OCTextInput) -> Bool
    func OCTextInputShouldReturn(_ OCTextInput: OCTextInput) -> Bool
    func OCTextInputShouldClear(_ OCTextInput: OCTextInput) -> Bool
    func OCTextInputWillChangeValidState(_ OCTextInput: OCTextInput)
}


public extension OCTextInputDelegate {
    func OCTextInputDidBeginEditing(_ OCTextInput: OCTextInput) {}
    func OCTextInputDidEndEditing(_ OCTextInput: OCTextInput) {}
    func OCTextInputDidChange(_ OCTextInput: OCTextInput) {}
    func OCTextInputShouldChangeCharacters(_ OCTextInput: OCTextInput, inRange range: NSRange, replacementString string: String) -> Bool { return true }
    func OCTextInputShouldBeginEditing(_ OCTextInput: OCTextInput) -> Bool { return true }
    func OCTextInputShouldEndEditing(_ OCTextInput: OCTextInput) -> Bool { return true }
    func OCTextInputShouldReturn(_ OCTextInput: OCTextInput) -> Bool { return true }
    func OCTextInputShouldClear(_ OCTextInput: OCTextInput) -> Bool { return true }
    func OCTextInputWillChangeValidState(_ OCTextInput: OCTextInput) {}
}


public class OCTextInput: UIControl {
    
    public typealias OCTextInputType = OCTextInputFieldConfigurator.OCTextInputType
    
    open var tapAction: (() -> Void)?
    open weak var delegate: OCTextInputDelegate?
    open fileprivate(set) var isActive = false
    
    open var type: OCTextInputType = .standard {
        didSet {
            configureType()
        }
    }
    
    open var returnKeyType: UIReturnKeyType! = .default {
        didSet {
            textInput.changeReturnKeyType(with: returnKeyType)
        }
    }
    
    open var placeHolderText = OCTextInputDefaults.Placeholder().text {
        didSet {
            placeholderLayer.string = placeHolderText
        }
    }
    
    open var  regEx : RegExCheck? {
        didSet {
            
        }
    }
    
    open var characterCounter : CharacterCounter? {
        didSet {
            showCharacterCounter()
        }
    }
    
    open var animatePlaceHolder = OCTextInputDefaults.Placeholder().animate
    
    open var style: OCTextInputStyle = OCTextInputStyleDefault() {
        didSet {
            configureStyle()
        }
    }
    
    open var text: String? {
        get {
            return textInput.currentText
        }
        set {
            if !textInput.view.isFirstResponder {
                (newValue != nil) ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
            }
            textInput.currentText = newValue
        }
    }
    
    open var selectedTextRange: UITextRange? {
        get { return textInput.currentSelectedTextRange }
        set { textInput.currentSelectedTextRange = newValue }
    }
    
    open var beginningOfDocument: UITextPosition? {
        get { return textInput.currentBeginningOfDocument }
    }
    
    open var isValid: Bool! = true {
        willSet {
            if newValue != self.isValid {
                delegate?.OCTextInputWillChangeValidState(self)
            }
        }
    }
    //
    fileprivate let lineView = AnimatedLine()
    fileprivate let placeholderLayer = CATextLayer()
    
    fileprivate let additionView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor.clear
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let errorLabel: UILabel = {
        let label = UILabel()
            label.backgroundColor = UIColor.clear
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let counterLabel: UILabel = {
        let label = UILabel()
            label.backgroundColor = UIColor.clear
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let lineWidth: CGFloat = 1.0 / UIScreen.main.scale
    fileprivate let counterLabelRightMargin: CGFloat = 15.0
    fileprivate let counterLabelTopMargin: CGFloat = 0.0
    
    fileprivate var isResigningResponder = false
    fileprivate var isPlaceholderAsHint = false
    fileprivate var hasCounterLabel = false
    fileprivate var textInput: TextInput!
    
    fileprivate var textInputTrailingConstraint: NSLayoutConstraint!
    fileprivate var disclosureViewWidthConstraint: NSLayoutConstraint!
    fileprivate var disclosureView: UIView?
    fileprivate var placeholderErrorText: String?
    
    fileprivate var placeholderPosition: CGPoint {
        if isPlaceholderAsHint {
            return CGPoint(x: style.marginInsets.left, y: style.yHintPositionOffset)
        } else {
            return CGPoint(x: style.marginInsets.left, y: style.marginInsets.top + style.yPlaceholderPositionOffset)
        }
    }
    
    //
    public convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCommonElements()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCommonElements()
    }
    //
    override open var intrinsicContentSize: CGSize {
        let normalHeight : CGFloat = textInput.view.intrinsicContentSize.height
        return CGSize(width: UIViewNoIntrinsicMetric, height: normalHeight + style.marginInsets.top + style.marginInsets.bottom)
    }
    
    open override func updateConstraints() {
        addLineViewConstraints()
        addTextInputConstraints()
        super.updateConstraints()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlaceholderLayer()
    }
    
    fileprivate func layoutPlaceholderLayer() {
        let frameHeightCorrectionFactor: CGFloat = 1.2
        placeholderLayer.frame = CGRect(origin: placeholderPosition, size: CGSize(width: bounds.width, height: style.textInputFont.pointSize * frameHeightCorrectionFactor))
    }
    
    // mark: Configuration
    
    fileprivate func addAdditionViewConstraints() {
        pinLeading(toLeadingOf: additionView, constant: style.marginInsets.left)
        let _ = pinTrailing(toTrailingOf: additionView, constant: style.marginInsets.right)
        pinBottom(toBottomOf: additionView, constant: 0.0)
    }
    
    fileprivate func addLineViewConstraints() {
        addAdditionViewConstraints()
        
        pinLeading(toLeadingOf: lineView, constant: style.marginInsets.left)
        let _ = pinTrailing(toTrailingOf: lineView, constant: style.marginInsets.right)
        lineView.setHeight(to: lineWidth)
        
        let constant : CGFloat = 1.0 //characterCounter != nil ? -counterLabel.intrinsicContentSize.height - counterLabelTopMargin : 0
        lineView.pinBottom(toTopOf: additionView, constant: constant)
    }
    
    fileprivate func addTextInputConstraints() {
        pinLeading(toLeadingOf: textInput.view, constant: style.marginInsets.left)
        if disclosureView == nil {
            textInputTrailingConstraint = pinTrailing(toTrailingOf: textInput.view, constant: style.marginInsets.right)
        }
        pinTop(toTopOf: textInput.view, constant: style.marginInsets.top)
        textInput.view.pinBottom(toTopOf: lineView, constant: style.marginInsets.bottom)
    }
    
    fileprivate func setupCommonElements() {
        addAdditionView()
        addLine()
        addPlaceHolder()
        addTapGestureRecognizer()
        addTextInput()
    }
    
    fileprivate func addAdditionView() {
        addSubview(additionView)
    }
    
    fileprivate func addLine() {
        lineView.defaultColor = style.lineInactiveColor
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
    }
    
    fileprivate func addPlaceHolder() {
        placeholderLayer.masksToBounds = false
        placeholderLayer.string = placeHolderText
        placeholderLayer.foregroundColor = style.inactiveColor.cgColor
        placeholderLayer.fontSize = style.textInputFont.pointSize
        placeholderLayer.font = style.textInputFont
        placeholderLayer.contentsScale = UIScreen.main.scale
        placeholderLayer.backgroundColor = UIColor.clear.cgColor
        layoutPlaceholderLayer()
        layer.addSublayer(placeholderLayer)
    }
    
    fileprivate func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        addGestureRecognizer(tap)
    }
    
    fileprivate func addTextInput() {
        textInput = OCTextInputFieldConfigurator.configure(with: type)
        textInput.textInputDelegate = self
        textInput.view.tintColor = style.activeColor
        textInput.textColor = style.textInputFontColor
        textInput.font = style.textInputFont
        textInput.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textInput.view)
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func updateCounter() {
        guard let counterText = counterLabel.text else { return }
        let components = counterText.components(separatedBy: "/")
        let characters = (text != nil) ? text!.count : 0
        
        counterLabel.text = "\(characters)/\(components[1])"
    }
    
    // mark: States and animations
    
    fileprivate func configurePlaceholderAsActiveHint() {
        
        if !animatePlaceHolder {
            configurePlaceholderAsHiden()
            return
        }
        
        isPlaceholderAsHint = true
        
        if let counter = characterCounter {
            if counter.visibleState == .active {
                counterLabel.isHidden = false
            }
        }
        
        configurePlaceholderWith(fontSize: style.placeholderMinFontSize,
                                 foregroundColor: style.activeColor.cgColor,
                                 text: placeHolderText)
        lineView.fillLine(with: style.activeColor)
    }
    
    fileprivate func configurePlaceholderAsInactiveHint() {
        isPlaceholderAsHint = true
        
        if let counter = characterCounter {
            if counter.visibleState == .active {
                counterLabel.isHidden = true
            }
        }
        
        configurePlaceholderWith(fontSize: style.placeholderMinFontSize,
                                 foregroundColor: style.inactiveColor.cgColor,
                                 text: placeHolderText)
        lineView.animateToInitialState()
    }
    
    fileprivate func configurePlaceholderAsDefault() {
        isPlaceholderAsHint = false
        
        if let counter = characterCounter {
            if counter.visibleState == .active {
                counterLabel.isHidden = true
            }
        }
        
        configurePlaceholderWith(fontSize: style.textInputFont.pointSize,
                                 foregroundColor: style.inactiveColor.cgColor,
                                 text: placeHolderText)
        lineView.animateToInitialState()
    }
    
    fileprivate func configurePlaceholderAsErrorHint() {
        isPlaceholderAsHint = true
        
        if let counter = characterCounter {
            if counter.visibleState == .active {
                counterLabel.isHidden = false //true
            }
        }
        
        configurePlaceholderWith(fontSize: style.placeholderMinFontSize,
                                 foregroundColor: style.errorColor.cgColor,
                                 text: placeHolderText)
        lineView.fillLine(with: style.errorColor)
    }
    
    fileprivate func configurePlaceholderAsHiden() {
        isPlaceholderAsHint = false
        
        if let counter = characterCounter {
            if counter.visibleState == .active {
                counterLabel.isHidden = true
            }
        }
        
        configurePlaceholderWith(fontSize: style.textInputFont.pointSize,
                                 foregroundColor: style.invisibleColor.cgColor,
                                 text: placeHolderText)
        lineView.fillLine(with: style.activeColor)
    }
    
    fileprivate func configurePlaceholderWith(fontSize: CGFloat, foregroundColor: CGColor, text: String?) {
        placeholderLayer.fontSize = fontSize
        placeholderLayer.foregroundColor = foregroundColor
        placeholderLayer.string = text
        layoutPlaceholderLayer()
    }
    
    fileprivate func animatePlaceholder(to applyConfiguration: () -> Void) {
        
        let function = CAMediaTimingFunction(controlPoints: 0.3, 0.0, 0.5, 0.95)
        transactionAnimation(with: OCTextInputDefaults.Placeholder().duration, timingFuncion: function, animations: applyConfiguration)
    }
    
    // mark: Behaviours
    
    @objc fileprivate func viewWasTapped(sender: UIGestureRecognizer) {
        if let tapAction = tapAction {
            tapAction()
        } else {
            becomeFirstResponder()
        }
    }
    
    fileprivate func styleDidChange() {
        lineView.defaultColor = style.lineInactiveColor
        placeholderLayer.foregroundColor = style.inactiveColor.cgColor
        let fontSize = style.textInputFont.pointSize
        placeholderLayer.fontSize = fontSize
        placeholderLayer.font = style.textInputFont
        textInput.view.tintColor = style.activeColor
        textInput.textColor = style.textInputFontColor
        textInput.font = style.textInputFont
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
    
    @discardableResult override open func becomeFirstResponder() -> Bool {
        isActive = true
        let firstResponder = textInput.view.becomeFirstResponder()
        counterLabel.textColor = style.activeColor
        placeholderErrorText = nil
        animatePlaceholder(to: configurePlaceholderAsActiveHint)
        return firstResponder
    }
    
    override open var isFirstResponder: Bool {
        return textInput.view.isFirstResponder
    }
    
    override open func resignFirstResponder() -> Bool {
        guard !isResigningResponder else { return true }
        isActive = false
        isResigningResponder = true
        let resignFirstResponder = textInput.view.resignFirstResponder()
        isResigningResponder = false
        counterLabel.textColor = style.inactiveColor
        
        /*
        if let textInputError = textInput as? TextInputError {
            textInputError.removeErrorHintMessage()
        }
        */
        // If the placeholder is showing an error we want to keep this state. Otherwise revert to inactive state.
        if placeholderErrorText == nil {
            animateToInactiveState()
            clearError()
        }
        return resignFirstResponder
    }
    
    fileprivate func animateToInactiveState() {
        guard let text = textInput.currentText, !text.isEmpty else {
            animatePlaceholder(to: configurePlaceholderAsDefault)
            return
        }
        animatePlaceholder(to: configurePlaceholderAsInactiveHint)
    }
    
    override open var canResignFirstResponder: Bool {
        return textInput.view.canResignFirstResponder
    }
    
    override open var canBecomeFirstResponder: Bool {
        guard !isResigningResponder else { return false }
        if let disclosureView = disclosureView, disclosureView.isFirstResponder {
            return false
        }
        return textInput.view.canBecomeFirstResponder
    }
    
    //Error label
    open func show(error errorMessage: String, placeholderText: String? = nil) {
        placeholderErrorText = errorMessage
        showError(text: placeholderErrorText!)
        
        animatePlaceholder(to: configurePlaceholderAsErrorHint)
    }
    
    open func clearError() {
        isValid = true
        placeholderErrorText = nil
        errorLabel.removeConstraints(errorLabel.constraints)
        errorLabel.removeFromSuperview()
        
        if isActive {
            animatePlaceholder(to: configurePlaceholderAsActiveHint)
        } else {
            animateToInactiveState()
        }
    }
    
    fileprivate func showError(text : String) {
        isValid = false
        errorLabel.text = text
        errorLabel.textColor = style.errorColor
        errorLabel.font = style.counterLabelFont
        additionView.addSubview(errorLabel)
        
        additionView.pinTop(toTopOf: errorLabel, constant: 0)
        additionView.pinLeading(toLeadingOf: errorLabel, constant: 0)
        additionView.pinBottom(toBottomOf: errorLabel, constant: 0)
        
        if counterLabel.superview == nil {
            let _ = errorLabel.pinTrailing(toTrailingOf: additionView, constant: counterLabelRightMargin)
        } else {
            let _ = errorLabel.pinTrailing(toLeadingOf: counterLabel, constant: 5)
        }
        
        additionView.invalidateIntrinsicContentSize()
    }
    
    //
    fileprivate func configureType() {
        textInput.view.removeFromSuperview()
        addTextInput()
    }
    
    fileprivate func configureStyle() {
        styleDidChange()
        if isActive {
            configurePlaceholderAsActiveHint()
        } else {
            isPlaceholderAsHint ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
        }
    }
    
    open func showCharacterCounterLabel(with maximum: Int) {
        let characters = (text != nil) ? text!.count : 0
        counterLabel.text = "\(characters)/\(maximum)"
        counterLabel.textColor = isActive ? style.activeColor : style.inactiveColor
        counterLabel.font = style.counterLabelFont
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addCharacterCounterConstraints()
        invalidateIntrinsicContentSize()
    }
    
    
    fileprivate func showCharacterCounter() {
        guard let counter = characterCounter else {
            return
        }
        
        if counter.visibleState == .never {
            return
        }
        
        var limit = ""
        
        if counter.min == 0 && counter.max > 0 {
            limit = "\(counter.max)"
        } else if counter.min > 0 && counter.max > 0 {
            limit = "\(counter.min)-\(counter.max)"
        }
        
        let characters = (text != nil) ? text!.count : 0
        
        if limit.count > 0 {
            counterLabel.text = "\(characters)/\(limit)"
        } else {
            counterLabel.text = "\(characters)"
        }
        
        counterLabel.textColor = isActive ? style.activeColor : style.inactiveColor
        counterLabel.font = style.counterLabelFont
        counterLabel.isHidden = counter.visibleState != .always
        
        additionView.addSubview(counterLabel)
        addCharacterCounterConstraints()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func addCharacterCounterConstraints() {
        additionView.pinTop(toTopOf: counterLabel, constant: counterLabelTopMargin)
        additionView.pinBottom(toBottomOf: counterLabel, constant: 0.0)
        let _ = additionView.pinTrailing(toTrailingOf: counterLabel, constant: counterLabelRightMargin)
        additionView.invalidateIntrinsicContentSize()
    }
    
    open func removeCharacterCounterLabel() {
        counterLabel.removeConstraints(counterLabel.constraints)
        counterLabel.removeFromSuperview()
        additionView.invalidateIntrinsicContentSize()
    }
    
    //
    open func addDisclosureView(disclosureView: UIView) {
        if let constraint = textInputTrailingConstraint {
            removeConstraint(constraint)
        }
        self.disclosureView?.removeFromSuperview()
        self.disclosureView = disclosureView
        addSubview(disclosureView)
        textInputTrailingConstraint = textInput.view.pinTrailing(toLeadingOf: disclosureView, constant: 0)
        disclosureView.alignHorizontalAxis(toSameAxisOfView: textInput.view)
        disclosureView.pinBottom(toBottomOf: self, constant: 12)
        let _ = disclosureView.pinTrailing(toTrailingOf: self, constant: 16)
    }
    
    open func removeDisclosureView() {
        guard disclosureView != nil else { return }
        disclosureView?.removeFromSuperview()
        disclosureView = nil
        textInput.view.removeConstraint(textInputTrailingConstraint)
        textInputTrailingConstraint = pinTrailing(toTrailingOf: textInput.view, constant: style.marginInsets.right)
    }
    
    open func position(from: UITextPosition, offset: Int) -> UITextPosition? {
        return textInput.currentPosition(from: from, offset: offset)
    }
    
    fileprivate func checkByRegExp() throws {
        
        let text = self.textInput.currentText!
        
        if text.count == 0 {
            throw RegExCheckError.empty
        }
        
        guard let regEx = regEx else {
            return
        }
        
        let regex = try! NSRegularExpression(pattern: regEx.expression)
        
        
        let results = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        
        if results.count == 0
        {
            throw RegExCheckError.validationError(regEx.errorMessage!)
        }
    }
    
}

extension OCTextInput: TextInputDelegate {
    open func textInputDidBeginEditing(textInput: TextInput) {
        becomeFirstResponder()
        delegate?.OCTextInputDidBeginEditing(self)
    }
    
    open func textInputDidEndEditing(textInput: TextInput) {
        do {
             try checkByRegExp()
             //clearError()
        }
        catch let error as RegExCheckError {
            switch error {
            case .empty:
                configurePlaceholderAsActiveHint()
                break
            case .validationError(let msg):
                show(error: msg, placeholderText: placeHolderText)
                break
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        let _ = resignFirstResponder()
        delegate?.OCTextInputDidEndEditing(self)
    }
    
    open func textInputDidChange(textInput: TextInput) {
        updateCounter()
        delegate?.OCTextInputDidChange(self)
    }
    
    open func textInput(textInput: TextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textInput.currentText, case let start = text.utf16.index(text.utf16.startIndex, offsetBy: range.lowerBound),
            case let end = text.utf16.index(text.utf16.startIndex, offsetBy: range.upperBound),
            let startIndex = start.samePosition(in: text), let endIndex = end.samePosition(in: text)
        {
            let newString = text.replacingCharacters(in: startIndex..<endIndex, with: string)
            
            if let counter = characterCounter {
                if counter.visibleState != .never && counter.observerType?.type != .pass {
                    if newString.count < counter.min || newString.count > counter.max {
                        if let msg = counter.observerType?.info {
                            show(error: msg, placeholderText: placeHolderText)
                        } else {
                            configurePlaceholderAsErrorHint()
                        }
                        
                        if newString.count > counter.max && counter.observerType?.type == .keep {
                            return delegate?.OCTextInputShouldChangeCharacters(self, inRange: NSMakeRange(0, 0), replacementString: "") ?? false
                        }
                        
                    } else {
                        clearError()
                    }
                }
            }
        }
        return delegate?.OCTextInputShouldChangeCharacters(self, inRange: range, replacementString: string) ?? true
    }
    
    open func textInputShouldBeginEditing(textInput: TextInput) -> Bool {
        return delegate?.OCTextInputShouldBeginEditing(self) ?? true
    }
    
    open func textInputShouldEndEditing(textInput: TextInput) -> Bool {
        return delegate?.OCTextInputShouldEndEditing(self) ?? true
    }
    
    open func textInputShouldReturn(textInput: TextInput) -> Bool {
        return delegate?.OCTextInputShouldReturn(self) ?? true
    }
    
    open func textInputShouldClear(textInput: TextInput) -> Bool {
        clearError()
        return delegate?.OCTextInputShouldClear(self) ?? true
    }
}

public protocol TextInput {
    var view: UIView { get }
    
    var currentText: String? { get set }
    var font: UIFont? { get set }
    var textColor: UIColor? { get set }
    weak var textInputDelegate: TextInputDelegate? { get set }
    var currentSelectedTextRange: UITextRange? { get set }
    var currentBeginningOfDocument: UITextPosition? { get }
    
    func changeReturnKeyType(with newReturnKeyType: UIReturnKeyType)
    func currentPosition(from: UITextPosition, offset: Int) -> UITextPosition?
}

public extension TextInput where Self: UIView {
    var view: UIView {
        return self
    }
}

public protocol TextInputDelegate: class {
    func textInputDidBeginEditing(textInput: TextInput)
    func textInputDidEndEditing(textInput: TextInput)
    func textInputDidChange(textInput: TextInput)
    func textInput(textInput: TextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    func textInputShouldBeginEditing(textInput: TextInput) -> Bool
    func textInputShouldEndEditing(textInput: TextInput) -> Bool
    func textInputShouldReturn(textInput: TextInput) -> Bool
    func textInputShouldClear(textInput: TextInput) -> Bool
}

public extension TextInputDelegate {
    func textInputDidBeginEditing(textInput: TextInput) {}
    func textInputDidEndEditing(textInput: TextInput) {}
    func textInputDidChange(textInput: TextInput) {}
    func textInput(textInput: TextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { return true }
    func textInputShouldBeginEditing(textInput: TextInput) -> Bool { return true }
    func textInputShouldEndEditing(textInput: TextInput) -> Bool { return true }
    func textInputShouldReturn(textInput: TextInput) -> Bool { return true }
    func textInputShouldClear(textInput: TextInput) -> Bool { return true }
}

public protocol TextInputError {
    func configureErrorState(with message: String?)
    func removeErrorHintMessage()
}
