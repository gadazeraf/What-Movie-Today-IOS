//
//  FirstViewController.swift
//  What Movie Today
//
//  Created by Gad on 05/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire

var cxsrfCookie: HTTPCookie? = nil

class FirstViewController: UIViewController {
    
    var height: CGFloat = 0
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let URL_USER_LOGIN = "https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/login/"
    
    let defaultValues = UserDefaults.standard
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            print("cookie", cookie.value)
            if cookie.name == "csrftoken" { cxsrfCookie = cookie
                print("crsf", cookie.value)
                // break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.alpha = 0
    }
    
    
    @IBAction func buttonSignUp(_ sender: Any) {
        let SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.present(SignUpViewController, animated: true, completion: nil)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    //the button action function
    @IBAction func buttonLogin(_ sender: UIButton) {

        //getting the username and password
        let parameters: Parameters=[
            "username":textFieldUserName.text!,
            "password":textFieldPassword.text!
        ]
        
        var token = ""
        if let cookie = cxsrfCookie {
            token = cookie.value
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": token,
            "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/login"
        ]
        
        //making a post request
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5)
        activityIndicator.startAnimating()
        AF.request(URL_USER_LOGIN, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                switch response.result {
                case let .success(value):
                    let jsonData = value as! NSDictionary
                    if jsonData.value(forKey: "key") != nil {
                        
                        //switching the screen
                        let RateMovieViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateMovieViewController") as! RateMovieViewController
                        self.present(RateMovieViewController, animated: true, completion: nil)
                    }
                    else {
                        self.errorLabel.alpha = 1
                    }
                case .failure(_):
                    //error message in case of invalid credential
                    print("error credentials")
                }
                activityIndicator.stopAnimating()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

