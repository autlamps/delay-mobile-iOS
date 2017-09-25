//
//  ViewController.swift
//  Delayed
//
//  Created by Dharyin Colbert on 24/09/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginAction(_ sender: Any) {
        if emailField.text != "" && passwordField.text != "" {
            if segmentControl.selectedSegmentIndex == 0 { //login user
                
                Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, Error) in
                    
                    if user != nil { //user exists, sucessfull login
                        print("Login Sucessful")
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    }
                    else { //error loging in
                        if let myError = Error?.localizedDescription { //if available, print error desciption
                            //self.errorLabel.text = myError
                            print(myError)
                        }
                        else { //generic error
                            print("Error")
                        }
                    }
                })
            }
            else { //register user
                Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                    if user != nil { //sucessfully created user
                        print("Account Created")
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    }
                    else { //could not create user
                        if let myError = error?.localizedDescription { //if available, print error desciption
                            print(myError)
                        }
                        else { //generic error
                            print("Error")
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

