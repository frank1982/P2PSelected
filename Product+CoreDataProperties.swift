

import Foundation
import CoreData

extension Product {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var title: String?
    @NSManaged var author: String?
    @NSManaged var descript: String?
    @NSManaged var headImage: NSData?
    @NSManaged var iconImage: NSData?
    @NSManaged var downUrl: String?
    @NSManaged var detailUrl: NSData?
    @NSManaged var comments: NSNumber?
    @NSManaged var flag0: NSNumber?
    @NSManaged var flag1: NSNumber?

}
