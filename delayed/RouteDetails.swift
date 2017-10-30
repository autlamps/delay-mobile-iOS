//
//  RouteDetails.swift
//  delayed
//
//  Created by Dharyin Colbert on 30/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON

class RouteDetails: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var trips = [String]()
    var details = [subTrip]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = trips[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "subTrip", sender: self)
//    }
    
    /* pass route object from main table to details view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subTrip" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = details[indexPath.row]
                let controller = segue.destination as! StoptimePage
                controller.detailItem = object
            }
        }
    }
    
    /* Update the user interface */
    func configureView() {
        if let detail = detailItem {
            //SVProgressHUD.show(withStatus: "Refreshing...")
            
            let url = "https://dev.delayed.nz/routes/\(detail.id)/trips"
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
                                self.details.append(subTrip(id: json["result"]["trips"][i]["id"].stringValue, route_id: json["result"]["trips"][i]["route_id"].stringValue, service_id: json["result"]["trips"][i]["service_id"].stringValue, gtfsid: json["result"]["trips"][i]["gtfsid"].stringValue, headsign: json["result"]["trips"][i]["headsign"].stringValue, monday: json["result"]["trips"][i]["calendar"]["monday"].stringValue, tuesday: json["result"]["trips"][i]["calendar"]["tuesday"].stringValue, wednesday: json["result"]["trips"][i]["calendar"]["wednesday"].stringValue, thursday: json["result"]["trips"][i]["calendar"]["thursday"].stringValue, friday: json["result"]["trips"][i]["calendar"]["friday"].stringValue, saturday: json["result"]["trips"][i]["calendar"]["saturday"].stringValue, sunday: json["result"]["trips"][i]["calendar"]["sunday"].stringValue, start_time: json["result"]["trips"][i]["calendar"]["start_time"].stringValue, end: json["result"]["trips"][i]["calendar"]["end"].stringValue))
                            }
                            print("\n")
                            print(self.details)
                            
                            for i in 0 ..< self.details.count {
                                self.trips.append("\(self.details[i].start_time) - \(self.details[i].end)")
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .automatic)
                            }
                            
                            self.tableView.reloadData()
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
    
    var detailItem: RouteInfo? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
}

struct subTrip {
    
    var id: String
    var route_id: String
    var service_id: String
    var gtfsid: String
    var headsign: String
    var monday: String
    var tuesday: String
    var wednesday: String
    var thursday: String
    var friday: String
    var saturday: String
    var sunday: String
    var start_time: String
    var end: String
    
    init(id: String, route_id: String, service_id: String, gtfsid: String, headsign: String, monday: String, tuesday: String, wednesday: String, thursday: String, friday: String, saturday: String, sunday: String, start_time: String, end: String) {
        
        self.id = id
        self.route_id = route_id
        self.service_id = service_id
        self.gtfsid = gtfsid
        self.headsign = headsign
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.start_time = start_time
        self.end = end
    }
}
