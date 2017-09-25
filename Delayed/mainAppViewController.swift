//
//  mainAppViewController.swift
//  Delayed
//
//  Created by Dharyin Colbert on 24/09/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import FirebaseAuth

class mainAppViewController: UIViewController  {
    
    @IBOutlet weak var textData: UITextView!
    
    @IBAction func logoutButton(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
   
    func parseData() {
        
        let urlPath = "https://dev.delayed.nz/delays"
        let url = NSURL(string: urlPath)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRlX2NyZWF0ZWQiOjE1MDYwNjU0NDgsInRva2VuX2lkIjoiNDEzMjY1ZmUtMTBlMi00NTAwLThiOWItY2ZhZjE4NGQ0NDE0IiwidXNlcl9pZCI6IjQzNGM2NzcyLWFkNDgtNGMzNi1iMDA0LWM3YmNiYTU2N2M4NiJ9.T8ZdYXc2WLmD1Khq7-DjlwEyuMOpiZXyQL58fELSdBY", forHTTPHeaderField: "X-DELAY-AUTH")
        //request.addValue(userid, forHTTPHeaderField: "uid")
        //request.addValue(hash, forHTTPHeaderField: "hash")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let myData = data {
                print(myData)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print(json)
                    let responseData = String(data: data!, encoding: String.Encoding.utf8)
                    DispatchQueue.main.async {
                        self.textData.text = responseData
                    }
                    
                }
                catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
