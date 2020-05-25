//
//  FavoriteInsight.swift
//  Insight
//
//  Created by Josh Leikam on 7/15/17.
//  Copyright © 2017 Josh Leikam. All rights reserved.
//

import UIKit
import CoreData

class FavoritedInsight: NSManagedObject {
    
    @NSManaged var insightTxt: String
    @NSManaged var insightDate: NSDate
    @NSManaged var insightID: String
    
}

