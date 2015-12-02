

import UIKit
import CoreData

class Dao {
    
    let URL:String="http://120.26.215.42:8080"
    //let URL:String="http://127.0.0.1:8080"
    
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
        }
        return result
    }
    
    //根据id从服务端同步获取数据明细
    func getDataFromServerByID(id:String)->Product?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var urlString=URL+"/touWhat/getProductInfoByID2.action?id="+id
        var url:NSURL=NSURL(string:urlString)!
        var urlRequest:NSURLRequest=NSURLRequest(URL: url)
        var response:NSURLResponse?
        var error:NSError?
        var jsonResult:NSDictionary!
        var product=NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product

        do{
            let data = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &response)
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        }
        catch{
            print("根据id:\(id)从服务端获取对应数据明细失败")
        }
        product.id=String(jsonResult["id"] as? NSNumber)
        product.name=jsonResult["name"] as! String
        product.title=jsonResult["title"] as! String
        product.author=jsonResult["author"] as! String
        product.descript=jsonResult["descript"] as! String
        product.downUrl=jsonResult["downUrl"] as! String
        product.comments=jsonResult["comments"] as! NSNumber
        product.flag0=jsonResult["flag0"] as! NSNumber
        product.flag1=jsonResult["flag1"] as! NSNumber
        
        do {
            var imgHeadUrl=jsonResult["headImage"] as! String
            var data:NSData?=NSData(contentsOfURL: NSURL(string: imgHeadUrl)!)
            product.headImage=data
        }catch {print("下载网络图片失败")}
        
        do {
            var imgIconUrl=jsonResult["iconImage"] as! String
            var data:NSData?=NSData(contentsOfURL: NSURL(string: imgIconUrl)!)
            product.iconImage=data
        }catch {print("下载网络图片失败")}
        
        //array<NSDictionary> to NSData
        var data=NSData(data: NSKeyedArchiver.archivedDataWithRootObject(jsonResult["detailUrl"] as! Array<NSDictionary>))
        product.detailUrl=data
        
        return product
    }
    
    //将一条Product数据持久化
    func saveData(product:Product){
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var _product=NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
        _product=product
        do{
            try context.save()
        }catch{
            print("将一条Product数据持久化失败")
        }
    }
    
    //查找本地已经存储的数据数量
    func localSaveProductNum()->Int{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var product=NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        
        var num:Int?
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            num=fetchObjects.count
  
        }catch{
            print("查找本地已经存储的数据数量失败")
        }
        return num!
    }
    
    //删除本地最旧一条数据
    func delLocalOldestData(){
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        //降序排序...
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: true,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors = [sortDescrpitor]
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    context.deleteObject(_product)
                    do{
                        try context.save()
                        print("本地最旧数据\(_product.id)已经删除")
                    }catch(let error){
                        print("本地最旧数据\(_product.id)删除失败")
                    }
                }
            }
        }catch(let error){
            
            print("在执行删除本地最旧数据时，查询本地数据失败...")
        }
    }
    
}
