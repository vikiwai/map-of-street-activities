//
//  CreatorViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController {

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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
