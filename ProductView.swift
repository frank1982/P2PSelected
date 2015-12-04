

import UIKit
import CoreData

class ProductView: UIView {
    
    var delegate:ProductViewDelegate?
    var _product:Product?

    init(frame: CGRect,num:Int,product:Product) {
        
        super.init(frame: frame)
        
        _product=product
        var _constant=Constant()
        var bgView=UIView(frame:CGRectMake(10, 0, self.frame.width-20, self.frame.height))
        bgView.backgroundColor=UIColor.whiteColor()
        bgView.layer.cornerRadius=8
        self.addSubview(bgView)
        
        var name=UILabel()
        name.text=product.name
        name.font=UIFont(name: _constant._textFont, size: 20)
        name.sizeToFit()
        name.center=CGPoint(x: 10+name.frame.width/2,y: 33)
        bgView.addSubview(name)
        
        var title=UILabel()
        title.text=product.title
        title.font=UIFont(name: _constant._textFont, size: 16)
        title.sizeToFit()
        title.center=CGPoint(x: 10+name.frame.width+10+title.frame.width/2,y: 33)
        bgView.addSubview(title)
        
        var headImage=UIImageView(frame:CGRectMake(0, 66, self.frame.width-20, self.frame.height*0.25))
        headImage.image=UIImage(data: product.headImage!)
        headImage.contentMode=UIViewContentMode.ScaleToFill
        bgView.addSubview(headImage)
        
        var str=product.descript
        var attributedString=NSMutableAttributedString(string: str!)
        var paragraphStyle=NSMutableParagraphStyle()
        //设置行间距
        paragraphStyle.lineSpacing=8
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0,NSString(string: str!).length))
        //设置字体...
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: _constant._textFont, size: 14)!, range: NSMakeRange(0,NSString(string: str!).length))
        //计算文字占据的尺寸大小，其中CGSize为约束限制
        var fontSize=attributedString.boundingRectWithSize(CGSize(width: self.frame.width-40,height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var descriptLabel=UILabel()
        descriptLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        descriptLabel.numberOfLines = 0
        descriptLabel.attributedText = attributedString
        var height=min(fontSize.height,self.frame.height-headImage.frame.origin.y-headImage.frame.height-10-76)
        descriptLabel.frame=CGRectMake(10, headImage.frame.origin.y+headImage.frame.height+20, fontSize.width, height)//高度取最小值
        bgView.addSubview(descriptLabel)
        
        var author=UILabel()
        author.text=product.author
        author.font=UIFont(name: _constant._textFont, size: 16)
        author.sizeToFit()
        author.center=CGPoint(x: self.frame.width-20-10-author.frame.width/2,y: self.frame.height-33)
        bgView.addSubview(author)


    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        delegate?.addDetailView(_product!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}

protocol ProductViewDelegate{
    
    func addDetailView(product:Product)
}
