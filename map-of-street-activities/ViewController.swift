//
//  ViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 07/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var labelOfRequestRegistrationButton: UIButton!
    @IBOutlet weak var inputEmailField: UITextField!
    @IBOutlet weak var inputPasswordField: UITextField!
    
    var authToken: NSManagedObject?
    
    // Go to user registration
    @IBAction func requestRegistration(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registrationController") as! RegistrationViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    // Go to the main screen of the application if the user is already registered
    @IBAction func requestEntry(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://vikiwai.local/auth")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
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
                
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    
                    let dict = utf8Representation.toJSON() as? [String: String]
                    
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async {
                            self.save(token: dict!["token"]!, email: self.inputEmailField.text!)
                            
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tarBarController")
                            
                            self.present(newViewController, animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            let alertController = UIAlertController(title: "Ooops", message: "Wrong e-mail or password", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Fix", style: UIAlertAction.Style.default) {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func save(token: String, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Token", in: managedContext)!
        
        let thisToken = NSManagedObject(entity: entity, insertInto: managedContext)
        thisToken.setValue(token, forKeyPath: "token")
        thisToken.setValue(email, forKeyPath: "email")
        
        do {
            try managedContext.save()
            authToken = thisToken
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
