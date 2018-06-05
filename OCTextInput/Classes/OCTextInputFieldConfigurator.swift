
import UIKit

public struct OCTextInputFieldConfigurator {
    
    //MARK:Field Type
    public enum OCTextInputType {
        case standard
        case email
        case password
        case numeric
        case selection
        case multiline
        case generic(textInput: TextInput)
    }
    
    static func configure(with type: OCTextInputType) -> TextInput {
        switch type {
        case .standard:
            return OCTextInputTextConfigurator.generate()
        case .email:
            return OCTextInputEmailConfigurator.generate()
        case .password:
            return OCTextInputPasswordConfigurator.generate()
        case .numeric:
            return OCTextInputNumericConfigurator.generate()
        case .selection:
            return OCTextInputSelectionConfigurator.generate()
        case .multiline:
            return OCTextInputMultilineConfigurator.generate()
        case .generic(let textInput):
            return textInput
        }
    }
}

fileprivate struct OCTextInputTextConfigurator {
    
    static func generate() -> TextInput {
        let textField = OCTextField()
            textField.clearButtonMode = .whileEditing
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        return textField
    }
}

fileprivate struct OCTextInputEmailConfigurator {
    
    static func generate() -> TextInput {
        let textField = OCTextField()
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .emailAddress
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        return textField
    }
}

fileprivate struct OCTextInputPasswordConfigurator {
    
    static func generate() -> TextInput {
        
        let textField = OCTextField()
            textField.rightViewMode = .whileEditing
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .none
       
        let normalImage = UIImage(named: "cm_icon_input_eye_normal", in: Bundle(for: OCTextInput.self), compatibleWith: nil)
        
        let selectedImage = UIImage(named: "cm_icon_input_eye_selected", in: Bundle(for: OCTextInput.self), compatibleWith: nil)
        
        
        let disclosureButton = UIButton(type: .custom)
            disclosureButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
            disclosureButton.setImage(normalImage, for: .normal)
            disclosureButton.setImage(selectedImage, for: .selected)
        
        textField.add(disclosureButton: disclosureButton) {
            disclosureButton.isSelected = !disclosureButton.isSelected
            textField.resignFirstResponder()
            textField.isSecureTextEntry = !textField.isSecureTextEntry
            textField.becomeFirstResponder()
        }
        return textField
    }
}

fileprivate struct OCTextInputNumericConfigurator {
    
    static func generate() -> TextInput {
        let textField = OCTextField()
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .decimalPad
            textField.autocorrectionType = .no
        return textField
    }
}

fileprivate struct OCTextInputSelectionConfigurator {
    
    static func generate() -> TextInput {
        
        let arrowImageView = UIImageView(image: UIImage(named: "disclosure", in: Bundle(for: OCTextInput.self), compatibleWith: nil))
        
        let textField = OCTextField()
            textField.rightView = arrowImageView
            textField.rightViewMode = .always
            textField.isUserInteractionEnabled = false
        return textField
    }
}

fileprivate struct OCTextInputMultilineConfigurator {
    
    static func generate() -> TextInput {
        let textView = OCTextEdit()
            textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)//.zero
            textView.backgroundColor = .clear
            textView.isScrollEnabled = false
            textView.autocorrectionType = .no
        return textView
    }
}
