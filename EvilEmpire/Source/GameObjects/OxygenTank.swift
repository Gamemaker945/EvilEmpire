//
//  OxygenTank.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/5/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit
import QuartzCore

// -----------------------------------------------------------------------------
// MARK: - OxygenTankDelegate Protocol

protocol OxygenTankDelegate {
    func tankDepleted ()
}

// -----------------------------------------------------------------------------
// MARK: - OxygenTank Class

class OxygenTank: UIView {

    // MARK: - Constants
    struct Constants {
        struct AssetNames {
            static let tankImg = "O2tank"
        }
        
        struct Colors {
            static let okColor = UIColor.blueColor()
            static let alarmColor = UIColor.redColor()
        }
        
        
    }
    
    // MARK: - Variables

    private var tank: UIImageView!
    private var level: UIView!
    
    private var duration:Int = 0
    private var isRed = false
    
    private var colorTimer:NSTimer?
    private var flashTimer:NSTimer?
    
    var delegate: OxygenTankDelegate?

    convenience init (frame: CGRect, levelDuration: Int) {
        
        self.init (frame: frame)
        duration = levelDuration
        
        self.flashTimer = NSTimer.scheduledTimerWithTimeInterval(Double(duration) * 0.66, target: self, selector: Selector("startSwitchColor:"), userInfo: nil, repeats: false)
        
    }
    
    // MARK: - Init Functions

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        level = UIView (frame: CGRectMake (10, 20, self.frame.size.width/3, self.frame.size.height - 30))
        level.backgroundColor = UIColor.blueColor()
        self.addSubview(level)

        tank = UIImageView (frame: self.bounds)
        tank.image = UIImage (named: Constants.AssetNames.tankImg)
        self.addSubview(tank)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        haltCountdown ()
    }
    
    // MARK: - Public Functions

    func beginCountdown () {
        
        UIView.animateWithDuration(Double(duration), animations: { () -> Void in
            var f = self.level.frame
            let y = CGRectGetMaxY(f)
            f.size.height = 0.1
            f.origin.y = y
            self.level.frame = f
            }) { (done) -> Void in
                if done {
                    self.delegate?.tankDepleted()
                }
                self.haltCountdown ()
        }
    }
    
    func haltCountdown () {
        flashTimer?.invalidate()
        flashTimer = nil
        colorTimer?.invalidate()
        colorTimer = nil
        self.layer.removeAllAnimations()
    }
    
    func reset () {
        haltCountdown ()
        level.removeFromSuperview()
        level = UIView (frame: CGRectMake (10, 20, self.frame.size.width/3, self.frame.size.height - 30))
        level.backgroundColor = UIColor.blueColor()
        self.insertSubview(level, atIndex: 0)
    }
    

    // MARK: - Private Functions
    func startSwitchColor(timer : NSTimer) {
        self.colorTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("switchColor:"), userInfo: nil, repeats: true)
    }

    func switchColor(timer : NSTimer) {
        
        self.isRed = !self.isRed
        if isRed {
            self.level.backgroundColor = Constants.Colors.okColor
        } else {
            self.level.backgroundColor = Constants.Colors.alarmColor
        }
    }

}
