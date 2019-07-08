//
//  SignUpViewController.swift
//  What Movie Today
//
//  Created by Gad on 08/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonSignup(_ sender: Any) {
        
        let parameters: Parameters=[
            "username":usernameTextField.text!,
            "password1":passwordTextField.text!,
            "password2":passwordTextField.text!,
            "email":emailTextField.text!
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": cxsrfCookie!.value,
            "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/registration"
        ]
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5)
        activityIndicator.startAnimating()
        AF.request("https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/registration/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
            {
                response in
                print(response)
                
                switch response.result {
                case let .success(value):
                    let jsonData = value as! NSDictionary
                    if jsonData.value(forKey: "key") != nil {
                    }
                    else {
                        self.errorLabel.text = "An obscur error occured"
                        self.errorLabel.alpha = 1
                        return
                    }
                case .failure(_):
                    print("error")
                    return
                }
                let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! FirstViewController
                self.present(ViewController, animated: true, completion: nil)
                
                let parameters: Parameters = [
                    "name": "harry potter"
                ]
                let sharedCookieStorage = HTTPCookieStorage.shared
                var csrfCookie: HTTPCookie? = nil

                for cookie in sharedCookieStorage.cookies! {
                    print("cookie", cookie.value)
                    if cookie.name == "csrftoken" { csrfCookie = cookie
                        print("crsf", cookie.value)
                        // break
                    }
                }
                
                let headers: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "X-CSRFToken": csrfCookie!.value,
                    "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/movies/"
                ]
                
                AF.request("https://what-movie-today-for-ios.herokuapp.com/api/v1/movies/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
                    print("response", response)
                }
                
                activityIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func buttonLogin(_ sender: Any) {
        let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! FirstViewController
        self.present(ViewController, animated: true, completion: nil)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }

}
