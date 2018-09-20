import UIKit

final internal class OCTextField: UITextField {
    
    //MARK:Private members
    fileprivate var disclosureButtonAction: (() -> Void)?
    
    //Delegate
    weak var textInputDelegate: TextInputDelegate?
    
    var rightViewPadding: CGFloat
    var rightClearButtonPadding: CGFloat
    
    //MARK:Lifecycle
    
    override init(frame: CGRect) {
        
        self.rightViewPadding = OCTextInputDefaults().padding
        self.rightClearButtonPadding = OCTextInputDefaults.ClearButton().padding
        
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.rightViewPadding = OCTextInputDefaults().padding
        self.rightClearButtonPadding = OCTextInputDefaults.ClearButton().padding
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds).offsetBy(dx: rightViewPadding, dy: 0)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: bounds).offsetBy(dx: rightClearButtonPadding, dy: 0)
    }
    
    func add(disclosureButton button: UIButton, action: @escaping (() -> Void)) {
        let selector = #selector(disclosureButtonPressed)
        if disclosureButtonAction != nil, let previousButton = rightView as? UIButton {
            previousButton.removeTarget(self, action: selector, for: .touchUpInside)
        }
        disclosureButtonAction = action
        button.addTarget(self, action: selector, for: .touchUpInside)
        rightView = button
    }
    
    @objc fileprivate func disclosureButtonPressed() {
        disclosureButtonAction?()
    }
    
    @objc fileprivate func textFieldDidChange() {
        textInputDelegate?.textInputDidChange(textInput: self)
    }
}

extension OCTextField: TextInput {
    
    func changeReturnKeyType(with newReturnKeyType: UIReturnKeyType) {
        returnKeyType = newReturnKeyType
    }
    
    func currentPosition(from: UITextPosition, offset: Int) -> UITextPosition? {
        return position(from: from, offset: offset)
    }
    
    var currentText: String? {
        get { return text }
        set { self.text = newValue }
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        get { return typingAttributes ?? [:] }
        set { self.typingAttributes = textAttributes }
    }
    
    var currentSelectedTextRange: UITextRange? {
        get { return self.selectedTextRange }
        set { self.selectedTextRange = newValue }
    }
    
    public var currentBeginningOfDocument: UITextPosition? {
        get { return self.beginningOfDocument }
    }
}

extension OCTextField: TextInputError {
    
    func configureErrorState(with message: String?) {
        placeholder = message
    }
    
    func removeErrorHintMessage() {
        placeholder = nil
    }
}

extension OCTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textInputDelegate?.textInputDidBeginEditing(textInput: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textInputDelegate?.textInputDidEndEditing(textInput: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textInputDelegate?.textInput(textInput: self, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textInputDelegate?.textInputShouldBeginEditing(textInput: self) ?? true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textInputDelegate?.textInputShouldEndEditing(textInput: self) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textInputDelegate?.textInputShouldReturn(textInput: self) ?? true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return textInputDelegate?.textInputShouldClear(textInput: self) ?? true
    }
}
