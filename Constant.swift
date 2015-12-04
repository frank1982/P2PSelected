
import UIKit

struct Constant {
    
    let _orangeColor=UIColor(red: CGFloat(255) / 255.0, green: CGFloat(185) / 255.0, blue: CGFloat(15) / 255.0, alpha: CGFloat(1))
    let _colorArray=[
        //orange
        UIColor(red: CGFloat(255) / 255.0, green: CGFloat(185) / 255.0, blue: CGFloat(15) / 255.0, alpha: CGFloat(1)),
        UIColor(red: CGFloat(35) / 255.0, green: CGFloat(213) / 255.0, blue: CGFloat(148) / 255.0, alpha: CGFloat(1)),
        UIColor(red: CGFloat(130) / 255.0, green: CGFloat(30) / 255.0, blue: CGFloat(215) / 255.0, alpha: CGFloat(1)),
        UIColor(red: CGFloat(29) / 255.0, green: CGFloat(126) / 255.0, blue: CGFloat(200) / 255.0, alpha: CGFloat(1))
    ]
    let _textFont="Copperplate-Light"
    
    func getRandomColor()->UIColor{
        var i:UInt32
        i=UInt32(_colorArray.count)
        return _colorArray[Int(arc4random_uniform(i))]
    }
    
    let LOADNUM=10//一次显示或加载的最大数据数量
    let ICONNUMBERSHOWINSCREEN=8//icon一屏显示最大数量
    let LOCALSAVENUM=10//本地允许存储的最大数据数量
}