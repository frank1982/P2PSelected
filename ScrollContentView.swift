
import UIKit

class ScrollContentView: UIView {
    
    var delegate:ScrollViewDelegate?
    
    override init(frame:CGRect){
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var pos=(touches as NSSet).anyObject()?.locationInView(self)
        delegate?.touchView(pos!)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var pos=(touches as NSSet).anyObject()?.locationInView(self)
        delegate?.moveView(pos!)

    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var pos=(touches as NSSet).anyObject()?.locationInView(self)
        delegate?.endView(pos!)
    }
}

protocol ScrollViewDelegate{
    
    func touchView(point:CGPoint)
    func moveView(point:CGPoint)
    func endView(point:CGPoint)
}
