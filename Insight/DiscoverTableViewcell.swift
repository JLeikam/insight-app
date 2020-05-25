//
//  DiscoverTableViewcell.swift
//  Insight
//
//  Created by Josh Leikam on 7/16/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import CoreData

protocol DiscoverCellDelegate{
    func didTapAmazonButton(url:String)
    func didTapReadingButton()
}

class DiscoverTableViewcell: UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var readingListButton: UIButton!
    var addToReadingListToggleState = 1
    var bookLink = String()
    var readingListArray: [ReadingList] = []
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var bookItem: AmazonBookModel!
    

    
    var delegate: DiscoverCellDelegate?

    
    func setBook(book: AmazonBookModel){
        bookItem = book
        titleLabel.text = book.bookTitle
        authorLabel.text = book.bookAuthor
        bookLink = book.bookLink
        
        self.checkBook()

    }
    
    func checkBook(){
        
        self.addToReadingListToggleState = 1
        
        self.readingListButton.setImage(UIImage(named:"icons8-Add List-100.png"), for: .normal)
        
        self.readingListArray = try! self.coreDataContext.fetch(ReadingList.fetchRequest())
        
        
        for book in self.readingListArray{
            if(bookItem.bookLink == book.readListLink){
                print("match")
                self.readingListButton.setImage(UIImage(named:"icons8-Add List Filled-100.png"), for: .normal)
                self.addToReadingListToggleState = 2
            }
            
        }
        
        
        
    }
    
    @IBAction func amazonButton(_ sender: Any) {
        delegate?.didTapAmazonButton(url: bookItem.bookLink)
    }
    
    @IBAction func readingListButton(_ sender: UIButton) {
        if(addToReadingListToggleState == 1){
            sender.setImage(UIImage(named:"icons8-Add List Filled-100.png"), for: .normal)
           addToReadingListToggleState = 2
            
            
            let readingListItem = NSEntityDescription.insertNewObject(forEntityName: "ReadingList", into: coreDataContext) as! ReadingList
            
            readingListItem.readListAuthor = bookItem.bookAuthor
            readingListItem.readListTitle = bookItem.bookTitle
            readingListItem.readListLink = bookItem.bookLink
            readingListItem.readListDate = Date() as NSDate

            
            do{
                try coreDataContext.save()
            }
            catch{
                print(error)
            }
        }
            else{
                
                sender.setImage(UIImage(named:"icons8-Add List-100.png"), for: .normal)
                addToReadingListToggleState  = 1
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadingList")
                request.sortDescriptors = [NSSortDescriptor(key: "readListDate", ascending: false)]
                request.predicate = NSPredicate(format: "readListLink == %@", bookItem.bookLink)
                
            
                let result = try? coreDataContext.fetch(request)
                
                if let objects = result as? [ReadingList] {
                    for readingListItem in objects {
                        coreDataContext.delete(readingListItem)
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
}

