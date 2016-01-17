//
//  MapViewContoller.swift
//  On The Map
//
//  Created by Laura Evans on 12/17/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Define Variables
    var locations: [OTMStudentInformation] = [OTMStudentInformation]()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        OTMClient.sharedInstance().loadStudentInformation { (result, errorString) -> Void in
            if let locations = result {
                dispatch_async(dispatch_get_main_queue(), {
                    self.locations = locations
                    self.loadLocations()
                })
            } else {
                
                let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel) { (action) in }
                alertController.addAction(dismissAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
        
        mapView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Refresh View
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
    
    //MARK - Load Locations on Map
    func loadLocations() {
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for location in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }

        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}
