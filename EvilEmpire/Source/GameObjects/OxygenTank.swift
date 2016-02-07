//
//  OxygenTank.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/5/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

protocol OxygenTankDelegate {
    func tankDepleted ()
}


class OxygenTank: UIView {

    private var tank: UIImageView!
    private var level: UIView!
    
    private var duration:Int = 0
    
    var delegate: OxygenTankDelegate?

    convenience init (frame: CGRect, levelDuration: Int) {
        
        self.init (frame: frame)
        duration = levelDuration
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        level = UIView (frame: CGRectMake (10, 20, self.frame.size.width/3, self.frame.size.height - 30))
        level.backgroundColor = UIColor.blueColor()
        self.addSubview(level)

        tank = UIImageView (frame: self.bounds)
        tank.image = UIImage (named: "O2tank")
        self.addSubview(tank)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginCountdown () {
        
        UIView.animateWithDuration(Double(duration), animations: { () -> Void in
            var f = self.level.frame
            let y = CGRectGetMaxY(f)
            f.size.height = 0.1
            f.origin.y = y
            self.level.frame = f
            }) { (done) -> Void in
                self.delegate?.tankDepleted()
        }
    }
    
    func haltCountdown () {
        self.layer.removeAllAnimations()
    }

}
