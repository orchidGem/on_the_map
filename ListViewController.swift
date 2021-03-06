//
//  ListViewController.swift
//  On The Map
//
//  Created by Laura Evans on 12/28/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.dataSource = self
        listTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        OTMClient.sharedInstance().loadStudentInformation { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.listTableView.reloadData()
                })
            } else {
                let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                alertController.addAction(dismissAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return

            }
        }
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.viewWillAppear(true)
    }
    
    // Logout
    @IBAction func logOut(sender: AnyObject) {
        OTMClient.sharedInstance().deleteSession() { (success, error) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginController")
                    self.presentViewController(loginViewController!, animated: true, completion: nil)
                    
                })
            } else {
                print("error logging out")
            }
        }
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMStudentInformation.allStudentInformation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell") as UITableViewCell!
        let location = OTMStudentInformation.allStudentInformation[indexPath.row]
        
        cell.textLabel!.text = "\(location.firstName) \(location.lastName)"
        cell.imageView!.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        if let url = OTMStudentInformation.allStudentInformation[indexPath.row].mediaURL as String? {
            app.openURL(NSURL(string: url)!)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}