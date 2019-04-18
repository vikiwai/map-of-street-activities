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

    var authToken: String?
    
    
    @IBOutlet weak var inputOldPasswordField: UITextField!
    @IBOutlet weak var inputNewPasswordField: UITextField!
    
    @IBAction func changePassword(_ sender: Any) {
    }
    
    
    @IBOutlet weak var importImageButton: UIButton!
    
    var imageView: UIImageView!
    
    @IBAction func importImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        
        self.present(image, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        } else {
            print("Not possible to import")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var inputNameCompanyField: UITextField!
    @IBOutlet weak var inputPhoneNumberField: UITextField!
    
    @IBAction func getRights(_ sender: Any) {
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Hey", message: "Terminate the application?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in NSLog("Yes")
            
            UserDefaults.standard.set(false, forKey: self.authToken!)
            UserDefaults.standard.synchronize()
            
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
                authToken = (data.value(forKey: "token") as! String)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
