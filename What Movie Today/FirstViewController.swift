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
    
    //The login script url make sure to write the ip instead of localhost
    //you can get the ip using ifconfig command in terminal
    let URL_USER_LOGIN = "https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/login/"
    
    //the defaultvalues to store user data
    let defaultValues = UserDefaults.standard
    
    //the connected views
    //don't copy instead connect the views using assistant editor
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hiding the navigation button
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //if user is already logged in switching to profile screen
        if defaultValues.string(forKey: "username") != nil{
            let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewcontroller") as! ProfileViewController
            self.navigationController?.pushViewController(profileViewController, animated: true)
            
        }
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
    
    
    
    //the button action function
    @IBAction func buttonLogin(_ sender: UIButton) {
        
        //getting the username and password
        let parameters: Parameters=[
            "username":textFieldUserName.text!,
            "password":textFieldPassword.text!
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": cxsrfCookie!.value,
            "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/login"
        ]
        
        //making a post request
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5) // put in the middle
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
                        //self.navigationController?.pushViewController(RateMovieViewController, animated: true)
                        self.present(RateMovieViewController, animated: true, completion: nil)
                        
                        //self.dismiss(animated: false, completion: nil)
                    }
                    else {
                        self.errorLabel.alpha = 1
                    }
                    
                // }
                case .failure(_):
                    //error message in case of invalid credential
                    //self.labelMessage.text = "Invalid username or password"
                    print("error")
                }
                activityIndicator.stopAnimating()
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

