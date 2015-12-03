

import UIKit

class ViewController: UIViewController {
    
    var dao:Dao?
    var _color:UIColor!
    var pos0:CGPoint?
    var pos1:CGPoint?
    var pos2:CGPoint?
    var mainView:UIView!
    var menuView:UIView!
    var detailView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("init")
        var _constant=Constant()
        _color=_constant.getRandomColor()
        
        mainView=UIView(frame:self.view.frame)
        mainView.backgroundColor=_color
        self.view.addSubview(mainView)
        
        menuView=MenuView(frame: self.view.frame)
        menuView.backgroundColor=UIColor.whiteColor()
        self.view.addSubview(menuView)
        self.view.bringSubviewToFront(mainView)
        
        //addMenuIcon
        var menuIcon=UIButton(frame: CGRectMake(10, 21, 36, 24))
        menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Normal)
        menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Selected)
        //menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Reserved)
        //menuIcon.setImage(UIImage(named: "MenuIcon"), forState: UIControlState.Disabled)
        menuIcon.adjustsImageWhenHighlighted=false
        mainView.addSubview(menuIcon)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        pos0=(touches as NSSet).anyObject()?.locationInView(self.view)
        print(pos0)
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
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            self.mainView.frame.origin.x = self.view.frame.width*3/4
            self.menuView.viewWithTag(1001)!.layer.setAffineTransform(CGAffineTransformMakeScale(1,1))
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
            UIView.commitAnimations()
        }else{
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            self.mainView.frame.origin.x = 0
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
            UIView.commitAnimations()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

