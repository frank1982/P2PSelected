//
//  Product+CoreDataProperties.swift
//  P2P
//
//  Created by frank on 15/12/2.
//  Copyright © 2015年 frank. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Product {

    @NSManaged var author: String?
    @NSManaged var comments: NSNumber?
    @NSManaged var descript: String?
    @NSManaged var detailUrl: NSData?
    @NSManaged var downUrl: String?
    @NSManaged var flag0: NSNumber?
    @NSManaged var flag1: NSNumber?
    @NSManaged var headImage: NSData?
    @NSManaged var iconImage: NSData?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var title: String?

}
