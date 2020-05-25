//
//  TodayViewController.swift
//  Insight
//
//  Created by Josh Leikam on 7/14/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreData


class SixViewController: UIViewController {
    
    @IBOutlet weak var buttonToolbar: UIToolbar!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quoteTxtView: UITextView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var refQuotes: DatabaseReference!
    var refHandle : UInt!
    var quoteTxt: String!
    var amazonID: String!
    var markAsFavoriteToggleState = 1
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favoriteQuoteArray: [FavoritedInsights] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initQuote()
        self.initDateLabel()
        
        buttonToolbar.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            let controller = UIAlertController(title: "No Connection Detected", message: "This app requires an Internet/Mobile Data connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    func refresh(notification: NSNotification){
        self.checkQuote()
    }
    
    func initDateLabel(){
        let date = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd, YYYY"
        let str = dateFormatter.string(from: yesterday!)
        
        dateLabel.text = str
        
    }
    
    func initQuote(){
        
        _ = getQuoteData(completionQuote: { (quote, amazonID) in
            
            self.quoteTxtView.text = quote
            self.quoteTxt = quote
            self.amazonID = amazonID
            
            self.checkQuote()
        })
        
        
    }
    
    func checkQuote(){
        
        self.markAsFavoriteToggleState = 1
        
        self.favoriteButton.image = UIImage(named:"icons8-Star.png")
        
        self.favoriteQuoteArray = try! self.coreDataContext.fetch(FavoritedInsights.fetchRequest())
        
        
        for quote in self.favoriteQuoteArray {
            if(self.quoteTxt == quote.insightTxt){
                print("match")
                self.favoriteButton.image = UIImage(named:"icons8-Star Filled.png")
                self.markAsFavoriteToggleState = 2
            }
            
        }

        
        
    }
    
    
    func willEnterForeground() {
        self.initQuote()
        self.initDateLabel()
    }
    
    //returns todays date as a num 1 - inifinity. uses jan1 and 1970 to calculate a hard start date
    func getDay() -> Int{
        let today = Date()
        let secondsSince1970 = Int(today.timeIntervalSince1970) //seconds since 1970
        let secondsSinceJan12017 = 1483228800 + (3600 * 5) //convert to CST time
        let secondsInDay = 86400
        let day = ((secondsSince1970 - secondsSinceJan12017)/secondsInDay) + 1
        
        return day - 1
    }
    
    //pulls quoteTxt from database
    func getQuoteData(completionQuote:@escaping ((_ quoteTxt:String, _ quoteID: String)->Void)){
        let day = getDay()
        _ = getMaxQuotes { (maxQuotes) in
            let quoteNumber = (day % maxQuotes)
            self.refQuotes = Database.database().reference().child("quotes")
            self.refHandle = self.refQuotes.child(String(quoteNumber)).observe(DataEventType.value, with: { (snapshot) in
                let quoteObject = snapshot.value as? [String: AnyObject]
                let quoteTxt = quoteObject?["text"] as! String
                let quoteAuthor = quoteObject?["author"] as! String
                let quoteSource = quoteObject?["source"] as! String
                let amazonID = quoteObject?["amazonID"] as! String
                let textToDisplay = "\"" +  quoteTxt + "\"" + " \n" + "-" + quoteAuthor + ", " + quoteSource
                completionQuote(textToDisplay, amazonID)
            })
        }
    }
    
    //gets the key of the last quote added to the database (last quote will have the highest index)
    func getMaxQuotes(completion:@escaping ((_ maxQuotes:Int)->Void)){
        refQuotes = Database.database().reference().child("quotes")
        refHandle = refQuotes.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            let maxQuotes = Int(snapshot.key)!
            completion(maxQuotes)
        })
    }
    
    
    @IBAction func favoriteButton(_ sender: UIBarButtonItem) {
        if(markAsFavoriteToggleState == 1){
            sender.image = UIImage(named:"icons8-Star Filled.png")
            markAsFavoriteToggleState  = 2
            
            
            let favoriteInsight = NSEntityDescription.insertNewObject(forEntityName: "FavoritedInsights", into: coreDataContext) as! FavoritedInsights
            
            favoriteInsight.insightTxt = self.quoteTxt
            favoriteInsight.insightDate = Date() as NSDate
            favoriteInsight.insightID = self.amazonID
            
            do{
                try coreDataContext.save()
            }
            catch{
                print(error)
            }
            
            
        }
        else{
            
            sender.image = UIImage(named:"icons8-Star.png")
            markAsFavoriteToggleState  = 1
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedInsights")
            request.sortDescriptors = [NSSortDescriptor(key: "insightDate", ascending: false)]
            request.predicate = NSPredicate(format: "insightTxt == %@", self.quoteTxt)
            

            
            let result = try? coreDataContext.fetch(request)
            
            if let objects = result as? [FavoritedInsights] {
                for insight in objects {
                    coreDataContext.delete(insight)
                }
            } else {
                print("fetch failed")
            }
            
            do{
                try coreDataContext.save()
            }
            catch{
                print(error)
            }
            
        }
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let message = self.quoteTxt!
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

