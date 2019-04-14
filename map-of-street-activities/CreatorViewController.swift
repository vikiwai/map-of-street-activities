//
//  CreatorViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class CreatorViewController: UIViewController {

    var authToken: NSManagedObject?
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
