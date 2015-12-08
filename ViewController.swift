

import UIKit

class ViewController: UIViewController,ProductViewDelegate,UIScrollViewDelegate {
    
    var dao:Dao=Dao()
    var _color:UIColor!
    var pos0:CGPoint?
    var pos1:CGPoint?
    var pos2:CGPoint?
    var mainView:UIView!
    var menuView:UIView!
    var detailView:UIView!
    var menuIcon:UIButton!
    var scrollView:UIScrollView!
    var iconScrollView:UIScrollView!
    var _constant=Constant()
    var oldIconNum:Int=0//计算icon弹出位置
    var lastNum:Int?//当前最后一条数据序号，从0开始
    var lastId:Int32?//当前显示出来的最后一条数据id
    
    var bgViewOfIcon:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _color=_constant.getRandomColor()
        
        mainView=UIView(frame:self.view.frame)
        mainView.backgroundColor=_color
        self.view.addSubview(mainView)
        
        menuView=MenuView(frame: self.view.frame)
        menuView.backgroundColor=UIColor.whiteColor()
        self.view.addSubview(menuView)
        self.view.bringSubviewToFront(mainView)
        
        //addMenuIcon
        menuIcon=UIButton(frame: CGRectMake(10, 31, 36, 24))
        menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Selected)
        //menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Reserved)
        //menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Disabled)
        menuIcon.adjustsImageWhenHighlighted=false
        mainView.addSubview(menuIcon)
        menuIcon.addTarget(self, action: "touchMenuIcon", forControlEvents: UIControlEvents.TouchUpInside)
        
        //add product scrollview
        scrollView=UIScrollView(frame:CGRectMake(0, 66, self.view.frame.width, self.view.frame.height-66-88))
        scrollView.pagingEnabled=true
        scrollView.showsHorizontalScrollIndicator=false
        scrollView.delegate=self
        mainView.addSubview(scrollView)
        
        //add icon scrollview
        iconScrollView=UIScrollView(frame:CGRectMake(0, self.view.frame.height-80, self.view.frame.width, 80))
        iconScrollView.showsHorizontalScrollIndicator=false
        mainView.addSubview(iconScrollView)
        
        //需要用bgview过渡一下，否则直接scrollView.addSubview的没有考虑conffset
        bgViewOfIcon=UIView(frame:CGRectMake(0, 0, self.view.frame.width, 80))
        iconScrollView.addSubview(bgViewOfIcon)
        
        
        //获取本地最新数据
        var product:Product = dao.findLocalNewestData()!
        //加载最新数据并显示
        /*
        for(var i=0;i<10;i++){
            loadScrollView(i,product:product)
            loadIconScrollView(i,product:product)
        }
        lastNum=9
        */
        
            loadScrollView(0,product:product)
            loadIconScrollView(0,product:product)
        
        lastNum=0
        

        self.iconScrollView.subviews[0].viewWithTag(1002)!.frame.origin.y -= 20
        
        //异步加载其他数据
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            //首先从服务端查询最长
            //let LOADNUM=10//一次显示或加载的最大数据数量
            //"/findNewestIDByLength.action"
            var productIDArray:NSArray=self.dao.findNewestIDByLength(self._constant.LOADNUM, id: (product.id?.intValue)!)!
            //print(self.dao.isDataExistInLocal((product.id?.intValue)!))
            for(var i=0;i<productIDArray.count;i++){
                
                //首先检查该条数据是否本地存在?
                var str:String=productIDArray[i] as! String
                //print(str)
                if self.dao.isDataExistInLocal(Int32(str)!) == false {//本地不存在
                    
                    //从服务端下载该条数据的完整信息
                    var tmpProduct = self.dao.getDataFromServerByID(str)
                    //print("\(str)从服务端下载")
                    self.dao.saveData(tmpProduct!)
                   
                                        //print(self.lastNum)
                        //通知主线程刷新
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            //print("准备将\(str)插入位置\(self.lastNum!)")
                            self.loadScrollView(self.lastNum!+1,product:tmpProduct!)
                            self.loadIconScrollView(self.lastNum!+1,product:tmpProduct!)
                            self.lastNum = self.lastNum!+1
                            self.lastId=tmpProduct!.id?.intValue
                            //print("当前最后一条数据的id是:\(self.lastId)")

                        });
                    
                }else{//本地已经有该条数据
                    
                    //print("\(str)本地已经有该条数据")
                    var tmpProduct2 = self.dao.findLocalDataById(Int32(str)!)
                    
                    //print("准备将\(str)插入位置\(self.lastNum!)")
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //print("now num is:\(self.lastNum!)")
                        self.loadScrollView(self.lastNum!+1,product:tmpProduct2!)
                        self.loadIconScrollView(self.lastNum!+1,product:tmpProduct2!)
                        self.lastNum = self.lastNum!+1
                        self.lastId=tmpProduct2!.id?.intValue
                        //print("当前最后一条数据的id是:\(self.lastId)")
                    });
                }
                
            }
            
        })
        

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        self.scrollView.scrollEnabled=false
        //sleep(1)
        var pageNo = Int(self.scrollView.contentOffset.x/self.view.frame.width)
        //print("pageNo is: \(pageNo)")
        
        //iconScroll roll
        var cellWidth=(self.view.frame.width)/CGFloat(_constant.ICONNUMBERSHOWINSCREEN)
        //if self.iconScrollView.contentOffset.x
        
        if pageNo >= 4 {
            
            self.iconScrollView.setContentOffset(CGPoint(x:cellWidth*CGFloat(pageNo-4),y:0), animated: true)//animated=true，异步动画

        }
        
        if pageNo >= lastNum{

            loadMore(lastNum!)
            
        }
        //icon jump
        if pageNo != oldIconNum {
            
            self.iconScrollView.viewWithTag(6000+oldIconNum)?.viewWithTag(1002)?.frame.origin.y += 20
            UIView.animateWithDuration(0.1,
                animations: {
                    self.iconScrollView.viewWithTag(6000+pageNo)?.viewWithTag(1002)?.frame.origin.y -= 20
                },
                completion: {
                    (finished) in
                    UIView.animateWithDuration(0.2, delay: 0,usingSpringWithDamping: 0.2,initialSpringVelocity: 5.0,options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            self.iconScrollView.viewWithTag(6000+pageNo)?.viewWithTag(1002)?.frame.origin.y += 6
                        }, completion: {
                            (finished:Bool)->Void in
                            UIView.animateWithDuration(0.2, delay: 0,usingSpringWithDamping: 0.2,initialSpringVelocity: 5.0,options: UIViewAnimationOptions.CurveEaseOut,
                                animations: {
                                     self.iconScrollView.viewWithTag(6000+pageNo)?.viewWithTag(1002)?.frame.origin.y -= 3
                                }, completion: nil)
                           
                    })})

            oldIconNum=pageNo
        }
        
        
        self.scrollView.scrollEnabled=true
    }
    
    //从服务器申请下载从lastNum开始的，最大长度为LOADNUM的id序号数组
    func loadMore(lastNum:Int){
        
        //print("loadMore")
        //加载loading
        var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicatorView.color=_constant.getRandomColor()
        activityIndicatorView.center=self.view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            //首先从服务端查询最长
            //let LOADNUM=10//一次显示或加载的最大数据数量
            //"/findNewestIDByLength.action"
            var productIDArray:NSArray=self.dao.findNewestIDByLength(self._constant.LOADNUM, id: self.lastId!)!
            for(var i=0;i<productIDArray.count;i++){
                
                    var str:String=productIDArray[i] as! String
                    //从服务端下载该条数据的完整信息
                    var tmpProduct = self.dao.getDataFromServerByID(str)
                    //print("\(str)从服务端下载")
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //print("准备插入位置\(self.lastNum!)")
                        //print("load more finish")
                        //print("当前conffset is:\(self.iconScrollView.contentOffset.x)")
                        self.loadScrollView(self.lastNum!+1,product:tmpProduct!)
                        self.loadIconScrollView(self.lastNum!+1,product:tmpProduct!)
                        self.lastNum = self.lastNum!+1
                        self.lastId=tmpProduct!.id?.intValue
                        //print("当前最后一条数据的id是:\(self.lastId)")
                        activityIndicatorView.stopAnimating()
                    });
            }
            
            
        })

    }
    
    func addDetailView(product:Product){
        
        detailView=DetailView(frame: self.view.frame,product: product)
        detailView.frame.origin.x = self.view.frame.width
        self.view.addSubview(detailView)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        detailView.frame.origin.x = 0
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
        UIView.commitAnimations()
    }
    
    func loadScrollView(num:Int,product:Product){
        
        var productView=ProductView(frame: CGRectMake(CGFloat(num)*self.view.frame.width,0,self.view.frame.width,self.view.frame.height-66-88),num: num,product: product)
        productView.delegate=self
        self.scrollView.addSubview(productView)
        scrollView.contentSize=CGSize(width: CGFloat(num+1)*self.view.frame.width,height: self.view.frame.height-66-88)
    }
    
    func loadIconScrollView(num:Int,product:Product){
        
        var cellWidth=(self.view.frame.width)/CGFloat(_constant.ICONNUMBERSHOWINSCREEN)
        var iconView=IconView(frame: CGRectMake(CGFloat(num)*cellWidth,80-cellWidth,cellWidth,cellWidth),num: num,product: product)
        iconView.tag=6000+num//区分不同的icon
        bgViewOfIcon.addSubview(iconView)
        iconScrollView.contentSize=CGSize(width: bgViewOfIcon.frame.width,height: 80)
        
        /*
        var cellWidth=(self.view.frame.width)/CGFloat(_constant.ICONNUMBERSHOWINSCREEN)
        var iconView=IconView(frame: CGRectMake(CGFloat(num)*cellWidth,80-cellWidth,cellWidth,cellWidth),num: num,product: product)
        iconView.tag=6000+num//区分不同的icon
        self.iconScrollView.addSubview(iconView)
        iconScrollView.contentSize=CGSize(width: CGFloat(num+1)*cellWidth,height: 80)
        */
    }
    
    
    func touchMenuIcon(){
        
        if self.mainView.frame.origin.x >= self.view.frame.width/2 {
            
            //hideMenu
            hideMenu()           
        }else{
            
            //showMenu
            showMenu()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        pos0=(touches as NSSet).anyObject()?.locationInView(self.view)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        pos1=(touches as NSSet).anyObject()?.locationInView(self.view)
        var dx=pos1!.x-pos0!.x
        pos0=pos1//获取变化的速度，否则太快
        dx = max(-self.mainView.frame.origin.x,dx)//左边界...
        dx = min(self.view.frame.width*3/4-self.mainView.frame.origin.x,dx)//右边界...
        self.mainView.frame.origin.x += dx
        var scale=self.mainView.frame.origin.x/(self.view.frame.width*3/4)
        self.menuView.viewWithTag(1001)!.layer.setAffineTransform(CGAffineTransformMakeScale(scale,scale))
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(self.mainView.frame.origin.x >= self.view.frame.width/2){
            
            showMenu()
        }else{
            
            hideMenu()
        }

    }
    
    func showMenu(){
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.mainView.frame.origin.x = self.view.frame.width*3/4
        self.menuView.viewWithTag(1001)!.layer.setAffineTransform(CGAffineTransformMakeScale(1,1))
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
        UIView.commitAnimations()

    }
    
    func hideMenu(){
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.mainView.frame.origin.x = 0
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
        UIView.commitAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

