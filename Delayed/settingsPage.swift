//
//  SettingsPage.swift
//  delayed
//
//  Created by Dharyin Colbert on 24/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit

class SettingsPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var settings = ["Reset Password"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = settings[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "confirmNewPass", sender: self)
    }

    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.layer.cornerRadius = 5
    }
}
