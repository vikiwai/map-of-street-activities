//
//  ViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 07/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var labelOfRequestRegistrationButton: UIButton!
    
    @IBOutlet weak var inputEmailField: UITextField!
    
    @IBOutlet weak var inputPasswordField: UITextField!
    
    @IBAction func requestRegistration(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "registrationController") as! RegistrationViewController
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func requestEntry(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://localhost/auth")!)
        
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
                        let authToken = dict!["token"]!
                        
                        DispatchQueue.main.async {
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "mapController") as! MapViewController
                            self.present(newViewController, animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            let alertController = UIAlertController(title: "Ooops", message: "Wrong e-mail or password", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Fix", style: UIAlertAction.Style.default) {
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: true) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
