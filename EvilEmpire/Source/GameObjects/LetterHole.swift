//
//  LetterHole.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/4/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

enum LetterBounceDirection: Int {
    case Stationary = 0
    case MovingUp
    case MovingDown
}

class LetterHole: UIView {

    private var letterLabel: UILabel!
    private var holeImageView: UIImageView!
    
    private var bounceDirection:LetterBounceDirection = .Stationary
    var letter: String = ""
    
    
    convenience init (frame: CGRect, letter: String) {
        
        self.init (frame: frame)
        
        self.letter = letter
        letterLabel.text = letter
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Create the background
        letterLabel = UILabel (frame: self.bounds)
        letterLabel.font = UIFont.systemFontOfSize(30)
        letterLabel.textAlignment = NSTextAlignment.Center
        letterLabel.textColor = UIColor.redColor()
        letterLabel.alpha = 0.5
        self.addSubview(letterLabel)
      
        let holeImg = UIImage (named: "hole-1")
        holeImageView = UIImageView (image: holeImg)
        holeImageView.frame = self.bounds
        holeImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.45, 1.45);
        self.addSubview(holeImageView)
        
        let delay = arc4random_uniform(4) * UInt32(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.beginLetterBounce()
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didPlugHole (tile: LetterTile) -> Bool {
        let diffX = abs (tile.center.x - self.center.x)
        let diffY = abs (tile.center.y - self.center.y)
        
        return (diffX < 15 && diffY < 15)
    }
    
    func beginLetterBounce () {
        var deltaY = 0
        if bounceDirection == .Stationary {
            deltaY = -10
            bounceDirection = .MovingUp
        } else if bounceDirection == .MovingUp {
            deltaY = 20
            bounceDirection = .MovingDown
        } else {
            deltaY = -20
            bounceDirection = .MovingUp
        }
        
        UIView.animateWithDuration(2, animations: { () -> Void in
            
            var f = self.letterLabel.frame
            f.origin.y += CGFloat(deltaY)
            self.letterLabel.frame = f
            
            }) { (done) -> Void in
                self.beginLetterBounce ()
        }
    }
}
