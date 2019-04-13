//
//  Activities.swift
//  map-of-street-activities
//
//  Created by vikiwai on 13/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import Foundation
import MapKit

class Activity: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    // let discipline: String
    let coordinate: CLLocationCoordinate2D
    let company: String
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, company: String) {
        self.title = title
        self.locationName = locationName
        // self.discipline = discipline
        self.coordinate = coordinate
        self.company = company
        
        super.init()
    }
    
    init?(json: [Any]) {
        // 1
        self.title = json[16] as? String ?? "No Title"
        self.locationName = json[12] as! String
        //self.discipline = json[15] as! String
        // 2
        if let latitude = Double(json[18] as! String),
            let longitude = Double(json[19] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        self.company = json[10] as! String
    }
    
    var subtitle: String? {
        return locationName
    }
}
