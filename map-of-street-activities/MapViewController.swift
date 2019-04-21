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

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        //locationManager.stopUpdatingLocation()
        
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
                print("Something was wrong...", error)
            }
        }
        task.resume()
    }
    
    var toolBar = UIToolbar()
    
    @IBAction func filterActivities(_ sender: Any) {
        filtersPicker.delegate = self
        filtersPicker.backgroundColor = UIColor.white
        filtersPicker.setValue(UIColor.black, forKey: "textColor")
        filtersPicker.autoresizingMask = .flexibleWidth
        filtersPicker.contentMode = .center
        filtersPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(filtersPicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    
    var filtersPicker = UIPickerView()
    var filter: String = ""
    
    let myPickerData: Array<String> = ["morning", "day", "evening", "night", "whatever"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filter = myPickerData[row]
    }
    
    @objc func onDoneButtonTapped() {
        filtersPicker.removeFromSuperview()
        toolBar.removeFromSuperview()
        
        print(filter)
        
        switch filter {
        case "morning":
            var searchedActivities: [Activity] = []
            
            for result in activities {
                if result.timeStart > "06:00" && result.timeStart <= "12:00" {
                    searchedActivities.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.activities)
                self.mapView.addAnnotations(searchedActivities)
            }
        case "day":
            var searchedActivities: [Activity] = []
            
            for result in activities {
                if result.timeStart > "12:00" && result.timeStart <= "18:00" {
                    searchedActivities.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.activities)
                self.mapView.addAnnotations(searchedActivities)
            }
        case "evening":
            var searchedActivities: [Activity] = []
            
            for result in activities {
                if result.timeStart > "19:00" && result.timeStart <= "23:59" {
                    searchedActivities.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.activities)
                self.mapView.addAnnotations(searchedActivities)
            }
        case "night":
            var searchedActivities: [Activity] = []
            
            for result in activities {
                if result.timeStart >= "00:00" && result.timeStart <= "06:00" {
                    searchedActivities.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.activities)
                self.mapView.addAnnotations(searchedActivities)
            }
        default:
            return
        }
    }
    
    @IBOutlet weak var searchText: UITextField!
    
    
    @IBAction func searchActivities(_ sender: Any) {
        var searchedActivities: [Activity] = []
        
        for result in activities {
            if result.titleA.contains(String(searchText!.text!)) || searchText!.text! == "" {
                searchedActivities.append(result)
            }
        }
        
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.activities)
            self.mapView.addAnnotations(searchedActivities)
        }
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
            
        } else {
            print("Turn on location services or GPS")
        }

        loadInitialData()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let view: MKMarkerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = detailLabel.font.withSize(17)
        detailLabel.text = "Location name: \(annotation.locationName) \nCompany: \(annotation.company) \nDate: \(annotation.date) \nTime start: \(annotation.timeStart) \nDescription: \(annotation.wholeDescription)"
            view.detailCalloutAccessoryView = detailLabel

        return view
    }
}
