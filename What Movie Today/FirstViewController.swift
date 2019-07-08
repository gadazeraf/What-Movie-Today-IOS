//
//  FirstViewController.swift
//  What Movie Today
//
//  Created by Gad on 05/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController {

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
    
    //the button action function
    @IBAction func buttonLogin(_ sender: UIButton) {
        
        //getting the username and password
        let parameters: Parameters=[
            "username":textFieldUserName.text!,
            "password":textFieldPassword.text!
        ]
        
        //making a post request
        AF.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                switch response.result {
                case let .success(value):
                    let jsonData = value as! NSDictionary
                    //print("jsonww", jsonData.value(forKey: "non_field_errors")!)
                    //let jsond = jsonData[0] as! NSDictionary
                    
                    let test = ""
                    if let weatherArray = jsonData as? [[String:Any]],
                        let weather = weatherArray.first {
                        print("weaether", weather["non_field_errors"]) // the value is an optional.
                    }
                    print("test", test)
                    if test == "Unable to log in with provided credentials." {
                        print("not log")
                    }
                    if test != "" {
                        print("fuck")
                    }
                   // if jsonData.value(forKey: "non_field_errors") != nil {
                        
                    //if there is no error
                    /*if(!(jsonData.value(forKey: "error") as! Bool)){
                        
                        //getting the user from response
                        let user = jsonData.value(forKey: "user") as! NSDictionary
                        
                        //getting user values
                        let userId = user.value(forKey: "id") as! Int
                        let userName = user.value(forKey: "username") as! String
                        let userEmail = user.value(forKey: "email") as! String
                        let userPhone = user.value(forKey: "phone") as! String
                        
                        //saving user values to defaults
                        self.defaultValues.set(userId, forKey: "userid")
                        self.defaultValues.set(userName, forKey: "username")
                        self.defaultValues.set(userEmail, forKey: "useremail")
                        self.defaultValues.set(userPhone, forKey: "userphone")*/
                        
                        //switching the screen
                        let RateMovieViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateMovieViewController") as! RateMovieViewController
                        self.navigationController?.pushViewController(RateMovieViewController, animated: true)
                        
                        self.dismiss(animated: false, completion: nil)
                    
                   // }
                case .failure(_):
                    //error message in case of invalid credential
                    //self.labelMessage.text = "Invalid username or password"
                    print("error")
                }
        }
    }
    
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

