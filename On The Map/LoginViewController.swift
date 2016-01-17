
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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

            let alertController = UIAlertController(title: nil, message: "Empty email or password", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
            alertController.addAction(dismissAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
            
        }
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
        
        OTMClient.sharedInstance().createSession(self) { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(tabBarController!, animated: true, completion: nil)
                    myActivityIndicator.removeFromSuperview()
                    
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    myActivityIndicator.removeFromSuperview()
                    
                    let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                    alertController.addAction(dismissAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    return
                })
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        let svc = SFSafariViewController(URL: NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
        self.presentViewController(svc, animated: true, completion: nil)
    }
}