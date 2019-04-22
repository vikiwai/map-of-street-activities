//
//  CreatorViewController.swift
//  map-of-street-activities
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class CreatorViewController: UIViewController {

    var token: String?
    var email: String?
    
    @IBOutlet weak var inputTitleField: UITextField!
    @IBOutlet weak var inputAddressField: UITextField!
    @IBOutlet weak var inputLatitudeField: UITextField!
    @IBOutlet weak var inputLongitudeField: UITextField!
    @IBOutlet weak var inputDateField: UITextField!
    @IBOutlet weak var inputCompanyField: UITextField!
    @IBOutlet weak var inputStartTimeField: UITextField!
    @IBOutlet weak var inputDurationField: UITextField!
    @IBOutlet weak var inputDescriptionField: UITextView!
    
    @IBAction func createEventButton(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://85.143.172.4:81/activities")!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "title": inputTitleField.text!,
            "locationName": inputAddressField.text!,
            "coordsLat": inputLatitudeField.text!,
            "coordsLon": inputLongitudeField.text!,
            "company": inputCompanyField.text!,
            "description": inputDescriptionField.text!,
            "date": inputDateField.text!,
            "timeStart": inputStartTimeField.text!,
            "categories": inputDurationField.text!,
            "authToken": token!,
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
                    else {
                        DispatchQueue.main.async{
                            let alertController = UIAlertController(title: "Ooops", message: "Smth was wrong...", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Correct", style: UIAlertAction.Style.default) {
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
            task.resume()
        } catch {
            print("Something was wrong")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
