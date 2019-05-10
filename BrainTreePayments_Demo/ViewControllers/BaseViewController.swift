//
//  BaseViewController.swift
//  BTOFF
//
//  Created by LogicalWings Mac on 05/09/18.
//  Copyright © 2018 LogicalWings Mac. All rights reserved.
//

import UIKit
import Toast_Swift

class BaseViewController: UIViewController,ApiCallbacks {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func makeTost(_ message: String) {
        self.view.makeToast(message.localized(), duration: 3.0, position: .bottom)
    }
    
    func serverResponseMessages(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(title: "done".localized(), style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        // add a toolbar with a done button above the number pad
        textField.inputAccessoryView = keypadToolbar
    }
    
    func givePlaceholder(textField:UITextField,placeHolderString:String){
        textField.placeholder = placeHolderString
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailStr)
    }
    
    // Mark: Api Callbacks
    
    func onHttpResponse(request: ApiRequest, data: Any) {
        
    }
    
    func onHttpError(error: String) {
        
        //DispatchQueue.main.sync {
            
            self.serverResponseMessages(error)
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
