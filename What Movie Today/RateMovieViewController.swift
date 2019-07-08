//
//  RateMovieViewController.swift
//  What Movie Today
//
//  Created by Gad on 05/07/2019.
//  Copyright © 2019 Azeraf. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import YoutubePlayer_in_WKWebView

class RateMovieViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var divisor: CGFloat!
    var currentMovie: String = ""
    var xsrfCookie: HTTPCookie? = nil
    
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var imgCardBis: UIImageView!
    
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var cardBisLabel: UILabel!
    
    @IBOutlet weak var cardBis: Card!
    @IBOutlet weak var card: Card!
    
    
    //Mark - popup detail
    @IBOutlet weak var popupView: UIScrollView!
    @IBOutlet weak var popupName: UILabel!
    //@IBOutlet weak var popupImg: UIImageView!
    @IBOutlet weak var popupTeaser: UILabel!
    @IBOutlet weak var popupYT: WKYTPlayerView!
    @IBOutlet weak var popupStack: UIStackView!
    
    //Mark - viewDidload
    
    override func viewDidLoad() {
        super.viewDidLoad()
        divisor = (view.frame.width / 2) / 0.61
        calculateCard(label: cardLabel, img: imgCard)
        cardBis.alpha = 0
        // Do any additional setup after loading the view.
        print("sizeA", popupStack.frame.height)
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            print("cookie", cookie.value)
            if cookie.name == "csrftoken" { xsrfCookie = cookie
                print("crsf", cookie.value)
                break
            }
        }
    }
    
    func calculateCard(label: UILabel, img: UIImageView) {
        var imgRqst : String?
        let activityIndicator = UIActivityIndicatorView(style: .gray) // Create the activity indicator
        view.addSubview(activityIndicator) // add it as a  subview
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5) // put in the middle
        activityIndicator.startAnimating()
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
                    let data = jsonData[Int.random(in: 0 ... 100)] as! NSDictionary
                    print("json", data.value(forKey: "Name")!)
                    if let name = data.value(forKey: "Name") {
                        let nameb = name as? String ?? ""
                        let newString = nameb.replacingOccurrences(of: " ", with: "+")
                        let finalString = newString + "+Movie"
                        print("nameb", finalString)
                        imgRqst = "https://serpapi.com/search.json?q=" + finalString + "&tbm=isch&ijn=0&api_key=0462fb563e312cee95ddd23e393e3d2b05aa12afe21bb4e07779f7c37da03e50"
                        label.text = nameb
                        self.currentMovie = nameb
                        self.popupName.text = nameb
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
                                    //self.popupImg.download(string: imgLinked.value(forKey: "original") as! String)
                                    //let data = jsonData[0] as! NSDictionary
                                    //print("json", data.value(forKey: "Name")!)
                                case .failure(_):
                                    //error message in case of invalid credential
                                    label.text = "Error api google"
                                }
                                if let teaser = data.value(forKey: "wTeaser") {
                                    self.popupTeaser.text = teaser as! String
                                    print("teaser", self.popupTeaser.text as! String)
                                }
                                if let yID = data.value(forKey: "yID") {
                                   let id = yID as! String
                                    print("id", id)
                                    self.popupYT.load(withVideoId: id)

                                }
                                print("sizeB", self.popupStack.frame.height)
                                self.popupView.updateContentView()
                                activityIndicator.stopAnimating()
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
    
    @IBAction func cardTap(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.popupView.alpha = 1
        }
    }
    @IBAction func cardBisTap(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.popupView.alpha = 1
        }
    }
    
    @IBAction func closePopup(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.popupView.alpha = 0
        }
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
                else {
                    UIView.animate(withDuration: 0.3) {
                        card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                        card.transform = .identity
                    }
                    return
                }
            }
        }
    }
    
    func like_swipe(name: String) {
        
        let parameters: Parameters = [
            "name": name
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": xsrfCookie!.value
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

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
        print("size", contentSize.height)
    }
}
