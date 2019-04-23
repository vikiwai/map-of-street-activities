//
//  SettingsViewController.swift
//  map-of-street-activities
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

protocol Note {
    func isUpload()
}

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var cellDelegate: Note?
    
    var authToken: NSManagedObject?
    var token: String?
    var email: String?
    
    @IBOutlet weak var inputConfirmNewPasswordField: UITextField!
    @IBOutlet weak var inputNewPasswordField: UITextField!
    
    @IBAction func changePassword(_ sender: Any) {
        if inputNewPasswordField.text! != inputConfirmNewPasswordField.text! {
            let alertController = UIAlertController(title: "Passwords don't match", message: "The entered passwords are different, so changes are not completed", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                UIAlertAction in NSLog("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        var request = URLRequest(url: URL(string: "http://85.143.172.4:81/password")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "authToken": token!,
            "password": inputNewPasswordField.text!
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
                
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    let dict = utf8Representation.toJSON() as? [String: String]
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Done", message: "Your password has been changed", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else if dict!["status"]! == "INVALID_AUTH" {
                        print("No readable data received in response")
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Failure", message: "INVALID_AUTH", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                    
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()
        } catch {
            print("Something was wrong with changing password")
        }
    }
    
    @IBOutlet weak var importImageButton: UIButton!
    
    var imageView: UIImageView = UIImageView()
    
    @IBAction func importImage(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        
        self.present(image, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        fetchAuthToken()
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.1)
            
            if imageData != nil{
                var request = URLRequest(url: URL(string:"http://85.143.172.4:81/userpic")!)
                
                request.httpMethod = "POST"
                
                let boundary = "vikabunyaevaiosprogrammistshootka"
                let contentType = String(format: "multipart/form-data; boundary=%@",boundary)
                request.addValue(contentType, forHTTPHeaderField: "Content-Type")
                
                var body = Data()
                
                body.append(String(format: "\r\n--%@\r\n",boundary).data(using: String.Encoding.utf8)!)
                body.append(String(format:"Content-Disposition: form-data; name=\"authToken\"\r\n\r\n").data(using: String.Encoding.utf8)!)
                body.append(token!.data(using: String.Encoding.utf8)!)
                
                body.append(String(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
                body.append(String(format:"Content-Disposition: form-data; name=\"userpic\"; filename=\"img.jpg\"\r\n").data(using: String.Encoding.utf8)!)
                body.append(String(format: "Content-Type: image/jpeg\r\n\r\n").data(using: String.Encoding.utf8)!)
                body.append(imageData!)
                body.append(String(format: "\r\n--%@--\r\n", boundary).data(using: String.Encoding.utf8)!)
                
                request.httpBody = body
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: request) { (responseData, response, responseError) in
                    guard responseError == nil else {
                        print(responseError as Any)
                        return
                    }
                    
                    if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                        print("response: ", utf8Representation)
                        
                        DispatchQueue.main.async {
                            self.cellDelegate?.isUpload()
                        
                            let alertController = UIAlertController(title: "Done", message: "The selected photo has been uploaded", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        print("No readable data received in response")
                        
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Failure", message: "Not possible to import photo", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                task.resume()
                
            }
        } else {
            print("Something was wrong with uploading photo")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var inputEmailField: UITextField!
    @IBOutlet weak var inputNameCompanyField: UITextField!
    
    @IBAction func getRights(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://85.143.172.4:81/publishing-rights-applications")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let params: [String: String] = [
            "authToken": token!
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
                
                if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                    print("response: ", utf8Representation)
                    let dict = utf8Representation.toJSON() as? [String: String]
                    if dict!["status"]! == "OK" {
                        DispatchQueue.main.async {
                            self.inputNameCompanyField.text! = ""
                            self.inputEmailField.text! = ""
                            let alertController = UIAlertController(title: "Done", message: "Rights to create your own events were requested", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                        
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else if dict!["status"]! == "ALREADY_APPLIED" {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Failure", message: "You already have rights to create events", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                                UIAlertAction in NSLog("OK")
                            }
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else if dict!["status"]! == "INVALID_AUTH" {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Failure", message: "INVALID_AUTH", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
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
            print("Something was wrong with post request for getting rights")
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Quit the application?", message: "Are you sure? User will lose authentication", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in NSLog("Yes")
            
            self.deleteData()
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "initController")
            self.present(newViewController, animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
            UIAlertAction in NSLog("No")
            return
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func aboutApp(_ sender: Any) {
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
    
    func deleteData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
