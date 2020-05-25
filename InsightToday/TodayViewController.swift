//
//  TodayViewController.swift
//  InsightToday
//
//  Created by Josh Leikam on 7/10/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var quoteLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteLabel.text = "Open your app to read your quote of the day."
        if let quoteFromApp = UserDefaults.init(suiteName: "group.com.joshleikam.dailyinsight")?.value(forKey: "testQuote") {
            quoteLabel.text = quoteFromApp as? String
            print(quoteFromApp)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let quoteFromApp = UserDefaults.init(suiteName: "group.com.joshleikam.dailyinsight")?.value(forKey: "testQuote") {
            if quoteFromApp as? String != quoteLabel.text {
                quoteLabel.text = quoteFromApp as? String
                completionHandler(NCUpdateResult.newData)
            } else {
                quoteLabel.text = "Open your app to read your quote of the day."
                completionHandler(NCUpdateResult.newData)

            }
        }
        else {
            completionHandler(NCUpdateResult.noData)
        }

    }
    
}
