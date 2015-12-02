

import UIKit
import CoreData

class Dao {
    
    let URL:String="http://120.26.215.42:8080"
    
    //查找本地最新的数据id
    func findLocalNewID()->String?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var product=NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
        
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors=[sortDescrpitor]
        
        var id:String?
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            for _product:Product in fetchObjects as! [Product]{
                
                id=_product.id
            }
        }catch{
            print(error)
        }
        return id
    }
    
    //从服务端查询最新数据id,采用同步方式
    func getNewestInfoFromServer()->String?{
        
        var urlString=URL+"/touWhat/getNewestInfo.action"
        var nsUrl:NSURL=NSURL(string:urlString)!
        var request:NSURLRequest=NSURLRequest(URL: nsUrl)
        var response:NSURLResponse?
        var error:NSError?
        var result:String?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            result=NSString(data:data,encoding:NSUTF8StringEncoding) as! String
            
        }catch(let error){
            print("查找服务器最新编号失败...")
            print(error)
        }
        return result
    }
}
