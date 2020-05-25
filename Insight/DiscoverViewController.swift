//
//  DiscoverViewController.swift
//  Insight
//
//  Created by Josh Leikam on 7/14/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import SafariServices
import CoreData
import FirebaseDatabase

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,XMLParserDelegate, DiscoverCellDelegate{
    
    @IBOutlet var loadingView: UIView!
    
    
    var refQuotes: DatabaseReference!
    var refHandle : UInt!

    
    var books: [AmazonBookModel] = []
    var bookTitle = String()
    var bookAuthor = String()
    var bookLink = String()
    var eName: String = String()
    
    var insightID: String!
    var currentID: String!
    var didChangeID = false
    
    
    var parser = XMLParser()
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    @IBOutlet weak var discoverTableView: UITableView!
    

    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        //remove separator lines while loading page
        self.discoverTableView.tableFooterView = UIView()
        
        self.discoverTableView.estimatedRowHeight = 140
        self.discoverTableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRecentFavorite(){
        
        self.insightID = nil
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedInsights")
        request.sortDescriptors = [NSSortDescriptor(key: "insightDate", ascending: false)]
        request.fetchLimit = 1
        
        let result = try? coreDataContext.fetch(request)
        
        if let objects = result as? [FavoritedInsights] {
            for insight in objects {
                self.insightID = insight.insightID
                
            }
        } else {
            print("failed")

        }
        

        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        fetchRecentFavorite()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.parseXml()
        })
        
        books = []
        if(books.count == 0){
            self.discoverTableView.backgroundView = loadingView
        }
        else{
            self.discoverTableView.backgroundView = nil
        }
        
        self.discoverTableView.reloadData()

    }
    
    func willEnterForeground(){
        fetchRecentFavorite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.parseXml()
        })
        
        books = []
        if(books.count == 0){
            self.discoverTableView.backgroundView = loadingView
        }
        else{
            self.discoverTableView.backgroundView = nil
        }
        
        self.discoverTableView.reloadData()
        

    }
    
    func parseXml(){

        
        if(self.insightID == nil){
        _ = getAmazonID(completionAmazonID: { (amazonID) in
                let url = AmazonSigning().getAmazonRequestURLFor(amazonID)
                
                let urlToSend: URL = URL(string: url)!
                
                self.parser = XMLParser(contentsOf: urlToSend)!
                self.parser.delegate = self
                
                let success:Bool = self.parser.parse()
                
                if success {
                    print("parse success!")
                    
                } else {
                    print("parse failure!")
                }
                
                self.discoverTableView.reloadData()
            })
        }
        else{
            let url = AmazonSigning().getAmazonRequestURLFor(self.insightID)
            
            let urlToSend: URL = URL(string: url)!
            
            self.parser = XMLParser(contentsOf: urlToSend)!
            self.parser.delegate = self
            
            let success:Bool = self.parser.parse()
            
            if success {
                print("parse success!")
                
            } else {
                print("parse failure!")
            }
            
            self.discoverTableView.reloadData()
        }


    }
    
    
    //MARK - Firebase
    
    //returns todays date as a num 1 - inifinity. uses jan1 and 1970 to calculate a hard start date
    func getDay() -> Int{
        let today = Date()
        let secondsSince1970 = Int(today.timeIntervalSince1970) //seconds since 1970
        let secondsSinceJan12017 = 1483228800 + (3600 * 5) //convert to CST time
        let secondsInDay = 86400
        let day = ((secondsSince1970 - secondsSinceJan12017)/secondsInDay) + 1
        
        return day
    }
    
    //gets the key of the last quote added to the database (last quote will have the highest index)
    func getMaxQuotes(completion:@escaping ((_ maxQuotes:Int)->Void)){
        refQuotes = Database.database().reference().child("quotes")
        refHandle = refQuotes.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            let maxQuotes = Int(snapshot.key)!
            completion(maxQuotes)
        })
    }
    
    
    func getAmazonID(completionAmazonID:@escaping ((_ amazonID:String)->Void)){
        let day = getDay()
        _ = getMaxQuotes { (maxQuotes) in
            let quoteNumber = (day % maxQuotes)
            self.refQuotes = Database.database().reference().child("quotes")
            self.refHandle = self.refQuotes.child(String(quoteNumber)).observe(DataEventType.value, with: { (snapshot) in
                let quoteObject = snapshot.value as? [String: AnyObject]
                let amazonID = quoteObject?["amazonID"] as! String
                completionAmazonID(amazonID)
            })
        }
        
    }

    
    //MARK - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoverCell", for: indexPath) as! DiscoverTableViewcell
        
        let book = books[indexPath.row]
        
        cell.selectionStyle = .none
        cell.setBook(book: book)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    //MARK - Buttons
    func didTapAmazonButton(url: String) {
        let bookURL = URL(string: url)
        let safariVC = SFSafariViewController(url: bookURL!)
        present(safariVC, animated: true, completion: nil)
    
    }
    
    func didTapReadingButton(){
        
    }
    
    //MARK - XMLParser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        eName = elementName
        
        if elementName == "Item" {
            bookTitle = String()
            bookAuthor = String()
            bookLink = String()
        }
        
    
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
        if elementName == "Item" {
            
            let book = AmazonBookModel()
            book.bookTitle = bookTitle
            book.bookAuthor = bookAuthor
            book.bookLink = bookLink
            books.append(book)
        }

        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if eName == "Title" {
                bookTitle += data
            } else if eName == "Author" {
                bookAuthor += data
            }
            else if eName == "DetailPageURL"{
                bookLink += data
            }
        }


    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }
    

}
