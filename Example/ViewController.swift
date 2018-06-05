//
//  ViewController.swift
//  Example

import UIKit
import OCTextInput

class ViewController: UIViewController, OCTextInputDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var tiDefault: OCTextInput!
    @IBOutlet weak var tiPassword: OCTextInput!
    @IBOutlet weak var tiEmail: OCTextInput!
    @IBOutlet weak var tiNumeric: OCTextInput!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup 
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:Addition
    private func initUI() {
        
        //simple
        tiDefault.accessibilityLabel = "Name"
        tiDefault.placeHolderText = "First name"
        tiDefault.type = .multiline
        tiDefault.characterCounter = CharacterCounter(min: 0, max: 32, visibleState: .always, observerType: ObserverType(type: .warn, info: "Check limit"))
        tiDefault.delegate = self
        
        //PassField with mask and "show/hide secret"
        tiPassword.accessibilityLabel = "Password"
        tiPassword.placeHolderText = "Password"
        tiPassword.type = .password
        tiPassword.characterCounter = CharacterCounter(min: 6, max: 14, visibleState: .active, observerType: ObserverType(type: .keep, info: "Check limit"))
        tiPassword.delegate = self
        
        //email
        tiEmail.accessibilityLabel = "Email"
        tiEmail.type = .email
        tiEmail.regEx = RegExCheck(expression : "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", errorMessage : "Enter valid Email")
        tiEmail.placeHolderText = "Email"
        tiEmail.delegate = self
        
        //
        tiNumeric.accessibilityLabel = "Pin"
        tiNumeric.placeHolderText = "Pin"
        tiNumeric.type = .numeric
        tiNumeric.characterCounter = CharacterCounter(min: 4, max: 8, visibleState: .always, observerType: ObserverType(type: .warn, info: nil))
    }
    
    func OCTextInputDidChange(OCTextInput: OCTextInput) {
        print("!!!!!OCTextInputDidChange")
    }
    
    func OCTextInputWillChangeValidState(_ OCTextInput: OCTextInput) {
        print("!!!!!OCTextInputWillChangeValidState")
    }
}

