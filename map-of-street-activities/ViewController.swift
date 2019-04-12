//
//  ViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 07/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var inputEmailField: UITextField!
    
    @IBOutlet weak var inputPasswordField: UITextField!
    
    @IBAction func requestRegistration(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registrationController") as! RegistrationViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func requestEntry(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

