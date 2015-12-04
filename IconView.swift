

import UIKit

class IconView: UIView {

    
    init(frame: CGRect,num:Int,product:Product) {
        
        super.init(frame: frame)
        
        var _constant=Constant()
        var bgView=UIView(frame:CGRectMake(1, 0, self.frame.width-2, self.frame.height))
        bgView.backgroundColor=UIColor.whiteColor()
        bgView.layer.cornerRadius=8
        bgView.tag=1002
        self.addSubview(bgView)
        
        var iconImage=UIImageView(frame:CGRectMake(1, 1, bgView.frame.width-2, bgView.frame.height-2))
        iconImage.image=UIImage(data: product.iconImage!)
        iconImage.contentMode=UIViewContentMode.ScaleToFill
        bgView.addSubview(iconImage)
     
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print("touch")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
