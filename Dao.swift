

import UIKit
import CoreData

class Dao {
    
    let URL:String="http://120.26.215.42:8080"
    //let URL:String="http://127.0.0.1:8080"
    
    
    //根据id查找本地一条数据的明细
    func findLocalDataById(id:Int32)->Product?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        //var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        //fetchRequest.sortDescriptors=[sortDescrpitor]
        //设置查询条件
        let predicate=NSPredicate(format: "id = %i", id)
        fetchRequest.predicate=predicate
        
        var result:Product?
        
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    result=_product
                }
            }
            
        }catch{
            print("根据id查找本地一条数据的明细失败")
        }
        return result!
    }

    
    //根据id查找一条数据是否在本地存在
    func isDataExistInLocal(id:Int32)->Bool{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        //var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        //fetchRequest.sortDescriptors=[sortDescrpitor]
        //设置查询条件
        let predicate=NSPredicate(format: "id = %i", id)
        fetchRequest.predicate=predicate
        
        var result:Bool?
        
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                result=true
            }else{
                result=false
            }
            
        }catch{
            print("根据id查找一条数据是否在本地失败")
        }
        return result!
    }
    
    //从服务端查询从id开始的num个数据序号，不包含id本身
    func findNewestIDByLength(num:Int,id:Int32)->NSArray?{
        
        //print("findNewestIDByLength")
        var urlString=URL+"/touWhat/findNewestIDByLength.action?num="+String(num)+"&id="+String(id)
        var nsUrl:NSURL=NSURL(string:urlString)!
        var request:NSURLRequest=NSURLRequest(URL: nsUrl)
        var response:NSURLResponse?
        var error:NSError?
        var result:NSArray?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            var str=NSString(data:data,encoding:NSUTF8StringEncoding)
            result=str?.componentsSeparatedByString("*")
            //print(result)
            
        }catch(let error){
            print("查找服务器从id开始的num个id失败")
        }
        return result

    }
    
    
    //获取本地最新的一条数据明细
    func findLocalNewestData()->Product?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors=[sortDescrpitor]
        
        var result:Product?
        
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    result=_product
                }
            }
            
        }catch{
            print("获取本地最新一条数据明细失败")
        }
        return result

    }

    //查找本地最新的数据id
    func findLocalNewID()->Int32?{
 
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors=[sortDescrpitor]
        
        var result:Int32?

        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    result=_product.id!.intValue
                }
            }
            
        }catch{
            
        }
        return result
        
    }
    
    //从服务端查询最新数据id,采用同步方式
    func getNewestInfoFromServer()->Int32?{
        
        var urlString=URL+"/touWhat/getNewestInfo.action"
        var nsUrl:NSURL=NSURL(string:urlString)!
        var request:NSURLRequest=NSURLRequest(URL: nsUrl)
        var response:NSURLResponse?
        var error:NSError?
        var result:Int32?
        do {
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            result=NSString(data:data,encoding:NSUTF8StringEncoding)?.intValue
            
        }catch(let error){
            print("查找服务器最新编号失败...")
        }
        return result
    }
    
    //根据id从服务端同步获取数据明细
    func getDataFromServerByID(id:String)->Product?{
        
        //print("getDataFromServerByID:\(id)")
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
        product.id=jsonResult["id"] as! NSNumber
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
    func localSaveProductNum()->Int?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context = app.managedObjectContext
        var error:NSError?
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
        return num
    }
    
    //删除本地最旧一条数据
    func delLocalOldestData(){
        
        //print("delLocalOldestData")
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
                    }catch(let error){
                        print("删除本地最旧一条数据失败...")
                        print("error")
                    }
                }
            }
        }catch(let error){
            
            print("在执行删除本地最旧一条数据时，查询本地数据失败...")
            print("error")
        }
        print("删除本地最旧一条数据...")

    }
    
}
