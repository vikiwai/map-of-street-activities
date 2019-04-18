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
    var token: String?
    
    @IBAction func requestRegistration(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registrationController") as! RegistrationViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
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
                
                // APIs usually respond with the data you just sent in your POST request
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    
                    let dict = utf8Representation.toJSON() as? [String: String]
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async {
                            self.save(token: dict!["token"]!)
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
                    print("no readable data received in response")
                }
            }
            
            task.resume()
        } catch {
            print("Что-то всё же пошло не так... Но что? I have no idea!")
        }
    }
    
    override func viewDidLoad() {
        fetchAuthToken()
        self.hideKeyboardWhenTappedAround()
        
        print("View")
        if token == nil {
            super.viewDidLoad()
        } else {
            print("JFHJKFJFJFJFJFJFJF")
            DispatchQueue.main.async {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "tarBarController")
                self.present(newViewController, animated: true, completion: nil)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func save(token: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Token",
                                       in: managedContext)!
        
        let t = NSManagedObject(entity: entity,
                                insertInto: managedContext)
        
        t.setValue(token, forKeyPath: "token")
        
        do {
            try managedContext.save()
            authToken = t
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchAuthToken() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                token = (data.value(forKey: "token") as! String)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
