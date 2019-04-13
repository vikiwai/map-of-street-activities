//
//  MapViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    /**
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
     }
     */
 

    var activities: [Activity] = []
    
    func loadInitialData() {
        // Read the .json file into a Data object.
        guard let fileName = Bundle.main.path(forResource: "Activity", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // Obtain a JSON object
            let json = try? JSONSerialization.jsonObject(with: data),
            // Check that the JSON object is a dictionary with String keys and Any values.
            let dictionary = json as? [String: Any],
            // You’re only interested in the JSON object whose key is "data".
            let works = dictionary["data"] as? [[Any]]
        else {
                return
        }
        
        /*
        let validWorks = works.flatMap {
            Activity(json: $0)
        }
        */
        
        // activities.append(contentsOf: validWorks)
    }
    
    
    // The location manager will update the delegate function.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    // Create a CLLocationManager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Decide whether application will need the users location always or only when the apps in use
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // Set our location manager to update
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // show event on map
        let activity = Activity(title: "Honey festival",
                              locationName: "Moscow",
                              discipline: "Free",
                              coordinate: CLLocationCoordinate2D(latitude: 55.735190, longitude: 37.607971),
                              company: "Rozetka")
        
        mapView.addAnnotation(activity)
        
        loadInitialData()
        mapView.addAnnotations(activities)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // Return the view for each annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check that this annotation is an Activity object.
        // If it isn’t, return nil to let the map view use its default annotation view.
        guard let annotation = annotation as? Activity else {
            return nil
        }
        
        // To make markers appear.
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        // Check to see if a reusable annotation view is available before creating a new one.
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // Create a new MKMarkerAnnotationView object, if an annotation view could not be dequeued.
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
    }
}
