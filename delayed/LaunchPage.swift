//
//  LaunchPage.swift
//  delayed
//
//  Created by Dharyin Colbert on 29/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

let preferences = UserDefaults.standard

class LaunchPage: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func anonUser(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Registering...")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["email":"", "password":""], options: []) else {return}
        let url = "https://dev.delayed.nz/users"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("json", forHTTPHeaderField: "X-DELAY-AUTH")
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response {
                print("\n\(response)")
            }
            if let data = data {
                do {
                    let json = JSON(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary)
                    //print(json)
                    
                    let success = json["success"].boolValue
                    if !success {
                        //print(json["errors"]["msg"].stringValue)
                        DispatchQueue.main.async {
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        preferences.set(true, forKey: "loggedIn")
                        preferences.set(json["result"]["user_id"].stringValue, forKey: "userId")
                        preferences.set(json["result"]["auth_token"].stringValue, forKey: "authToken")
                        preferences.synchronize()
                        print("\n*************************************************")
                        if let id = preferences.string(forKey: "userId"){
                            print("User ID: \(id)")
                        } else { print("User ID: null") }
                        if let at = preferences.string(forKey: "authToken"){
                            print("Auth Token: \(at)")
                        } else { print("Auth Token: null") }
                        print("*************************************************\n")
                        
                        /*print contents of NSUserDefaults */
                        print("\n")
                        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
                            print("\(key) = \(value) \n")
                        }
                        
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            SVProgressHUD.showSuccess(withStatus: "Account Created")
                            self.performSegue(withIdentifier: "loginSegue", sender: self)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }).resume()
    }
    
    var timer: Timer!
    var counter: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signupButton.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 64, green: 131, blue: 255).cgColor
        
        configureScrollView()
        configurePageController()
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(0.4)
        
        /* Auto-scroll images */
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changePage), userInfo: nil, repeats: true)
    }
    
    func configureScrollView() {
        let imgOne = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let imgTwo = UIImageView(frame: CGRect(x: scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        let imgThree = UIImageView(frame: CGRect(x: scrollView.frame.width*2, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        
        imgOne.image = UIImage(named: "1.png")
        imgTwo.image = UIImage(named: "2.png")
        imgThree.image = UIImage(named: "3.png")
        
        scrollView.addSubview(imgOne)
        scrollView.addSubview(imgTwo)
        scrollView.addSubview(imgThree)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width*3, height: scrollView.frame.height)
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    func configurePageController() {
        pageControl.numberOfPages = scrollView.subviews.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        
        pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
    }
    
    @objc func changePage() {
        if counter <= 3 {
            pageControl.currentPage = counter
            counter = counter+1
        }
        else {
            counter = 0
        }
        
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        counter = pageControl.currentPage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*print contents of NSUserDefaults */
        print("\n")
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
        }
        
        if preferences.bool(forKey: "loggedIn") {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
