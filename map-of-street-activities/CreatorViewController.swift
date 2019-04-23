//
//  CreatorViewController.swift
//  map-of-street-activities
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class CreatorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var token: String?
    var email: String?
    
    @IBOutlet weak var inputTitleField: UITextField!
    @IBOutlet weak var inputAddressField: UITextField!
    @IBOutlet weak var inputLatitudeField: UITextField!
    @IBOutlet weak var inputLongitudeField: UITextField!
    @IBOutlet weak var inputDateField: UITextField!
    @IBOutlet weak var inputCompanyField: UITextField!
    @IBOutlet weak var inputStartTimeField: UITextField!
    @IBOutlet weak var inputCategoryField: UITextField!
    @IBOutlet weak var inputDescriptionField: UITextView!
    
    private var datePicker: UIDatePicker?
    private var categoryPicker = UIPickerView()
    
    let myPickerData: Array<String> = ["ball", "business events", "cinema", "circus", "comedy-club", "concert", "dance trainings", "education",                                             "evening", "exhibition", "fashion", "festival", "flashmob", "games", "global", "holiday", "kids", "kvn", "magic",                                    "masquerade", "meeting", "night", "open", "other", "party", "permanent exhibitions", "photo", "presentation",                                        "quest", "show", "social activity", "speed-dating", "sport", "stand-up", "theater", "tour", "whatever"]
    
    @IBAction func createEventButton(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://85.143.172.4:81/check-publishing-rights")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "authToken": token!
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
                    
                    let dict = utf8Representation.toJSON() as? [String: Bool]
                    
                    if dict!["canPublish"]! != true {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Insufficient permissions", message: "You are not allowed to host your own events", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "I want to get them", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            let noAction = UIAlertAction(title: "I don't want", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("NO")
                            }
                            
                            alertController.addAction(okAction)
                            alertController.addAction(noAction)
                            
                            if okAction.isEnabled {
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let newViewController = storyBoard.instantiateViewController(withIdentifier: "settingsController")
                                self.present(newViewController, animated: true, completion: nil)
                            }
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            return
                        }
                    }
                } else {
                    print("No readable data received in response ")
                }
            }
            task.resume()
        } catch {
            print("Something was wrong with post request for checking rights")
        }
        
        
        if inputTitleField!.text == "" || inputAddressField.text! == "" || inputCompanyField.text! == "" || inputDescriptionField.text! == "" || inputLatitudeField.text! == "" || inputLongitudeField.text! == "" || inputDateField.text! == "" || inputStartTimeField.text! == "" || inputCategoryField.text! == "" {
            let alertController = UIAlertController(title: "Empty fields detected", message: "All input fields are required by the user", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                UIAlertAction in NSLog("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if Double(inputLatitudeField.text!) == nil || Double(inputLongitudeField.text!) == nil {
            let alertController = UIAlertController(title: "Coordinate type error", message: "Coordinates must be real numbers", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                UIAlertAction in NSLog("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let allMatches = matches(for: "(\\d{2}:\\d{2})", in: inputStartTimeField.text! as String)
        
        if allMatches.count == 0 {
            let alertController = UIAlertController(title: "Invalid time format", message: "Time must be entered according to the pattern: HH:mm", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                UIAlertAction in NSLog("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        var request1 = URLRequest(url: URL(string: "http://85.143.172.4:81/activities")!)
        
        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request1.httpMethod = "POST"
        
        let params1: [String: String] = [
            "title": inputTitleField.text!,
            "locationName": inputAddressField.text!,
            "coordsLat": inputLatitudeField.text!,
            "coordsLon": inputLongitudeField.text!,
            "company": inputCompanyField.text!,
            "description": inputDescriptionField.text!,
            "date": inputDateField.text!,
            "timeStart": inputStartTimeField.text!,
            "categories": inputCategoryField.text!,
            "authToken": token!,
        ]
        
        let encoder1 = JSONEncoder()
        
        do {
            request1.httpBody = try encoder1.encode(params1)
    
            let config1 = URLSessionConfiguration.default
            let session1 = URLSession(configuration: config1)
            let task1 = session1.dataTask(with: request1) { (responseData, response, responseError) in
                guard responseError == nil else {
                    print(responseError as Any)
                    return
                }
                
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    let dict = utf8Representation.toJSON() as? [String: String]
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async{
                            for view in self.view.subviews {
                                if let textField = view as? UITextField {
                                    textField.text = ""
                                }
                            }
                            self.inputDescriptionField.text! = ""
                            let alertController = UIAlertController(title: "Done", message: "Your event has been created", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            let alertController = UIAlertController(title: "Rejected", message: "INVALID_AUTH", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    print("No readable data received in response")
                }
            }
            task1.resume()
        } catch {
            print("Something was wrong with post request for creatinq event")
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let finalResult = results.map {
                String(text[Range($0.range, in: text)!])
            }
            return finalResult
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
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
        inputCategoryField.text! = myPickerData[row]
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        inputDateField.text! = dateFormatter.string(from: datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegistrationViewController.dateChanged(datePicker:)), for: .valueChanged)
        inputDateField.inputView = datePicker
        
        inputCategoryField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
        fetchAuthToken()
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
