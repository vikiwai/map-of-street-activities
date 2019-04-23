//
//  AdminViewController.swift
//  map-of-street-activities
//
//  server hostname — 85.143.173.40, port:81
//
//  Copyright © 2019 Victoria Bunyaeva. All rights reserved.
//

import UIKit
import CoreData

class AdminViewController: UIViewController {
    var authToken: NSManagedObject?
    var token: String?
    var email: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    var applications: [String] = []
    
    func loadApplications() {
        let request = URLRequest(url: URL(string: "http://85.143.173.40:81/publishing-rights-applications")!)
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
                let array = try decoder.decode([String].self, from: responseData!)
                DispatchQueue.main.async {
                    self.applications = array
                    self.tableView.reloadData()
                }
            } catch {
                print("Something was wrong with loading applications", error)
            }
        }
        task.resume()
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.loadApplications()
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

extension AdminViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewTableViewCell
        cell?.information.text = applications[indexPath.row]
        cell?.cellDelegate = self
        cell?.index = indexPath
        return cell!
    }
}

extension AdminViewController: TableViewCell {
    func onClickCell(index: Int, answer: Bool) {
        var request = URLRequest(url: URL(string: "http://85.143.173.40:81/publishing-rights")!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var params: [String: String] = [:]
        
        if answer {
            params = [
                "authToken": token!,
                "email": applications[index],
                "canPublish": "true"
            ]
        } else {
            params = [
                "authToken": token!,
                "email": applications[index],
                "canPublish": "false"
            ]
        }
        
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
                        DispatchQueue.main.async{
                            print("Right")
                            self.loadApplications()
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    print("No readable data received in response")
                    let alertController = UIAlertController(title: "Rejected", message: "INVALID_AUTH", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) {
                        UIAlertAction in NSLog("OK")
                    }
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            task.resume()
        } catch {
            print("Something was wrong with changing rights applications")
        }
    }
}
