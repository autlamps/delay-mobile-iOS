//
//  AllTrips.swift
//  delayed
//
//  Created by Dharyin Colbert on 24/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import FirebaseMessaging

class AllTrips: UITableViewController {
    
    var trips = [String]()
    var details = [TripInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(0.4)
        initilizeTable()
    }
    
    // MARK: - Table view data source
    
    /* pass trip object from main table to details view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = details[indexPath.row]
                let controller = segue.destination as! TripDetails
                controller.detailItem = object
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = trips[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func initilizeTable() {
        SVProgressHUD.show(withStatus: "Refreshing...")
        trips.removeAll()
        details.removeAll()
        
        let url = "https://dev.delayed.nz/delays"
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
                        for i in 0 ..< json["result"]["trips"].count {
                            self.details.append(TripInfo(trip_id: json["result"]["trips"][i]["trip_id"].stringValue, route_id: json["result"]["trips"][i]["route_id"].stringValue, route_long_name: json["result"]["trips"][i]["route_long_name"].stringValue, route_short_name: json["result"]["trips"][i]["route_short_name"].stringValue, stoptime_id: json["result"]["trips"][i]["next_stop"]["stoptime_id"].stringValue, next_stop_id: json["result"]["trips"][i]["next_stop"]["id"].stringValue, next_stop_name: json["result"]["trips"][i]["next_stop"]["name"].stringValue, next_stop_lat: json["result"]["trips"][i]["next_stop"]["lat"].stringValue, next_stop_lon: json["result"]["trips"][i]["next_stop"]["lon"].stringValue, delay: String(((json["result"]["trips"][i]["next_stop"]["delay"].stringValue as NSString).integerValue/60)), next_stop_scheduled_arrival: json["result"]["trips"][i]["next_stop"]["scheduled_arrival"].stringValue, next_stop_eta: json["result"]["trips"][i]["next_stop"]["eta"].stringValue, vehicle_id: json["result"]["trips"][i]["vehicle_id"].stringValue, vehicle_type: json["result"]["trips"][i]["vehicle_type"].stringValue, lat: json["result"]["trips"][i]["lat"].stringValue, lon: json["result"]["trips"][i]["lon"].stringValue))
                        }
                        print("\n")
                        //print(self.details)
                        
                        for i in 0 ..< self.details.count {
                            if (self.details[i].delay as NSString).integerValue > 0 {
                                self.trips.append("Service "+self.details[i].route_short_name+" is late")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                            else {
                                self.trips.append("Service "+self.details[i].route_short_name+" is early")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                        }
                        
                        self.tableView.reloadData()
                        SVProgressHUD.showSuccess(withStatus: "Updated!")
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
}

struct TripInfo {
    
    var trip_id: String
    var route_id: String
    var route_long_name: String
    var route_short_name: String
    var stoptime_id: String
    var next_stop_id : String
    var next_stop_name : String
    var next_stop_lat: String
    var next_stop_lon: String
    var delay: String
    var next_stop_scheduled_arrival: String
    var next_stop_eta: String
    var vehicle_id: String
    var vehicle_type: String
    var lat: String
    var lon: String
    
    init(trip_id: String, route_id: String, route_long_name: String, route_short_name: String, stoptime_id: String, next_stop_id : String, next_stop_name : String, next_stop_lat: String, next_stop_lon: String, delay: String, next_stop_scheduled_arrival: String, next_stop_eta: String, vehicle_id: String, vehicle_type: String, lat: String, lon: String) {
        
        self.trip_id = trip_id
        self.route_id = route_id
        self.route_long_name = route_long_name
        self.route_short_name = route_short_name
        self.stoptime_id = stoptime_id
        self.next_stop_id = next_stop_id
        self.next_stop_name = next_stop_name
        self.next_stop_lat = next_stop_lat
        self.next_stop_lon = next_stop_lon
        self.delay = delay
        self.next_stop_scheduled_arrival = next_stop_scheduled_arrival
        self.next_stop_eta = next_stop_eta
        self.vehicle_id = vehicle_id
        self.vehicle_type = vehicle_type
        self.lat = lat
        self.lon = lon
    }
}

