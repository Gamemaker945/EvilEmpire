//
//  ScrollingAlert.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/5/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

// -----------------------------------------------------------------------------
// MARK: - ScrollingAlert Class

class ScrollingAlert: UIView {

    // MARK: - Constants
    struct Constants {
        struct AssetNames {
            static let bgImg = "ScrollingAlert"
            static let alertFont = "TripleDotDigital-7"
        }

    }
    
    // MARK: - Variables

    var bg:UIImageView!
    var msgLabel:UILabel!
    

    
    
    
    // MARK: - Init Functions
    
    convenience init (frame: CGRect, msg: String) {
        
        self.init (frame: frame)
        
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Background
        bg = UIImageView (frame: self.bounds)
        bg.image = UIImage (named: Constants.AssetNames.bgImg)
        self.addSubview(bg)
        
        msgLabel = UILabel()
        msgLabel.font = UIFont (name: Constants.AssetNames.alertFont, size: 14)
        msgLabel.textAlignment = .Left

        self.addSubview(msgLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions

    /**
    Set the message to be displayed along with its color
    - parameter message: The message to be displayed.
    - parameter color: The color the message will use when visible
    */
    func setAlertMessage (message: String, usingColor color:UIColor) {
        msgLabel.text = message
        msgLabel.sizeToFit()
        msgLabel.textColor = color
        
        var f = self.msgLabel.frame
        f.origin.y = 0
        f.size.height = self.frame.size.height + 10
        self.msgLabel.frame = f
    }
    
    /**
     Start scrolling the alert sign
     */
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
