//
//  SecondViewController.swift
//  What Movie Today
//
//  Created by Gad on 05/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButton(_ sender: Any) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": xsrfCookie!.value
        ]
        AF.request("http://127.0.0.1:8000/api/v1/rest-auth/logout/", method: .post, headers: headers).responseString { (response) in
            print("response", response)
        }
        //switching to login screen
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! UIViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
}

