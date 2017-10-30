//
//  StoptimePage.swift
//  delayed
//
//  Created by Dharyin Colbert on 30/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class StoptimePage: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var stops = [String]()
    var details = [StopTime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        if let detail = detailItem {
            stops.removeAll()
            details.removeAll()
            
            let url = "https://dev.delayed.nz/trips/\(detail.id)/stoptimes"
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
                            for i in 0 ..< json["result"]["stop_time"].count {
                                self.details.append(StopTime(count: json["result"]["count"].intValue, id: json["result"]["stop_time"][i]["id"].stringValue, trip_id: json["result"]["stop_time"][i]["trip_id"].stringValue, stop_sequence: json["result"]["stop_time"][i]["stop_sequence"].intValue, stop_info_id: json["result"]["stop_time"][i]["stop_info"]["id"].stringValue, stop_info_name: json["result"]["stop_time"][i]["stop_info"]["name"].stringValue, stop_info_lat: json["result"]["stop_time"][i]["stop_info"]["lat"].stringValue, stop_info_lon: json["result"]["stop_time"][i]["stop_info"]["lon"].stringValue, departure: json["result"]["stop_time"][i]["departure"].stringValue, arrival: json["result"]["stop_time"][i]["arrival"].stringValue))
                            }
                            print("\n")
                            print(self.details)
                            
                            for i in 0 ..< self.details.count {
                                self.stops.append("Stop: \(self.details[i].stop_info_name), Departs: \(self.details[i].departure)")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = stops[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        performSegue(withIdentifier: "tripDays", sender: self)
    //    }
    
    /* pass route object from main table to details view */
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "subTrip" {
    //            if let indexPath = tableView.indexPathForSelectedRow {
    //                let object = details[indexPath.row]
    //                let controller = segue.destination as! SubscribePage
    //                controller.detailItem = object
    //            }
    //        }
    //    }
    
    var detailItem: subTrip? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

struct StopTime {
    
    var count: Int
    var id: String
    var trip_id: String
    var stop_sequence: Int
    var stop_info_id: String
    var stop_info_name: String
    var stop_info_lat: String
    var stop_info_lon: String
    var departure: String
    var arrival: String
    
    init(count: Int, id: String, trip_id: String, stop_sequence: Int, stop_info_id: String, stop_info_name: String, stop_info_lat: String, stop_info_lon: String, departure: String, arrival: String) {
        
        self.count = count
        self.id = id
        self.trip_id = trip_id
        self.stop_sequence = stop_sequence
        self.stop_info_id = stop_info_id
        self.stop_info_name = stop_info_name
        self.stop_info_lat = stop_info_lat
        self.stop_info_lon = stop_info_lon
        self.departure = departure
        self.arrival = arrival
    }
}

