//
//  LoginPage.swift
//  delayed
//
//  Created by Dharyin Colbert on 29/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class LoginPage: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
    }

    /* Validates the format of the login credentials */
    @IBAction func loginButtonAction(_ sender: Any) {
        errorLabel.isHidden = true
        self.view.endEditing(true)
        
        if (emailField.text?.isEmpty)! {
            errorLabel.text = "Please enter your email address"
            errorLabel.isHidden = false
        }
        else if !(isValidEmail(testStr: emailField.text!)) {
            errorLabel.text = "Please enter a valid email address"
            errorLabel.isHidden = false
        }
        else if (passwordField.text?.isEmpty)! {
            errorLabel.text = "Please enter your password"
            errorLabel.isHidden = false
        }
        else {
            let params = ["email":emailField.text,"password":passwordField.text]
            loginUser(params: params)
        }
    }
    
    /* validate the format of the entered email */
    fileprivate func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /* Authenticate user credentials with the API */
    func loginUser(params:[String:String?]) {
        SVProgressHUD.show()
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {return}
        let url = "https://dev.delayed.nz/tokens"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("json", forHTTPHeaderField: "X-DELAY-AUTH")
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = JSON(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary)
                    let success = json["success"].boolValue
                    
                    if success == false {
                        print("\n\(json["errors"]["msg"].stringValue)")
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
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
                        
                        do {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                SVProgressHUD.showSuccess(withStatus: "Login Successful")
                                
                                /*print contents of NSUserDefaults */
                                print("\n")
                                for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
                                    print("\(key) = \(value) \n")
                                }
                                
                                self.performSegue(withIdentifier: "loginSegue", sender: self)
                            }
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }).resume()
    }
    
    /* dismiss keyboard when touch outside of keyboard */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /* dismiss keyboard when hit enter key */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
