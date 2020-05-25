//
//  FavoritesViewController.swift
//  in-sight
//
//  Created by Josh Leikam on 6/28/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating{
    
    @IBOutlet var noFavoritesView: UIView!
   
    var favoriteQuoteArray:[FavoritedInsights] = []
    var filteredQuoteArray:[FavoritedInsights] = []
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var searchController = UISearchController()

    @IBOutlet weak var favoritesSearchBar: UISearchBar!
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    @IBAction func editButton(_ sender: UIButton) {
        if (favoritesTableView.isEditing) {
            favoritesTableView.setEditing(false, animated: false)
            sender.setTitle("Edit", for: .normal)
        } else{
            favoritesTableView.setEditing(true, animated: true)
            sender.setTitle("Done", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favoritesTableView.estimatedRowHeight = 140
        self.favoritesTableView.rowHeight = UITableViewAutomaticDimension
        
        self.fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "load"), object: nil)
        

        

        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.favoritesTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        self.checkToDisplayNoView()
        
        self.favoritesTableView.reloadData()
        
        self.favoritesTableView.tableFooterView = UIView()


    }
    
    func willEnterForeground() {

        self.fetchData()
        
        self.checkToDisplayNoView()
        
        self.favoritesTableView.reloadData()

    }
    

    public func refresh(notification: NSNotification){
        self.fetchData()
        
        self.checkToDisplayNoView()
        
        self.favoritesTableView.reloadData()

    }
    
    func checkToDisplayNoView(){
        if(favoriteQuoteArray.count == 0){
            favoritesTableView.backgroundView = noFavoritesView
        }
        else{
            favoritesTableView.backgroundView = nil
        }
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.isActive) {
            return self.filteredQuoteArray.count
        }
        return favoriteQuoteArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoritesTableViewCell
        
        
        if (self.searchController.isActive) {
            let quote = filteredQuoteArray[indexPath.row]
            cell.quoteLabel.text = quote.insightTxt
            return cell
        }
        
        cell.selectionStyle = .none
        
        let quote = favoriteQuoteArray[indexPath.row]
        
        cell.quoteLabel.text = quote.insightTxt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            if(searchController.isActive){
                let favoriteInsight = filteredQuoteArray[indexPath.row]
                coreDataContext.delete(favoriteInsight)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                do{
                    favoriteQuoteArray = try coreDataContext.fetch(FavoritedInsights.fetchRequest())
                }
                catch{
                    print(error)
                }
                filteredQuoteArray.remove(at: indexPath.row)
                favoritesTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
                
            else{
                let favoriteInsight = favoriteQuoteArray[indexPath.row]
                coreDataContext.delete(favoriteInsight)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                do{
                    favoriteQuoteArray = try coreDataContext.fetch(FavoritedInsights.fetchRequest())
                }
                catch{
                    print(error)
                }
                
                
                favoritesTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
            }
            
        }
        
        self.checkToDisplayNoView()
        
    }
    
    func fetchData(){
        
        do{
            favoriteQuoteArray = try coreDataContext.fetch(FavoritedInsights.fetchRequest())
            favoriteQuoteArray = favoriteQuoteArray.reversed()
        }
        catch{
            print(error)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {

        filteredQuoteArray.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "insightTxt contains[c] %@", searchController.searchBar.text!)
        let array = (favoriteQuoteArray as NSArray).filtered(using: searchPredicate)
        
        for item in array
        {
            let item = item as! FavoritedInsights
            filteredQuoteArray.append(item)
        }
        
        self.favoritesTableView.reloadData()
    }
    
    
}
