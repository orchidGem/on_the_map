
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
        
//        let username = hostViewController.usernameTextField.text!
//        let password = hostViewController.passwordTextField.text!
        
        let username = "laura.evans@ivieinc.com"
        let password = "Ilikelearning83!"
        
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
            
            guard (parsedResult["error"]! == nil) else {
                completionHandler(success: false, errorString: parsedResult["error"] as? String)
                return
            }
            
            completionHandler(success: true, errorString: nil)
            
        }
        
        task.resume()
    }
    
    
    func loadStudentInformation(completionHandler: (result: [OTMStudentInformation]?, errorString: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                print("error retrieiving student information")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            let students = OTMStudentInformation.moviesFromResults(results)
            
            completionHandler(result: students, errorString: nil)
            
            
        }
        task.resume()
    }
    
    
}
