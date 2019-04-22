//
//  MapViewController.swift
//  map-of-street-activities
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var token: String?
    var email: String?
    
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
        let request = URLRequest(url: URL(string: "http://85.143.172.4:81/activities")!)
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
                print("Something was wrong!", error)
            }
        }
        task.resume()
    }
    
    var toolBar = UIToolbar()
    var segmentedControl = UISegmentedControl(items: ["Day-time", "Category"])
    
    @IBAction func filterActivities(_ sender: Any) {
        filtersPicker.delegate = self
        filtersPicker.backgroundColor = UIColor.white
        filtersPicker.setValue(UIColor.black, forKey: "textColor")
        filtersPicker.autoresizingMask = .flexibleWidth
        filtersPicker.contentMode = .center
        filtersPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 280, width: UIScreen.main.bounds.size.width, height: 186)
        self.view.addSubview(filtersPicker)
        
        segmentedControl.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 310, width: UIScreen.main.bounds.size.width, height: 30)
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(chooseFilters), for: .valueChanged)
        self.view.addSubview(segmentedControl)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 94, width: UIScreen.main.bounds.size.width, height: 45))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil), UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped)), UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)]
        self.view.addSubview(toolBar)
    }
    
    @objc func chooseFilters(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            myPickerData = ["morning", "day", "evening", "night", "whatever"]
            filtersPicker.reloadAllComponents()
            segmentedControl.selectedSegmentIndex = 0
        case 1:
            myPickerData = ["ball", "business events", "cinema", "circus", "comedy-club", "concert", "dance trainings", "education", "evening", "exhibition",
                            "fashion", "festival", "flashmob", "games", "global", "holiday", "kids", "kvn", "magic", "masquerade", "meeting", "night",
                            "open", "other", "party", "permanent exhibitions", "photo", "presentation", "quest", "show", "social activity", "speed-dating",
                            "sport", "stand-up", "theater", "tour"]
            filtersPicker.reloadAllComponents()
            segmentedControl.selectedSegmentIndex = 1
        default:
            break
        }
    }
    
    var filtersPicker = UIPickerView()
    var filter: String = ""
    
    var myPickerData: Array<String> = []
    
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
        segmentedControl.removeFromSuperview()
        
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
            var searchedActivities: [Activity] = []
            
            for result in activities {
                for category in result.categories {
                    if filter == category {
                        searchedActivities.append(result)
                        break
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.activities)
                self.mapView.addAnnotations(searchedActivities)
            }
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
    
    func fetchAuthToken() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                token = (data.value(forKey: "token") as! String)
                email = (data.value(forKey: "email") as! String)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        /*
        let starImage = UIImage(named: "star-7")
        let starButton = UIButton()
        starButton.setImage(starImage, for: .normal)
        view.rightCalloutAccessoryView = starButton
        */
        view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        
        /*
        let starButton = UIButton(type: UIButton.ButtonType.custom)
        starButton.setImage(UIImage(named: "star-7"), for: .normal)
        starButton.setImage(UIImage(named: "star-7"), for: .highlighted)
        view.rightCalloutAccessoryView = starButton
        */
        
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = detailLabel.font.withSize(17)
        detailLabel.text = "Location name: \(annotation.locationName) \nCompany: \(annotation.company) \nDate: \(annotation.date) \nTime start: \(annotation.timeStart) \nDescription: \(annotation.wholeDescription)"
        view.detailCalloutAccessoryView = detailLabel

        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let activity = view.annotation as! Activity
        let idToFavourites = activity.id
        
        fetchAuthToken()
        
        var request = URLRequest(url: URL(string: "http://85.143.172.4:81/favourites/" + email!)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "authToken": token!,
            "id": idToFavourites
        ]
        
        let encoder = JSONEncoder()
        
        do {
            request.httpBody = try encoder.encode(params)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else {
                    print(responseError as Any)
                    return
                }
                
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    let dict = utf8Representation.toJSON() as? [String: String]
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async{
                            print("DONE")
                        }
                    }
                } else {
                    print("No readable data received in response")
                }
            }
            task.resume()
        } catch {
            print("Something was wrong")
        }
    }
}
