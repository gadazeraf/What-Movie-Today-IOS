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

var xsrfCookie: HTTPCookie? = nil

class RateMovieViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var divisor: CGFloat!
    var currentMovie: String = ""
    
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
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            print("cookie", cookie.value)
            if cookie.name == "csrftoken" { xsrfCookie = cookie
                print("crsf", cookie.value)
                // break
            }
        }
        
        designCard(card: card)
        designCard(card: cardBis)
    }
    
    func designCard(card: Card)
    {
        card.layer.cornerRadius = 30
        card.clipsToBounds = true
        card.layer.shadowPath =
            UIBezierPath(roundedRect: card.bounds,
                         cornerRadius: card.layer.cornerRadius).cgPath
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowOffset = CGSize(width: 10, height: 10)
        card.layer.shadowRadius = 1
        card.layer.masksToBounds = false
        
        self.imgCard.layer.cornerRadius = 30
        self.imgCardBis.layer.cornerRadius = 30
        
        self.popupView.layer.cornerRadius = 30
    }
    
    func calculateCard(label: UILabel, img: UIImageView) {
        var imgRqst : String?
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.frame.size.width*0.5, y: view.frame.size.height*0.5)
        activityIndicator.startAnimating()
        AF.request("https://what-movie-today-for-ios.herokuapp.com/api/v1/newmovies/most", method: .get).responseJSON
            {
                response in
                print(response)
                
                switch response.result {
                case let .success(value):
                    let jsonData = value as! NSArray
                    print("json", jsonData[0])
                    let data = jsonData[Int.random(in: 0 ... 51)] as! NSDictionary
                    print("json", data.value(forKey: "Name")!)
                    if let name = data.value(forKey: "Name") {
                        let nameb = name as? String ?? ""
                        let newString = nameb.replacingOccurrences(of: " ", with: "+")
                        let finalString = newString + "+Movie"
                        print("nameb", finalString)
                        //imgRqst = "https://serpapi.com/search.json?q=" + finalString + "&tbm=isch&ijn=0&api_key=0462fb563e312cee95ddd23e393e3d2b05aa12afe21bb4e07779f7c37da03e50"
                        imgRqst = "https://www.omdbapi.com/?t=" + newString + "&apikey=8b28d966"
                        label.text = nameb
                        self.currentMovie = nameb
                        self.popupName.text = nameb
                        print(imgRqst!)
                        AF.request(imgRqst!, method: .get).responseJSON
                            {
                                response in

                                print("GETIMG", response)
                                
                                switch response.result {
                                case let .success(value):
                                    let jsonData = value as! NSDictionary
                                    if let imgLink = jsonData.value(forKey: "Poster") {
                                        print("json", imgLink)
                                        img.download(string: imgLink as! String)
                                    }
                                case .failure(_):
                                    print("image search error occured")
                                }
                                if let teaser = data.value(forKey: "wTeaser") {
                                    self.popupTeaser.text = teaser as? String ?? ""
                                }
                                if let yID = data.value(forKey: "yID") {
                                    let id = yID as! String
                                    print("id", id)
                                    self.popupYT.load(withVideoId: id)
                                    
                                }
                                self.popupView.updateContentView()
                                activityIndicator.stopAnimating()
                        }
                    }
                case .failure(_):
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
            "X-CSRFToken": xsrfCookie!.value,
            "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/movies/"
        ]
        
        print("token",headers["X-CSRFToken"]!)
        
        AF.request("https://what-movie-today-for-ios.herokuapp.com/api/v1/movies/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
            print("response", response, String(data: response.request!.httpBody!, encoding: String.Encoding.utf8))
        }
        
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-CSRFToken": xsrfCookie!.value,
            "Referer": "https://what-movie-today-for-ios.herokuapp.com/api/v1/movies/"
        ]
        AF.request("https://what-movie-today-for-ios.herokuapp.com/api/v1/rest-auth/logout/", method: .post, headers: headers).responseString { (response) in
            print("response", response)
        }
        //switching to login screen
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! UIViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
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
