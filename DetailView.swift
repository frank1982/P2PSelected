
import UIKit

class DetailView: UIView,UIScrollViewDelegate,ScrollViewDelegate {

    var _product:Product?
    var _pos:CGFloat?//测量高度
    var pos0:CGPoint?
    var pos1:CGPoint?
    var pos2:CGPoint?
    
    init(frame: CGRect,product:Product) {
        
        super.init(frame: frame)
        
        var _constant=Constant()
        _product=product
        
        //add scroll
        var detailScroll=UIScrollView(frame:self.frame)
        detailScroll.backgroundColor=UIColor.whiteColor()
        self.addSubview(detailScroll)
        
        var contentView=ScrollContentView(frame:self.frame)
        contentView.delegate=self
        detailScroll.addSubview(contentView)
        
        //add headImage
        var headImage=UIImageView(frame:CGRectMake(0,0,self.frame.width,self.frame.height*0.25))
        headImage.image=UIImage(data: product.headImage!)
        headImage.contentMode=UIViewContentMode.ScaleToFill
        contentView.addSubview(headImage)
        
        //add tool area
        var toolView=UIView(frame:CGRectMake(0,headImage.frame.origin.y+headImage.frame.height,self.frame.width,self.frame.height*0.15))
        toolView.backgroundColor=UIColor.whiteColor()
        contentView.addSubview(toolView)
        
        //add icon in tool area
        var imageHeight = toolView.frame.height-60
        var icon=UIImageView(frame:CGRectMake(20, 30, imageHeight, imageHeight))
        icon.image=UIImage(data: product.iconImage!)
        icon.contentMode=UIViewContentMode.ScaleToFill
        toolView.addSubview(icon)
        
        //add name in tool area
        var name=UILabel()
        name.text=product.name!
        name.font=UIFont(name: _constant._textFont, size: 16)
        name.sizeToFit()
        name.frame.origin=CGPoint(x:icon.frame.origin.x+icon.frame.width+10,y:icon.frame.origin.y)
        toolView.addSubview(name)
        
        //add title in tool area
        var title=UILabel()
        title.text=product.title!
        title.font=UIFont(name: _constant._textFont, size: 14)
        title.sizeToFit()
        title.frame.origin=CGPoint(x:name.frame.origin.x,y:name.frame.origin.y+name.frame.height+15)
        toolView.addSubview(title)
        
        //add downBtn in tool area
        var downBtn=UIButton(frame: CGRectMake(self.frame.width-imageHeight-20, 30, imageHeight, imageHeight))
        downBtn.setImage(UIImage(named: "Down"), forState: UIControlState.Normal)
        downBtn.setImage(UIImage(named: "Down"), forState: UIControlState.Selected)
        downBtn.adjustsImageWhenHighlighted=false
        downBtn.addTarget(self, action: "downApp", forControlEvents: UIControlEvents.TouchUpInside)
        toolView.addSubview(downBtn)
        
        //初始内容高度
        _pos=toolView.frame.origin.y+toolView.frame.height+20
        //begin add content
        
        //NSData to array<NSDictionary>
        var arrayData:Array<NSDictionary> = NSKeyedUnarchiver.unarchiveObjectWithData(_product!.detailUrl!) as! Array<NSDictionary>
        for(var i=0;i<arrayData.count;i++){
            
            print("count is:\(i)")
            var type:Int=arrayData[i]["type"] as! Int
            switch type{//100=title,101=descript,102=imageUrl
                
            case 100:
                
                var str=arrayData[i]["content"] as! String
                var label=UILabel()
                label.text=str
                label.font=UIFont(name: _constant._textFont, size: 16)
                label.sizeToFit()
                label.frame.origin=CGPoint(x:20,y:_pos!)
                contentView.addSubview(label)
                _pos! += label.frame.height+20
                
                
            case 101:
            
                //print("descript")
                var str=arrayData[i]["content"] as! String
                var attributedString=NSMutableAttributedString(string: str)
                var paragraphStyle=NSMutableParagraphStyle()
                //设置行间距
                paragraphStyle.lineSpacing=8
                attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0,NSString(string: str).length))
                //设置字体...
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: _constant._textFont, size: 14)!, range: NSMakeRange(0,NSString(string: str).length))
                //计算文字占据的尺寸大小，其中CGSize为约束限制
                var fontSize=attributedString.boundingRectWithSize(CGSize(width: self.frame.width-40,height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                var descriptLabel=UILabel(frame: CGRectMake(20, _pos!, fontSize.width, fontSize.height))
                descriptLabel.attributedText = attributedString
                descriptLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping;
                descriptLabel.numberOfLines = 0
                //descriptLabel.sizeToFit()//高度无效
                contentView.addSubview(descriptLabel)
                _pos! += descriptLabel.frame.height+20
                
                
            case 102:
                
                var str=arrayData[i]["content"] as! String
                var image1=UIImageView(frame:CGRectMake(20, _pos!, self.frame.width-40, (self.frame.width-40)*1.5))
                image1.image=UIImage(named: "Default")
                image1.contentMode=UIViewContentMode.ScaleToFill
                contentView.addSubview(image1)
                _pos! += image1.frame.height+20
                
                //异步加载图片
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var URL:NSURL = NSURL(string: str)!
                    var data:NSData?=NSData(contentsOfURL: URL)
                    if data != nil {
                        var ZYHImage=UIImage(data: data!)
                        //写缓存
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //刷新主UI
                            image1.image=ZYHImage
                        })
                    }
                })

                
            default:
                break;
            }
            //print("pos is:\(_pos!)")
        }
        //set size of scrollView
        detailScroll.contentSize=CGSize(width: self.frame.width,height: _pos!+60)
        
        //add backBtn
        var backBtn=UIButton(frame: CGRectMake(15, 30, 36, 36))
        backBtn.setImage(UIImage(named: "Back"), forState: UIControlState.Normal)
        backBtn.setImage(UIImage(named: "Back"), forState: UIControlState.Selected)
        backBtn.adjustsImageWhenHighlighted=false
        backBtn.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backBtn)

    }
    
    //protocol func
    func touchView(point:CGPoint){
        pos0=point
    }
    func moveView(point:CGPoint){
        pos1=point
        var dx=pos1!.x-pos0!.x
        //pos0=pos1//获取变化的速度，否则太快
        dx = max(-self.frame.origin.x,dx)//左边界...
        dx = min(self.frame.width*3/4-self.frame.origin.x,dx)//右边界...
        self.frame.origin.x += dx
        
    }
    func endView(point:CGPoint){
        
    }
    
    //listent scroll action
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
    }
    
    func back(){
        
        UIView.animateWithDuration(0.3,
            animations: {
                self.frame.origin.x = self.frame.width
            },
            completion: {
                (finished) in
                self.removeFromSuperview()
            }
        )
    }
    
    func downApp(){
        
        UIApplication.sharedApplication().openURL(NSURL(string: _product!.downUrl!)!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
