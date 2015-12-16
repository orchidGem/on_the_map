
//
//  OTMConvinience.swift
//  On The Map
//
//  Created by Laura Evans on 12/1/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {
    
    func createSession(hostViewController: LoginViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        print(hostViewController.usernameTextField.text)
        
        
//        let username = hostViewController.usernameTextField.text!
//        let password = hostViewController.passwordTextField.text!
        
        let username = "laura.evans@ivieinc.com"
        let password = "Ilikelearning83!l"
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpbodyString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = httpbodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("login failed")
                return
            }

            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) // subset response data!
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            print("parsed data: \(parsedResult)")
            
            guard (parsedResult["error"]! == nil) else {
                print("No login for you!")
                completionHandler(success: false, errorString: parsedResult["error"] as? String)
                return
            }
            
            print("Yay login!")
            completionHandler(success: true, errorString: nil)
            
        }
        
        task.resume()
    }
}
