//
//  ListViewController.swift
//  On The Map
//
//  Created by Laura Evans on 12/28/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    var locations: [OTMStudentInformation] = [OTMStudentInformation]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.dataSource = self
        listTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        OTMClient.sharedInstance().loadStudentInformation { (result, errorString) -> Void in
            if let locations = result {
                self.locations = locations
                dispatch_async(dispatch_get_main_queue(), {
                    self.listTableView.reloadData()
                })
            } else {
                print(errorString)
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
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell") as UITableViewCell!
        let location = locations[indexPath.row]
        
        cell.textLabel!.text = "\(location.firstName) \(location.lastName)"
        cell.imageView!.image = UIImage(named: "pin")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        if let url = locations[indexPath.row].mediaURL as String? {
            app.openURL(NSURL(string: url)!)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}