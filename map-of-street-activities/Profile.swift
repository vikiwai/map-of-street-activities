//
//  Profile.swift
//  map-of-street-activities
//
//  server hostname — 85.143.173.40, port:81
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import Foundation
import MapKit

class Profile: NSObject, Decodable {
    let firstName: String
    let lastName: String
    let birthDate: String
    let email: String
    let password: String
    let canPublish: Bool
    let gender: String
}
