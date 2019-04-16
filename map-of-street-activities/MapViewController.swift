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
    
    // Create a CLLocationManager
    var locationManager = CLLocationManager()
    
    // The location manager will update the delegate function.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
    }
    
    func loadInitialData() {
        let request = URLRequest(url: URL(string: "http://vikiwai.local/activities")!)
        
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
            print("URA")
        } else {
            print("Turn on location services or GPS")
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
