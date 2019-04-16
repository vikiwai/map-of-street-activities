//
//  RegistrationViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var authToken: NSManagedObject?
    
    @IBOutlet weak var inputFirstNameField: UITextField!
    @IBOutlet weak var inputLastNameField: UITextField!
    
    let myPickerData: Array<String> = ["Rather not tell", "Female", "Male"]
    
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
        inputGenderField.text = myPickerData[row]
    }

    @IBOutlet weak var inputDateOfBirthField: UITextField!
    @IBOutlet weak var inputGenderField: UITextField!
    
    private var datePicker: UIDatePicker?
    private var genderPicker = UIPickerView()
    
    @IBOutlet weak var inputEmailField: UITextField!
    @IBOutlet weak var inputPasswordField: UITextField!
    @IBOutlet weak var inputConfirmPasswordField: UITextField!
    
    var what: Bool = false
    
    @IBAction func buttonCreateAccount(_ sender: Any) {
        print("GO")
        passwordsСheck(what: &self.what)
        print(self.what)
        
        if !what {
            return
        }
        
        print("DKFJSKDAFHSJBFKL")
        
        var request = URLRequest(url: URL(string: "http://vikiwai.local/users")!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "firstName": inputFirstNameField.text!,
            "lastName": inputLastNameField.text!,
            "birthDate": inputDateOfBirthField.text!,
            "gender": inputGenderField.text!,
            "email": inputEmailField.text!,
            "password": inputPasswordField.text!
        ]
        
        let encoder = JSONEncoder()
        
        do {
            request.httpBody = try encoder.encode(params)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) {
                (responseData, response, responseError) in guard responseError == nil else {
                    print(responseError as Any)
                    return
                }
                
                // APIs usually respond with the data you just sent in your POST request
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    
                    let dict = utf8Representation.toJSON() as? [String: String]
                    
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async {
                            self.save(token: dict!["token"]!)
                            print(self.authToken!)
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tarBarController")
                            self.present(newViewController, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Ooops", message: "This e-mail is already in use", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Correct e-mail adress", style: UIAlertAction.Style.default) {
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
            print("Something was wrong... I have no idea!")
            fatalError()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegistrationViewController.dateChanged(datePicker:)), for: .valueChanged)
        inputDateOfBirthField.inputView = datePicker
        
        inputGenderField.inputView = genderPicker
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        inputDateOfBirthField.text = dateFormatter.string(from: datePicker.date)
    }
    
    func passwordsСheck(what: inout Bool) {
        DispatchQueue.main.async {
            var confirmed = false
            var notEmpty = false
            
            if self.inputPasswordField.text! != self.inputConfirmPasswordField.text! {
                confirmed = false
                let alertController = UIAlertController(title: "Hey!", message: "Entered passwords don't match", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Confirm password again", style: UIAlertAction.Style.default) {
                    UIAlertAction in NSLog("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                confirmed = true
            }
            print(confirmed)
        
            // DispatchQueue.global()
            if self.inputPasswordField.text! == "" || self.inputConfirmPasswordField.text! == "" {
                notEmpty = false
                let alertController = UIAlertController(title: "Hey!", message: "Passwords field are empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Enter password again", style: UIAlertAction.Style.default) {
                    UIAlertAction in NSLog("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                notEmpty = true
            }
            print(notEmpty)
            
            print("_____________")
            
            if confirmed && notEmpty {
                self.what = true
            } else {
                self.what = false
            }
            
            print(self.what)
        }
    }
    
    func save(token: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Token", in: managedContext)!
        let thisToken = NSManagedObject(entity: entity, insertInto: managedContext)
        thisToken.setValue(token, forKeyPath: "token")
        
        do {
            try managedContext.save()
            authToken = thisToken
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

