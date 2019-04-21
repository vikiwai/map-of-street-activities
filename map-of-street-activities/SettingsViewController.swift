//
//  SettingsViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var authToken: NSManagedObject?
    
    var token: String?
    var email: String?
    
    @IBOutlet weak var inputOldPasswordField: UITextField!
    @IBOutlet weak var inputNewPasswordField: UITextField!
    
    @IBAction func changePassword(_ sender: Any) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("fjjsn")
        fetchAuthToken()
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            let imageData = imageView.image!.jpegData(compressionQuality: 0.1)
            
            if imageData != nil{
                var request = URLRequest(url: URL(string:"http://vikiwai.local/userpic")!)
                
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
                    } else {
                        print("No readable data received in response")
                    }
                }
                task.resume()
                
            }
        } else {
            print("Not possible to import")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var inputEmailField: UITextField!
    @IBOutlet weak var inputNameCompanyField: UITextField!
    
    @IBAction func getRights(_ sender: Any) {
        var request = URLRequest(url: URL(string: "http://vikiwai.local/publishing-rights-applications")!)
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
                    // TODO: Already exist
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Complit", message: "Right are requested", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                            UIAlertAction in NSLog("OK")
                        }
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    print("Error")
                }
            }
            task.resume()
        } catch {
            print("Something was wrong")
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Hey", message: "Terminate the application?", preferredStyle: .alert)
        
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
