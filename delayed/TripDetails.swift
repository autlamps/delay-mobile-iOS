//
//  TripDetails.swift
//  delayed
//
//  Created by Dharyin Colbert on 24/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit

class TripDetails: UIViewController {
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var lateOrEarlyLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    func configureView() {
        // Update the user interface
        if let detail = detailItem {
            DispatchQueue.main.async {
                self.serviceLabel.text = "Service: \(detail.route_short_name)"
                self.routeLabel.text = "Route: \(detail.route_long_name)"
               if((detail.delay as NSString).intValue < 0) {
                   self.delayLabel.text = String(abs((detail.delay as NSString).intValue))+" minutes"
                   self.lateOrEarlyLabel.text = "Late by"
               }
               else {
                   self.delayLabel.text = String((detail.delay as NSString).intValue)+" minutes"
                   self.lateOrEarlyLabel.text = "Early by"
               }
                self.nextStopLabel.text = "Next Stop: \(detail.next_stop_name)"
                self.etaLabel.text = "ETA: \(detail.next_stop_eta)"
            }
        }
    }
    
    var detailItem: TripInfo? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeButton.layer.cornerRadius = 5
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
