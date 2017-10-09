//
//  MasterViewController.swift
//  test
//
//  Created by Dharyin Colbert on 5/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [String]()
    var details = [TripInfo]()
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeTable()
        //navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .organize, target: self, action: )
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshTable(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTable(_:)))
        navigationItem.rightBarButtonItem = refreshButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        SVProgressHUD.setMinimumDismissTimeInterval(0.4)
        SVProgressHUD.setDefaultMaskType(.gradient)
    }
    
    @objc
    func refreshTable(_ sender: Any) {
        SVProgressHUD.setStatus("Refreshing...")
        objects.removeAll()
        details.removeAll()
        tableView.reloadData()
        
        let url = "https://dev.delayed.nz/delays"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl9pZCI6ImY0OWUxMWMyLTA4MTEtNDIwNy04YjM2LTM5OGJhM2VjNzlmYSJ9.wsIPZHEi65hogPAIOQtZ_zvQdsri2ofN2LfMMRIcQL8", forHTTPHeaderField: "X-DELAY-AUTH")
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
            }
            else {
                do {
                    let json = JSON(try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary)
                    print(json)
                    
                    let success = json["success"].boolValue
                    //print(success)
                    if !success {
                        //print(json["errors"]["msg"].stringValue)
                        DispatchQueue.main.async {
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        for i in 0 ..< json["result"]["trips"].count {
                            self.details.append(TripInfo(trip_id: json["result"]["trips"][i]["trip_id"].stringValue, route_id: json["result"]["trips"][i]["route_id"].stringValue, route_long_name: json["result"]["trips"][i]["route_long_name"].stringValue, route_short_name: json["result"]["trips"][i]["route_short_name"].stringValue, next_stop_id: json["result"]["trips"][i]["next_stop"]["id"].stringValue, next_stop_name: json["result"]["trips"][i]["next_stop"]["name"].stringValue, delay: String(((json["result"]["trips"][i]["next_stop"]["delay"].stringValue as NSString).integerValue/60)), eta: json["result"]["trips"][i]["next_stop"]["eta"].stringValue))
                        }
                        print("\n")
                        print(self.details)
                        
                        for i in 0 ..< self.details.count {
                            if (self.details[i].delay as NSString).integerValue > 0 {
                                self.objects.append("Service "+self.details[i].route_short_name+" is late")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                            else {
                                self.objects.append("Service "+self.details[i].route_short_name+" is early")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                        }
                        
                        self.tableView.reloadData()
                        SVProgressHUD.showSuccess(withStatus: "Updated!")
                    }
                }
                catch {
                    print(error)
                }
            }
        })
        task.resume()
        refresher.endRefreshing()
    }
    struct TripInfo {
        
        var trip_id : String
        var route_id : String
        var route_long_name : String
        var route_short_name : String
        
        var next_stop_id : String
        var next_stop_name : String
        var delay : String
        var eta : String
        
        init(trip_id : String, route_id : String, route_long_name : String, route_short_name : String, next_stop_id : String, next_stop_name : String, delay : String, eta : String) {
            self.trip_id = trip_id
            self.route_id = route_id
            self.route_long_name = route_long_name
            self.route_short_name = route_short_name
            self.next_stop_id = next_stop_id
            self.next_stop_name = next_stop_name
            self.delay = delay
            self.eta = eta
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = details[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    /* This esentially does exactly the same as refreshTable, but at the very start.
       I can't call the refreshTable func because it's an @objc selector */
    func initilizeTable() {
        SVProgressHUD.setStatus("Refreshing...")
        objects.removeAll()
        details.removeAll()
        
        let url = "https://dev.delayed.nz/delays"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl9pZCI6ImY0OWUxMWMyLTA4MTEtNDIwNy04YjM2LTM5OGJhM2VjNzlmYSJ9.wsIPZHEi65hogPAIOQtZ_zvQdsri2ofN2LfMMRIcQL8", forHTTPHeaderField: "X-DELAY-AUTH")
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
            }
            else {
                do {
                    let json = JSON(try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary)
                    print(json)
                    
                    let success = json["success"].boolValue
                    //print(success)
                    if !success {
                        //print(json["errors"]["msg"].stringValue)
                        DispatchQueue.main.async {
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        for i in 0 ..< json["result"]["trips"].count {
                            self.details.append(TripInfo(trip_id: json["result"]["trips"][i]["trip_id"].stringValue, route_id: json["result"]["trips"][i]["route_id"].stringValue, route_long_name: json["result"]["trips"][i]["route_long_name"].stringValue, route_short_name: json["result"]["trips"][i]["route_short_name"].stringValue, next_stop_id: json["result"]["trips"][i]["next_stop"]["id"].stringValue, next_stop_name: json["result"]["trips"][i]["next_stop"]["name"].stringValue, delay: String(((json["result"]["trips"][i]["next_stop"]["delay"].stringValue as NSString).integerValue/60)), eta: json["result"]["trips"][i]["next_stop"]["eta"].stringValue))
                        }
                        print("\n")
                        print(self.details)
                        
                        for i in 0 ..< self.details.count {
                            if (self.details[i].delay as NSString).integerValue > 0 {
                                self.objects.append("Service "+self.details[i].route_short_name+" is late")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                            else {
                                self.objects.append("Service "+self.details[i].route_short_name+" is early")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                        }
                        
                        self.tableView.reloadData()
                        SVProgressHUD.showSuccess(withStatus: "Updated!")
                    }
                }
                catch {
                    print(error)
                }
            }
        })
        task.resume()
    }
}
