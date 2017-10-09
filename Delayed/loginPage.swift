//
//  betterLoginPage.swift
//  Delayed
//
//  Created by Dharyin Colbert on 9/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import TextFieldEffects
import SwiftyJSON
import SVProgressHUD

var userId = ""
var token = ""

class loginPage: UIViewController {
    
    @IBOutlet weak var firstNameField: MadokaTextField!
    @IBOutlet weak var lastNameField: MadokaTextField!
    @IBOutlet weak var registerEmailField: MadokaTextField!
    @IBOutlet weak var registerPasswordField: MadokaTextField!
    @IBOutlet weak var confirmPasswordField: MadokaTextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerErrorLabel: UILabel!
    
    @IBOutlet weak var loginEmailField: MadokaTextField!
    @IBOutlet weak var loginPasswordField: MadokaTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginErrorLabel: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    /* Create new account with the API */
    func registerUser(params:[String:String?]) {
        SVProgressHUD.show()
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {return}
        let url = "https://dev.delayed.nz/users"
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
                    //print(json)
                    
                    let success = json["success"].boolValue
                    //print(success)
                    if !success {
                        //print(json["errors"]["msg"].stringValue)
                        DispatchQueue.main.async {
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        userId = json["result"]["user_id"].stringValue
                        token = json["result"]["auth_token"].stringValue
                        do {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                SVProgressHUD.showSuccess(withStatus: "Account Created")
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
                    //print(json)
                    
                    let success = json["success"].boolValue
                    //print(success)
                    if !success {
                        //print(json["errors"]["msg"].stringValue)
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        userId = json["result"]["user_id"].stringValue
                        token = json["result"]["auth_token"].stringValue
                        //print(id)
                        //print(token)
                        do {
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                SVProgressHUD.showSuccess(withStatus: "Login Successful")
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
    
    /* Validates the format of the registration form input */
    @IBAction func registerButtonAction(_ sender: Any) {
        registerErrorLabel.isHidden = true
        checkRegistrationForm()
    }
    
    /* Validates the format of the login credentials */
    @IBAction func loginButtonAction(_ sender: Any) {
        loginErrorLabel.isHidden = true
        registerErrorLabel.isHidden = true
        
        if (loginEmailField.text?.isEmpty)! {
            loginErrorLabel.text = "Please enter your email address"
            loginErrorLabel.isHidden = false
        }
        else if !(isValidEmail(testStr: loginEmailField.text!)) {
            loginErrorLabel.text = "Please enter a valid email address"
            loginErrorLabel.isHidden = false
        }
        else if (loginPasswordField.text?.isEmpty)! {
            loginErrorLabel.text = "Please enter your password"
            loginErrorLabel.isHidden = false
        }
        else {
            let params = ["email":loginEmailField.text,"password":loginPasswordField.text]
            loginUser(params: params)
        }
    }
    
    /* Creates an 'anonymous' user on the API */
    @IBAction func loginLaterAction(_ sender: Any) {
        registerUser(params: ["email":"", "password":""])
    }
    
    /* Check if regstration form is complete */
    fileprivate func checkRegistrationForm() {
        if (firstNameField.text?.isEmpty)! || (lastNameField.text?.isEmpty)! {
            registerErrorLabel.text = "Please enter your name"
            registerErrorLabel.isHidden = false
        }
        else if (registerEmailField.text?.isEmpty)! {
            registerErrorLabel.text = "Please enter an email address"
            registerErrorLabel.isHidden = false
        }
        else if !(isValidEmail(testStr: registerEmailField.text!)) {
            registerErrorLabel.text = "Please enter a valid email address"
            registerErrorLabel.isHidden = false
        }
        else if (registerPasswordField.text?.isEmpty)! {
            registerErrorLabel.text = "Please enter a password"
            registerErrorLabel.isHidden = false
        }
        else if (confirmPasswordField.text?.isEmpty)! {
            registerErrorLabel.text = "Please retype your password"
            registerErrorLabel.isHidden = false
        }
        else if registerPasswordField.text! != confirmPasswordField.text! {
            registerErrorLabel.text = "Your passwords don't match"
            registerErrorLabel.isHidden = false
        }
        else {
            registerUser(params: ["first_name":firstNameField.text, "last_name":lastNameField.text, "email":registerEmailField.text, "password":registerPasswordField.text])
        }
    }
    
    /* validate the format of the entered email */
    fileprivate func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /* Change what's displayed when using segment switch */
    @IBAction func segmentSwitch(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 { //login
            loginEmailField.isHidden = false
            loginPasswordField.isHidden = false
            loginButton.isHidden = false
            
            firstNameField.isHidden = true
            lastNameField.isHidden = true
            registerButton.isHidden = true
            registerEmailField.isHidden = true
            registerPasswordField.isHidden = true
            confirmPasswordField.isHidden = true
            registerErrorLabel.isHidden = true
        }
        else { //register
            loginEmailField.isHidden = true
            loginPasswordField.isHidden = true
            loginErrorLabel.isHidden = true
            loginButton.isHidden = true
            
            firstNameField.isHidden = false
            lastNameField.isHidden = false
            registerButton.isHidden = false
            registerEmailField.isHidden = false
            registerPasswordField.isHidden = false
            confirmPasswordField.isHidden = false
            registerErrorLabel.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.isHidden = true
        lastNameField.isHidden = true
        registerButton.isHidden = true
        registerEmailField.isHidden = true
        registerPasswordField.isHidden = true
        confirmPasswordField.isHidden = true
        registerErrorLabel.isHidden = true
        
        loginButton.layer.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(0.4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
