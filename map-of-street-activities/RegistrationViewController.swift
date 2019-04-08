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
    
    
    let myPickerData: Array<String> = ["Male", "Female"]
    
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
