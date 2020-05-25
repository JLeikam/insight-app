//
//  ToReadViewController.swift
//  Insight
//
//  Created by Josh Leikam on 7/16/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import SafariServices

class ToReadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, ReadingCellDelegate {
    


    @IBOutlet var noReadView: UIView!
    
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController = UISearchController()
    
    var readingListArray:[ReadingList] = []
    var filteredListArray:[ReadingList] = []

    
    @IBOutlet weak var readingTableView: UITableView!
    
    @IBAction func editButton(_ sender: UIButton) {
        if (readingTableView.isEditing) {
            readingTableView.setEditing(false, animated: false)
            sender.setTitle("Edit", for: .normal)
        } else{
            readingTableView.setEditing(true, animated: true)
            sender.setTitle("Done", for: .normal)
        }
    }
    
    func didTapAmazonButton(url: String) {
        let bookURL = URL(string: url)
        let safariVC = SFSafariViewController(url: bookURL!)
        present(safariVC, animated: true, completion: nil)
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.readingTableView.estimatedRowHeight = 140
        self.readingTableView.rowHeight = UITableViewAutomaticDimension
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.readingTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        self.fetchData()
        
        definesPresentationContext = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        self.readingTableView.tableFooterView = UIView()
        self.checkToDisplayNoView()
    }
    
    func willEnterForeground(){
        self.fetchData()
        self.readingTableView.reloadData()
        self.checkToDisplayNoView()
    }
    
    func refresh(notification: NSNotification){
        self.fetchData()
        self.readingTableView.reloadData()
        self.checkToDisplayNoView()
    }
    
    func checkToDisplayNoView(){
        if(readingListArray.count == 0){
            readingTableView.backgroundView = noReadView
        }
        else{
            readingTableView.backgroundView = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.isActive) {
            return self.filteredListArray.count
        }
        return readingListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ToReadTableViewCell
        
        
        if (self.searchController.isActive) {
            let book = filteredListArray[indexPath.row]
            cell.setBook(book: book)
            cell.delegate = self
            return cell
        }
        
        cell.selectionStyle = .none
        
        let book = readingListArray[indexPath.row]
        
        cell.setBook(book: book)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            if(searchController.isActive){
                 let readingListItem = filteredListArray[indexPath.row]
                coreDataContext.delete(readingListItem)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                do{
                    readingListArray = try coreDataContext.fetch(ReadingList.fetchRequest())
                }
                catch{
                    print(error)
                }
                filteredListArray.remove(at: indexPath.row)
                readingTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            
            else{
                let readingListItem = readingListArray[indexPath.row]
                coreDataContext.delete(readingListItem)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                do{
                    readingListArray = try coreDataContext.fetch(ReadingList.fetchRequest())
                }
                catch{
                    print(error)
                }
                
                
                readingTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
            }
          
        }
        
        self.checkToDisplayNoView()
        
    }
    
    func fetchData(){
        
        do{
            readingListArray = try coreDataContext.fetch(ReadingList.fetchRequest())
            readingListArray = readingListArray.reversed()
        }
        catch{
            print(error)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        
        let searchPredicateTitle = NSPredicate(format: "readListTitle contains[c] %@", searchController.searchBar.text!)
        let searchPredicateAuthor = NSPredicate(format: "readListAuthor contains[c] %@", searchController.searchBar.text!)
        let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [searchPredicateTitle,searchPredicateAuthor])
        
        filteredListArray.removeAll(keepingCapacity: false)
        
        let array = (readingListArray as NSArray).filtered(using: predicateCompound)
        
        for item in array
        {
            let item = item as! ReadingList
            filteredListArray.append(item)
        }
        
        self.readingTableView.reloadData()
    }
    

    deinit {
        self.searchController.view.removeFromSuperview()
    }

}
