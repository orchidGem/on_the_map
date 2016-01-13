
//
//  ViewController.swift
//  On The Map
//
//  Created by Laura Evans on 12/1/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.hidden = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // TextField Delegate Behavior - Dismiss Keyboard on Return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func loginSubmit(sender: AnyObject) {
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            dispatch_async(dispatch_get_main_queue(), {
                self.errorLabel.text = "Username and Password are required."
                self.errorLabel.hidden = false
            })
            return
        }
        
        OTMClient.sharedInstance().createSession(self) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(tabBarController!, animated: true, completion: nil)
                    
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.errorLabel.text = errorString
                    self.errorLabel.hidden = false
                })
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        let svc = SFSafariViewController(URL: NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
        self.presentViewController(svc, animated: true, completion: nil)
    }
}