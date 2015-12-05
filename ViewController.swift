

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
    var lastId:Int?//当前显示出来的最后一条数据id
    
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
                    print("\(str)从服务端下载")
                    self.dao.saveData(tmpProduct!)
                   
                                        print(self.lastNum)
                        //通知主线程刷新
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            print("准备将\(str)插入位置\(self.lastNum!)")
                            self.loadScrollView(self.lastNum!+1,product:tmpProduct!)
                            self.loadIconScrollView(self.lastNum!+1,product:tmpProduct!)
                            self.lastNum = self.lastNum!+1

                        });
                    
                }else{//本地已经有该条数据
                    
                    print("\(str)本地已经有该条数据")
                    var tmpProduct2 = self.dao.findLocalDataById(Int32(str)!)
                    
                    print("准备将\(str)插入位置\(self.lastNum!)")
                    //通知主线程刷新
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        print("now num is:\(self.lastNum!)")
                        self.loadScrollView(self.lastNum!+1,product:tmpProduct2!)
                        self.loadIconScrollView(self.lastNum!+1,product:tmpProduct2!)
                        self.lastNum = self.lastNum!+1
                    });
                }
                
            }
            
        })
        

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        var pageNo = Int(self.scrollView.contentOffset.x/self.view.frame.width)
        print("pageNo is: \(pageNo)")
        
        //iconScroll roll
        var cellWidth=(self.view.frame.width)/CGFloat(_constant.ICONNUMBERSHOWINSCREEN)
        //if self.iconScrollView.contentOffset.x
        
        if pageNo >= 4 {
            
            self.iconScrollView.setContentOffset(CGPoint(x:cellWidth*CGFloat(pageNo-4),y:0), animated: true)
        }
        
        //icon jump
        if pageNo != oldIconNum {
            
            print("wewqe")
            print(self.iconScrollView.subviews[1])
            self.iconScrollView.subviews[pageNo].viewWithTag(1002)?.frame.origin.y -= 20
            self.iconScrollView.subviews[oldIconNum].viewWithTag(1002)?.frame.origin.y += 20
            oldIconNum=pageNo
        }
        
        if pageNo >= lastNum{
            
            loadMore(lastNum!)
        }
        
    }
    
    //从服务器申请下载从lastNum开始的，最大长度为LOADNUM的id序号数组
    func loadMore(lastNum:Int){
        
        print("loadMore")
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
        self.iconScrollView.addSubview(iconView)
        iconScrollView.contentSize=CGSize(width: CGFloat(num+1)*cellWidth,height: 80)
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

