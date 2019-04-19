//
//  AccountViewController.swift
//  map-of-street-activities
//
//  Created by vikiwai on 08/04/2019.
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class AccountViewController: UIViewController {

    var token: String?
    var email: String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAuthToken()
        
        imageView.downloaded(from: "http://vikiwai.local/userpic/" + email!)
        
        
        let request = URLRequest(url: URL(string: "http://vikiwai.local/profile/" + token!)!)
        print("request: ", request as Any)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                print("error: ", responseError as Any)
                return
            }
            
            print("data: ", responseData!)
            
            let decoder = JSONDecoder()
            
            do {
                let person = try decoder.decode(Profile.self, from: responseData!)
                
                DispatchQueue.main.async {
                    print(person)
                    self.textView.text = "Full name: \(person.firstName) \(person.lastName) \nGender: \(person.gender) \nDate of Birth: \(person.birthDate) \nE-mail: \(person.email) \nRight for creating event: \(person.canPublish)"
                }
            } catch {
                print("Something was wrong...", error)
            }
        }
        task.resume()
        
        
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
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let data = data, error == nil,
            let image = UIImage(data: data)
            else {
                return
            }
            
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else {
            return
        }
        downloaded(from: url, contentMode: mode)
    }
}



