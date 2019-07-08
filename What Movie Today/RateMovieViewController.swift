//
//  RateMovieViewController.swift
//  What Movie Today
//
//  Created by Gad on 05/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire

class RateMovieViewController: UIViewController {

    var divisor: CGFloat!
    var currentMovie: String = ""
    
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var imgCardBis: UIImageView!
    
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var cardBisLabel: UILabel!
    
    @IBOutlet weak var cardBis: Card!
    @IBOutlet weak var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        divisor = (view.frame.width / 2) / 0.61
        calculateCard(label: cardLabel, img: imgCard)
        cardBis.alpha = 0
        // Do any additional setup after loading the view.
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            print("cookie", cookie.value)
            if cookie.name == "csrftoken" { xsrfCookie = cookie
                print("crsf", cookie.value)
            }
        }
    }
    
    func calculateCard(label: UILabel, img: UIImageView) {
        var imgRqst : String?
        AF.request("http://127.0.0.1:8000/api/v1/newmovies/most", method: .get).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                switch response.result {
                case let .success(value):
                    let jsonData = value as! NSArray
                    print("json", jsonData[0])
                    let data = jsonData[Int.random(in: 0 ... 2)] as! NSDictionary
                    print("json", data.value(forKey: "Name")!)
                    if let name = data.value(forKey: "Name") {
                        let nameb = name as? String ?? "" + " Movie"
                        let newString = nameb.replacingOccurrences(of: " ", with: "+")
                        imgRqst = "https://serpapi.com/search.json?q=" + newString + "&tbm=isch&ijn=0&api_key=0462fb563e312cee95ddd23e393e3d2b05aa12afe21bb4e07779f7c37da03e50"
                        label.text = nameb
                        self.currentMovie = nameb
                        print(imgRqst!)
                        AF.request(imgRqst!, method: .get).responseJSON
                            {
                                response in
                                //printing response
                                print(response)
                                
                                //getting the json value from the server
                                switch response.result {
                                case let .success(value):
                                    let jsonData = value as! NSDictionary
                                    print("json", jsonData.value(forKey: "images_results")!)
                                    let imgLink = jsonData.value(forKey: "images_results") as! NSArray
                                    let imgLinked = imgLink[0] as! NSDictionary
                                    print("json api result", imgLinked.value(forKey: "original")!)
                                    img.download(string: imgLinked.value(forKey: "original") as! String)
                                    //let data = jsonData[0] as! NSDictionary
                                    //print("json", data.value(forKey: "Name")!)
                                case .failure(_):
                                    //error message in case of invalid credential
                                    label.text = "Error api google"
                                }
                        }
                        
                        
                    }
                case .failure(_):
                    //error message in case of invalid credential
                    label.text = "Invalid username or password"
                }
        }
        
        
    }
    

    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        generate_swipe(sender: sender, cardBis: self.cardBis, cardBisLabel: self.cardBisLabel, imgCardBis: self.imgCardBis)
    }
    
    @IBAction func panCardBis(_ sender: UIPanGestureRecognizer) {
        generate_swipe(sender: sender, cardBis: self.card, cardBisLabel: self.cardLabel, imgCardBis: self.imgCard)
    }
    
    func generate_swipe(sender: UIPanGestureRecognizer, cardBis: Card, cardBisLabel: UILabel, imgCardBis: UIImageView) {
        if let card = sender.view {
            let point = sender.translation(in: view)
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
            
            let xFromCenter = card.center.x - view.center.x
            
            card.transform = CGAffineTransform(rotationAngle: xFromCenter/divisor)
            
            
            if xFromCenter > 150 {
                print("like")
            }
            else if xFromCenter < -150 {
                print("dislike")
            }
            
            if sender.state == UIGestureRecognizer.State.ended {
                
                if card.center.x < 75 {
                    //left side
                    UIView.animate(withDuration: 0.3) {
                        card.center = CGPoint(x: card.center.x - 200, y: card.center.y)
                        card.alpha = 0
                        cardBis.alpha = 1
                        self.calculateCard(label: cardBisLabel, img: imgCardBis)
                        cardBisLabel.text = ""
                        imgCardBis.image = nil
                    }
                    card.transform = .identity
                    return
                }
                else if card.center.x > (view.frame.width - 75) {
                    //right side
                    UIView.animate(withDuration: 0.3) {
                        card.center = CGPoint(x: card.center.x + 200, y: card.center.y)
                        card.alpha = 0
                        cardBis.alpha = 1
                        self.like_swipe(name: self.currentMovie)
                        self.calculateCard(label: cardBisLabel, img: imgCardBis)
                        cardBisLabel.text = ""
                        imgCardBis.image = nil
                        
                    }
                    card.transform = .identity
                    return
                }
            }
        }
    }
    
    func like_swipe(name: String) {
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            print("cookie", cookie.value)
            if cookie.name == "csrftoken" { xsrfCookie = cookie
                print("crsf", cookie)
            }
        }
        
        let parameters: Parameters = [
            "name": name
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": "Zo2bCRptVKULssZAZtqlPYsRv2G6JLWvxGHyUeVWPGrMtAStsTFt5W5d1Kx6GKLE"
        ]
        
        print("token",headers["X-CSRFToken"]!)
        
        AF.request("http://127.0.0.1:8000/api/v1/movies/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
            print("response", response, String(data: response.request!.httpBody!, encoding: String.Encoding.utf8))
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

import SDWebImage

extension UIImageView {
    func download(string: String) {
        sd_setImage(with: URL(string: string), placeholderImage: UIImage(named: "imagePlaceholder"), options: SDWebImageOptions.highPriority, completed: nil)
    }
}
