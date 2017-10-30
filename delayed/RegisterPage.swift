//
//  RegisterPage.swift
//  delayed
//
//  Created by Dharyin Colbert on 29/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class RegisterPage: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 5
    }

    /* Check the registration form input */
    @IBAction func registerButtonAction(_ sender: Any) {
        if (firstNameField.text?.isEmpty)! || (lastNameField.text?.isEmpty)! {
            errorLabel.text = "Please enter your name"
            errorLabel.isHidden = false
        }
        else if (emailField.text?.isEmpty)! {
            errorLabel.text = "Please enter an email address"
            errorLabel.isHidden = false
        }
        else if !(isValidEmail(testStr: emailField.text!)) {
            errorLabel.text = "Please enter a valid email address"
            errorLabel.isHidden = false
        }
        else if (passwordField.text?.isEmpty)! {
            errorLabel.text = "Please enter a password"
            errorLabel.isHidden = false
        }
        else if ((passwordField.text?.count)! < 6) {
            errorLabel.text = "Password must be at least 6 characters"
            errorLabel.isHidden = false
        }
        else if (confirmPasswordField.text?.isEmpty)! {
            errorLabel.text = "Please retype your password"
            errorLabel.isHidden = false
        }
        else if passwordField.text! != confirmPasswordField.text! {
            errorLabel.text = "Your passwords don't match"
            errorLabel.isHidden = false
        }
        else {
            registerUser(params: ["first_name":firstNameField.text, "last_name":lastNameField.text, "email":emailField.text, "password":passwordField.text])
        }
    }
    
    /* Create new account with the dev.delayed API */
    func registerUser(params:[String:String?]) {
        SVProgressHUD.show(withStatus: "Registering...")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {return}
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
                            self.performSegue(withIdentifier: "registerSegue", sender: self)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }).resume()
    }
    
    /* validate the format of the entered email */
    fileprivate func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
