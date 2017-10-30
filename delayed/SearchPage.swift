//
//  SearchPage.swift
//  delayed
//
//  Created by Dharyin Colbert on 30/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class SearchPage: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var label: UILabel!
    
    var routes = [String]()
    var details = [RouteInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        tableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.label.isHidden = true
        SVProgressHUD.show(withStatus: "Searching...")
        self.view.endEditing(true)
        self.label.isHidden = false
        populateTable()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.label.isHidden = false
        searchField.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.view.endEditing(true)
            self.tableView.isHidden = true
            self.label.isHidden = false
            searchBar.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = routes[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "routeDetails", sender: self)
    }
    
    /* pass route object from main table to details view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "routeDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let route = details[indexPath.row]
                let controller = segue.destination as! RouteDetails
                controller.detailItem = route
            }
        }
    }
    
    func populateTable() {
        
        routes.removeAll()
        details.removeAll()
        tableView.reloadData()
        
        let url = "https://dev.delayed.nz/routes"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        //request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl9pZCI6IjE4NmU3M2M4LWE5NzQtNDdhMS1hOGNjLWI4NTVmNWE2ZDk2ZSJ9.9EMpAdCmq4BpfumTX_r6oka61DDO_s8DbCj_R5NWWI4", forHTTPHeaderField: "X-DELAY-AUTH")
        
        request.addValue(preferences.string(forKey: "authToken")!, forHTTPHeaderField: "X-DELAY-AUTH")
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print("\n*************************************************")
                print(error!)
                print("*************************************************\n")
            }
            else {
                do {
                    let json = JSON(try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary)
                    //print(json)
                    
                    let success = json["success"].boolValue
                    if !success {
                        print(json)
                        print("\n*************************************************")
                        print(json["errors"]["msg"].stringValue)
                        print("*************************************************\n")
                        DispatchQueue.main.async {
                            SVProgressHUD.showError(withStatus: json["errors"]["msg"].stringValue)
                        }
                    }
                    else {
                        for i in 0 ..< json["result"]["routes"].count {
                            self.details.append(RouteInfo(id: json["result"]["routes"][i]["id"].stringValue, gtfs_id: json["result"]["routes"][i]["gtfs_id"].stringValue, agency_id: json["result"]["routes"][i]["agency_id"].stringValue, short_name: json["result"]["routes"][i]["short_name"].stringValue, long_name: json["result"]["routes"][i]["long_name"].stringValue, route_type: (json["result"]["routes"][i]["route_type"].stringValue as NSString).integerValue))
                        }
                        print("\n")
                        //print(self.details)
                        
                        for i in 0 ..< self.details.count {
                            
                            if (self.details[i].short_name as NSString).contains(self.searchField.text!) || (self.details[i].long_name as NSString).contains(self.searchField.text!) {
                                self.routes.append(self.details[i].long_name)
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                                
                                print(self.details[i].short_name)
                                print(self.details[i].long_name)
                            }
                        }
                        if self.routes.count > 0 {
                            
                            SVProgressHUD.dismiss()
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                        }
                        else {
                            SVProgressHUD.showError(withStatus: "No routes found!")
                        }
                    }
                }
                catch {
                    print("\n*************************************************")
                    print(error)
                    print("*************************************************\n")
                }
            }
        })
        task.resume()
    }
    
    /* dismiss keyboard when touch outside of keyboard */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchField.resignFirstResponder()
        self.view.endEditing(true)
    }
}

struct RouteInfo {
    
    var id: String
    var gtfs_id: String
    var agency_id: String
    var short_name: String
    var long_name: String
    var route_type: Int
    
    init(id: String, gtfs_id: String, agency_id: String, short_name: String, long_name: String, route_type: Int) {
        
        self.id = id
        self.gtfs_id = gtfs_id
        self.agency_id = agency_id
        self.short_name = short_name
        self.long_name = long_name
        self.route_type = route_type
    }
}
