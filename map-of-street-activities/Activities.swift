//
//  Activities.swift
//  map-of-street-activities
//
//  Created by vikiwai on 13/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import Foundation
import MapKit

class Activity: NSObject, MKAnnotation, Decodable {
    let titleA: String
    let locationName: String
    var coordsLat: Float
    var coordsLon: Float
    let company: String
    let wholeDescription: String
    let date: String
    let timeStart: String
    let creatorEmail: String
    let categories: Array<String>
    let id: String

    lazy var coordinate : CLLocationCoordinate2D = {
        return CLLocationCoordinate2D(latitude: Double(coordsLat), longitude: Double(coordsLon))
    }()
    
    init(titleA: String, locationName: String, coordsLat: Float, coordsLon: Float, company: String, wholeDescription: String, date: String, timeStart: String, creatorEmail: String, categories: Array<String>, id: String) {
        self.titleA = titleA
        self.locationName = locationName
        self.coordsLat = coordsLat
        self.coordsLon = coordsLon
        self.company = company
        self.wholeDescription = wholeDescription
        self.date = date
        self.timeStart = timeStart
        self.creatorEmail = creatorEmail
        self.categories = categories
        self.id = id
        
        super.init()
    }
    
    var title: String? {
        return titleA
    }
    
    var subtitle: String? {
        return locationName
    }
}
