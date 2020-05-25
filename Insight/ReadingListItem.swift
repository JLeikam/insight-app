//
//  ReadingListItem.swift
//  Insight
//
//  Created by Josh Leikam on 7/17/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import CoreData

class ReadingListItem: NSManagedObject {
    
    @NSManaged var readListAuthor: String
    @NSManaged var readListTitle: String
    @NSManaged var readListLink: String
    @NSManaged var readListDate: NSDate
    
}
