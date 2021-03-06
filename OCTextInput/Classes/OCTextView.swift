import UIKit

final internal class OCTextView: UITextView {
    
    weak var textInputDelegate: TextInputDelegate?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        delegate = self
    }
    
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
}

extension OCTextView: TextInput {
    
    var currentText: String? {
        get { return text }
        set { self.text = newValue }
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        get { return typingAttributes }
        set { self.typingAttributes = textAttributes }
    }
    
    var currentSelectedTextRange: UITextRange? {
        get { return self.selectedTextRange }
        set { self.selectedTextRange = newValue }
    }
    
    public var currentBeginningOfDocument: UITextPosition? {
        return self.beginningOfDocument
    }
    
    func changeReturnKeyType(with newReturnKeyType: UIReturnKeyType) {
        returnKeyType = newReturnKeyType
    }
    
    func currentPosition(from: UITextPosition, offset: Int) -> UITextPosition? {
        return position(from: from, offset: offset)
    }
}

extension OCTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textInputDelegate?.textInputDidBeginEditing(textInput: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textInputDelegate?.textInputDidEndEditing(textInput: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textInputDelegate?.textInputDidChange(textInput: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return textInputDelegate?.textInputShouldReturn(textInput: self) ?? true
        }
        return textInputDelegate?.textInput(textInput: self, shouldChangeCharactersInRange: range, replacementString: text) ?? true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return textInputDelegate?.textInputShouldBeginEditing(textInput: self) ?? true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return textInputDelegate?.textInputShouldEndEditing(textInput: self) ?? true
    }
}

