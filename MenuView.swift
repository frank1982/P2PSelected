

import UIKit

class MenuView: UIView {
    
    var bkView:UIView!
    
    override init(frame:CGRect){
       
        super.init(frame: frame)
        var _constant=Constant()
        
        bkView=UIView(frame:frame)
        bkView.backgroundColor=UIColor.clearColor()
        bkView.tag=1001
        self.addSubview(bkView)
        
        var headIcon:UIImageView=UIImageView()
        headIcon.image=UIImage(named:"MenuHead")
        headIcon.sizeToFit()
        headIcon.frame.origin=CGPoint(x:25,y:35)
        bkView.addSubview(headIcon)
        
        //head label
        var headLabel=UILabel()
        headLabel.text="登录"
        headLabel.font=UIFont(name: _constant._textFont, size: 28)
        headLabel.sizeToFit()
        headLabel.textColor=UIColor.whiteColor()
        headLabel.frame.origin.y=headIcon.frame.origin.y+headIcon.frame.height/2-headLabel.frame.height/2
        headLabel.frame.origin.x=headIcon.frame.origin.x+headIcon.frame.width+20
        bkView.addSubview(headLabel)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
