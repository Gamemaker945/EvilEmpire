//
//  ScrollingAlert.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/5/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class ScrollingAlert: UIView {

    var bg:UIImageView!
    var msgLabel:UILabel!
    
    convenience init (frame: CGRect, msg: String) {
        
        self.init (frame: frame)
        
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Background
        bg = UIImageView (frame: self.bounds)
        bg.image = UIImage (named: "ScrollingAlert")
        self.addSubview(bg)
        
        msgLabel = UILabel()
        msgLabel.font = UIFont (name: "TripleDotDigital-7", size: 14)
        msgLabel.textColor = UIColor.redColor()
        msgLabel.textAlignment = .Left
        self.addSubview(msgLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAlertMessage (message: String) {
        msgLabel.text = message
        msgLabel.sizeToFit()
        
        var f = self.msgLabel.frame
        f.origin.y = 0
        f.size.height = self.frame.size.height + 10
        self.msgLabel.frame = f
        
        beginScroll()
    }
    
    func beginScroll () {
        var f = self.msgLabel.frame
        f.origin.x = self.frame.size.width
        self.msgLabel.frame = f
        UIView.animateWithDuration(20, animations: { () -> Void in
            f.origin.x = f.size.width * -1
            self.msgLabel.frame = f
            }) { (done) -> Void in
                self.beginScroll()
        }
    }
}
