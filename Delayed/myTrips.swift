//
//  MyTrips.swift
//  delayed
//
//  Created by Dharyin Colbert on 25/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit

class MyTrips: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var objects = [String]()
    var details = [TripInfo]()
     
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = objects[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
