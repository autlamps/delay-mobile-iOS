//
//  DetailViewController.swift
//  Delayed
//
//  Created by Dharyin Colbert on 4/10/17.
//  Copyright © 2017 Lamps. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var lateOrEarlyLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBAction func subscribeAction(_ sender: Any) {
    }
    
    func configureView() {
        // Update the user interface
        if let detail = detailItem {
            DispatchQueue.main.async {
                self.serviceLabel.text = detail.route_short_name
                self.routeLabel.text = detail.route_long_name
                if((detail.delay as NSString).intValue < 0) {
                    self.delayLabel.text = String(abs((detail.delay as NSString).intValue))+" minutes"
                    self.lateOrEarlyLabel.text = "late"
                }
                else {
                    self.delayLabel.text = String((detail.delay as NSString).intValue)+" minutes"
                    self.lateOrEarlyLabel.text = "early"
                }
                self.nextStopLabel.text = detail.next_stop_name
                self.etaLabel.text = detail.eta
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeButton.layer.cornerRadius = 20
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: MasterViewController.TripInfo? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

