//
//  StudentInformation.swift
//  On The Map
//
//  Created by Laura Evans on 12/20/15.
//  Copyright © 2015 Ivie. All rights reserved.
//

struct OTMStudentInformation {
    
    //Mark: Properties
    var objectId = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude: Float!
    var longitude: Float!
    var createdAt: AnyObject?
    var updatedAt: AnyObject?
    var acl: AnyObject?
    
    init(dictionary: [String : AnyObject]) {
        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Float
        longitude = dictionary["longitude"] as! Float
        createdAt = (dictionary["createdAt"] as? AnyObject?)!
        updatedAt = (dictionary["updatedAt"] as? AnyObject?)!
        acl = (dictionary["acl"] as? AnyObject?)!
    }
    
    static func moviesFromResults(results: [[String : AnyObject]]) -> [OTMStudentInformation] {
        
        var students = [OTMStudentInformation]()
        
        for result in results {
            students.append(OTMStudentInformation(dictionary: result))
        }
        
        return students
    }

}