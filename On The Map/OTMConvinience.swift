
//
//  OTMConvinience.swift
//  On The Map
//
//  Created by Laura Evans on 12/1/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit
import MapKit

extension OTMClient {
    
    // Log Into Udacity
    func createSession(hostViewController: LoginViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let username = hostViewController.usernameTextField.text!
        let password = hostViewController.passwordTextField.text!
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpbodyString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = httpbodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Login Failed.")
                return
            }

            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5)) // subset response data!
            
            //print(NSString(data: newData!, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: true, errorString: "Login Failed:")
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard (parsedResult["error"]! == nil) else {
                completionHandler(success: false, errorString: parsedResult["error"] as? String)
                return
            }
            
            guard let accountInfo = parsedResult["account"] as? NSDictionary else {
                completionHandler(success: true, errorString: "Login Failed: Error parsing account information")
                print("error parsing account information")
                return
            }

            self.userID = accountInfo["key"] as? String
            completionHandler(success: true, errorString: nil)
            
        }
        
        task.resume()
    }
    
    // Delete Session / Logout
    func deleteSession(completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                print("error logging out")
                completionHandler(success: false, error: "error logging out")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            completionHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    
    func loadStudentInformation(completionHandler: (result: [OTMStudentInformation]?, errorString: String?) -> Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(result: nil, errorString: "Error retreiving student information")
                print("error retrieiving student information")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(result: nil, errorString: "Error parsing data")
                print("Could not parse the data as JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String : AnyObject]] else {
                completionHandler(result: nil, errorString: "Error loading student information")
                print("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            let students = OTMStudentInformation.studentsFromResults(results)
            
            completionHandler(result: students, errorString: nil)
            
            
        }
        
        task.resume()
    }
    
    
    func getUserData(completionHandler: (success: Bool, userData: AnyObject?, error: String?) -> Void)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.userID!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print("unable to get user information")
                completionHandler(success: false, userData: nil, error: "Unable to get user information")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(success: false, userData: nil, error: "Unable to get user information")
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let user = parsedResult["user"] else {
                completionHandler(success: false, userData: nil, error: "Unable to parse user information")
                print("error parsing user information")
                return
            }
            
            completionHandler(success: true, userData: user, error: nil)
            
        }
        
        task.resume()
    }
    
    
    func postStudentInformation(hostViewController: InfoPostingViewController, completionHandler: (success: Bool, error: String?) -> Void)
    {
        self.getUserData { (success, userData, error) -> Void in
            
            if error != nil { // Handle error...
                print("unable to get user information")
                completionHandler(success: false, error: "Unable to get user information")
                return
            }
            
            let uniqueKey = userData!["key"] as! String
            let firstname = userData!["first_name"] as! String
            let lastname =  userData!["last_name"] as! String
            let mapString = hostViewController.locationTextField.text!
            let mediaURL = hostViewController.urlTextField.text!
            let latitude = hostViewController.latitude
            let longitude = hostViewController.longitude
            
            let httpbodyString = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstname)\", \"lastName\": \"\(lastname)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = httpbodyString.dataUsingEncoding(NSUTF8StringEncoding)
    
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    print("error pinning location")
                    completionHandler(success: false, error: "error pinning location")
                    return
                }
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    completionHandler(success: false, error: "error pinning location")
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                guard (parsedResult["error"]! == nil) else {
                    print("error: \(parsedResult)")
                    completionHandler(success: false, error: parsedResult["error"] as? String)
                    return
                }
                
                completionHandler(success: true, error: nil)
            }
            task.resume()

            
        }

    }
    
    
    
}
