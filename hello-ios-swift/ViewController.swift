//
//  ViewController.swift
//  LaunchDarklyHelloWorld
//
//  Created by Korhan Bircan on 3/24/17.
//  Copyright © 2017 Korhan Bircan. All rights reserved.
//

import UIKit
import LaunchDarkly

class ViewController: UIViewController {
    @IBOutlet weak var featureFlagLabel: UILabel!

    // Enter your feature flag name here.
    fileprivate let featureFlagKey = "george-event-tracker-test"

    override func viewDidLoad() {
        super.viewDidLoad()

        LDClient.shared.observe(key: featureFlagKey, owner: self) { [weak self] (changedFlag) in
            self?.featureFlagDidUpdate(changedFlag.key)
        }
        checkFeatureValue()
    }

    fileprivate func checkFeatureValue() {
        
        
        let featureFlagValue = LDClient.shared.variation(forKey: featureFlagKey, fallback: false)
        
        do{
            try LDClient.shared.trackEvent(key: "test-demo-internal-numeric", data: nil ,metricValue:  10)
        }
        catch{
            print("tracking call failed")
        }
        updateLabel(value: featureFlagValue)
    }

    fileprivate func updateLabel(value: Bool) {
        featureFlagLabel.text = "\(featureFlagKey): \(value)"
    }

    func featureFlagDidUpdate(_ key: LDFlagKey) {
        if key == featureFlagKey {
            checkFeatureValue()
        }
    }
}
