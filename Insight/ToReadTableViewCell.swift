//
//  ToReadTableViewCell.swift
//  Insight
//
//  Created by Josh Leikam on 7/17/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit

protocol ReadingCellDelegate{
    func didTapAmazonButton(url:String)
}

class ToReadTableViewCell: UITableViewCell{
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: ReadingCellDelegate?
    
    var bookItem: ReadingList!
    
    func setBook(book: ReadingList){
        bookItem = book
        titleLabel.text = book.readListTitle
        authorLabel.text = book.readListAuthor
        
    }
    
    @IBAction func amazonButton(_ sender: Any) {
        delegate?.didTapAmazonButton(url: bookItem.readListLink!)
    }
    

    
}
