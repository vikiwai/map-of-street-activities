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
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    var activities: [Activity] = []
    
    // The location manager will update the delegate function.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    // Create a CLLocationManager
    let locationManager = CLLocationManager()
    
    func loadInitialData() {
        let request = URLRequest(url: URL(string: "http://localhost/activities")!)
        
        print("request: ", request as Any)
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                print("error: ", responseError as Any)
                return
            }
            
            print("data: ", responseData!)
            
            let decoder = JSONDecoder()
            
            do {
                let array = try decoder.decode([Activity].self, from: responseData!)
                
                DispatchQueue.main.async {
                    self.activities = array
                    
                    self.mapView.addAnnotations(self.activities)
                }
            } catch {
                print("shit...", error)
            }
        }
        
        task.resume()
    }
    

    
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

        loadInitialData()
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



/*
 let regionRadius: CLLocationDistance = 1000
 
 func centerMapOnLocation(location: CLLocation) {
 let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
 latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
 mapView.setRegion(coordinateRegion, animated: true)
 }
 */

/*
 // show event on map
 let activity = Activity(title: "Honey festival",
 locationName: "Moscow",
 discipline: "Free",
 coordinate: CLLocationCoordinate2D(latitude: 55.735190, longitude: 37.607971),
 company: "Rozetka")
 
 mapView.addAnnotation(activity)
 */

