//
//  RegistrationViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var inputFirstNameField: UITextField!
    
    @IBOutlet weak var inputLastNameField: UITextField!
    
    
    let myPickerData: Array<String> = ["Male", "Female", "Rather not tell"]
    
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
    
    @IBOutlet weak var inputConfrirmPasswordField: UITextField!
    
    @IBAction func buttonCreateAccount(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://localhost/users")!)
        
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
            let task = session.dataTask(with: request) { (responseData, response, responseError) in
                guard responseError == nil else {
                    print(responseError as Any)
                    return
                }
                
                // APIs usually respond with the data you just sent in your POST request
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    
                    if utf8Representation == "{\"status\": \"OK\"}" {
                        DispatchQueue.main.async{
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "mapController") as! MapViewController
                            self.present(newViewController, animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            let alertController = UIAlertController(title: "Ooops", message: "This e-mail is already in use", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Correct e-mail adress", style: UIAlertAction.Style.default) {
                                UIAlertAction in
                                NSLog("OK")
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                } else {
                    print("no readable data received in response")
                }
            }
            
            task.resume()
        } catch {
            print("Что-то всё же пошло не так... Но что? I have no idea!")
        }
        
       
        
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegistrationViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        inputDateOfBirthField.inputView = datePicker
        
        inputGenderField.inputView = genderPicker
        
        genderPicker.delegate = self
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        inputDateOfBirthField.text = dateFormatter.string(from: datePicker.date)
        
        view.endEditing(true)
    }
}
