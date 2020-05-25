//
//  TodayViewController.swift
//  InsightTodayExtension
//
//  Created by Josh Leikam on 7/10/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase
import FirebaseDatabase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var quoteTxtView: UITextView!
    var refQuotes: DatabaseReference!
    var refHandle : UInt!
    var quoteTxt: String = "Preparing Insight..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        // Do any additional setup after loading the view from its nib.
//        quoteTxtView.text = "Open app to see the insight of the day here."
//        if let quoteFromApp = UserDefaults.init(suiteName: "group.com.joshleikam.insighttodayextension")?.value(forKey: "testQuote") {
//            quoteTxtView.text = quoteFromApp as? String
//            print(quoteFromApp)
//        }
        self.initQuote()
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - START Widget
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
//        if let quoteFromApp = UserDefaults.init(suiteName: "group.com.joshleikam.insighttodayextension")?.value(forKey: "testQuote") {
//            if quoteFromApp as? String != quoteTxtView.text {
//                quoteTxtView.text = quoteFromApp as? String
//                completionHandler(NCUpdateResult.newData)
//            } else {
//                completionHandler(NCUpdateResult.noData)
//            }
//        } else {
//            quoteTxtView.text = "Open your app to read your quote of the day."
//            completionHandler(NCUpdateResult.newData)
//        }
        quoteTxtView.text = quoteTxt
        completionHandler(NCUpdateResult.newData)
        

    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize;
        }
        else {
            self.preferredContentSize = CGSize(width: CGFloat(0), height: quoteTxtView.contentSize.height);
        }
    }
    
    //MARK - END Widget
    
    //MARK - START Quotes
    
    //gets the key of the last quote added to the database (last quote will have the highest index)
    func getMaxQuotes(completion:@escaping ((_ maxQuotes:Int)->Void)){
        refQuotes = Database.database().reference().child("quotes")
        refHandle = refQuotes.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            let maxQuotes = Int(snapshot.key)!
            completion(maxQuotes)
        })
    }
    

    
    //pulls quoteTxt from database
    func getQuote(completionQuoteText:@escaping ((_ quoteTxt:String)->Void)){
        let day = getDay()
        _ = getMaxQuotes { (maxQuotes) in
            let quoteNumber = (day % maxQuotes)
            self.refQuotes = Database.database().reference().child("quotes")
            self.refHandle = self.refQuotes.child(String(quoteNumber)).observe(DataEventType.value, with: { (snapshot) in
                let quoteObject = snapshot.value as? [String: AnyObject]
                let quoteTxt = quoteObject?["text"] as! String
                let quoteAuthor = quoteObject?["author"] as! String
                let quoteSource = quoteObject?["source"] as! String
                let textToDisplay = "\"" +  quoteTxt + "\"" + " \n" + "-" + quoteAuthor + ", " + quoteSource
                completionQuoteText(textToDisplay)
            })
        }
    }
    
    func initQuote(){
        _ = getQuote(completionQuoteText: { (quote) in
            self.quoteTxt = quote
            self.quoteTxtView.text = quote
        })
    }
    
    //returns todays date as a num 1 - inifinity. uses jan1 and 1970 to calculate a hard start date
    func getDay() -> Int{
        let today = Date()
        let secondsSince1970 = Int(today.timeIntervalSince1970) //seconds since 1970
        let secondsSinceJan12017 = 1483228800 + (3600 * 5) //convert to CST time
        let secondsInDay = 86400
        let day = ((secondsSince1970 - secondsSinceJan12017)/secondsInDay) + 1
        
        return day
    }
    //MARK - END Quotes
    
}
