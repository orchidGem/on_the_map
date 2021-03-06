//
//  InfoPostingViewController.swift
//  On The Map
//
//  Created by Laura Evans on 1/3/16.
//  Copyright © 2016 Ivie. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InfoPostingViewController: UIViewController {
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var urlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.delegate = self
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.hidden = true
        urlView.hidden = true
    }
    
    
    // Submit Location and show pin on map
    @IBAction func submitLocation(sender: AnyObject) {
        
        if locationTextField.text!.isEmpty {
            let emptyLocationAlertController = UIAlertController(title: nil, message: "Location is required", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
            emptyLocationAlertController.addAction(dismissAction)
            self.presentViewController(emptyLocationAlertController, animated: true, completion: nil)
            
            return
        }
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
        
        let location = locationTextField.text as String!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location, completionHandler:
            {(placemarks, error) in
                
                guard (error == nil) else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let geocodeAlertController = UIAlertController(title: nil, message: "Unable to get location", preferredStyle: .Alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                        geocodeAlertController.addAction(dismissAction)
                        self.presentViewController(geocodeAlertController, animated: true, completion: nil)
                        
                        myActivityIndicator.removeFromSuperview()
                    })
                    return
                }
                
                self.latitude = placemarks![0].location?.coordinate.latitude
                self.longitude = placemarks![0].location?.coordinate.longitude
                
                let zoomInLocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
                
                let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showURLView()
                    self.mapView.addAnnotation(annotation)
                    self.centerMapOnLocation(zoomInLocation)
                    myActivityIndicator.removeFromSuperview()
                })
                
         })
    }
    
    // Submit URL and post to Student Information
    @IBAction func submitURL(sender: AnyObject) {
        
        if urlTextField.text!.isEmpty {
            dispatch_async(dispatch_get_main_queue(), {
                let emptyUrlAlertController = UIAlertController(title: nil, message: "URL is required.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                emptyUrlAlertController.addAction(dismissAction)
                self.presentViewController(emptyUrlAlertController, animated: true, completion: nil)
            })
            return
        }
        
        OTMClient.sharedInstance().postStudentInformation(self) { (success, error) in
            
            if success {
                print("success")
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let postAlertController = UIAlertController(title: nil, message: "error creating pin: \(error!)", preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                    postAlertController.addAction(dismissAction)
                    self.presentViewController(postAlertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    // Cancel and go back to Map View
    @IBAction func cancelInfoPosting(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Show URL Input and Map and Hide Location Input
    func showURLView() {
        self.mapView.hidden = false
        self.locationView.hidden = true
        self.urlView.hidden = false
    }
}

extension InfoPostingViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let regionRadius: CLLocationDistance = 1000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
 
}

extension InfoPostingViewController: UITextFieldDelegate {
    
    // TextField Delegate Behavior
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        return true
    }
}
