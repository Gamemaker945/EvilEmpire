//
//  LetterHole.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/4/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit
import AVFoundation

// -----------------------------------------------------------------------------
// MARK: - LetterBounceDirection Enum

enum LetterBounceDirection: Int {
    case Stationary = 0
    case MovingUp
    case MovingDown
}

// -----------------------------------------------------------------------------
// MARK: - LetterHole Class

class LetterHole: UIView {
    
    // MARK: - Constants
    struct Constants {
        struct AssetNames {
            static let holeImg = "hole-1"
            static let particleImg = "particle"
        }
        
        struct DropValues {
            static let dropWiggleRoom = CGSize (width: 15, height: 15)
        }
        
        struct BounceValues {
            static let bounceHeight = 20
        }
    }

    // MARK: - Variables
    private var letterLabel: UILabel!
    private var holeImageView: UIImageView!
    
    private var particleEmitter:CAEmitterLayer?
    
    private var bounceDirection:LetterBounceDirection = .Stationary
    var letter: String = ""
    

    
    
    // MARK: - Init Functions
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
      
        let holeImg = UIImage (named: Constants.AssetNames.holeImg)
        holeImageView = UIImageView (image: holeImg)
        holeImageView.frame = self.bounds
        holeImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.45, 1.45);
        self.addSubview(holeImageView)
        
        let delay = arc4random_uniform(4) * UInt32(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.beginLetterBounce()
            
        })
        let ddelay = Double(arc4random_uniform(100)) * Double(NSEC_PER_SEC) / 100
        time = dispatch_time(DISPATCH_TIME_NOW, Int64(ddelay))
        dispatch_after(time, dispatch_get_main_queue(), {
            //self.startSmoke()
            
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions

    // Check to see if the tile fit within the hole allowing for a bit of inaccuracy
    func didPlugHole (tile: LetterTile) -> Bool {
        let diffX = abs (tile.center.x - self.center.x)
        let diffY = abs (tile.center.y - self.center.y)
        
        return (diffX < Constants.DropValues.dropWiggleRoom.width &&
            diffY < Constants.DropValues.dropWiggleRoom.height)
    }
    
    // Start the letter "floating" within the hole
    func beginLetterBounce () {
        var deltaY = 0
        if bounceDirection == .Stationary {
            deltaY = Constants.BounceValues.bounceHeight / 2 * -1
            bounceDirection = .MovingUp
        } else if bounceDirection == .MovingUp {
            deltaY = Constants.BounceValues.bounceHeight
            bounceDirection = .MovingDown
        } else {
            deltaY = Constants.BounceValues.bounceHeight * -1
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
    
    func createPop () {
        
        particleEmitter = CAEmitterLayer()
        particleEmitter!.emitterPosition = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        particleEmitter!.emitterSize = self.bounds.size
        particleEmitter!.emitterMode = kCAEmitterLayerAdditive
        particleEmitter!.emitterShape = kCAEmitterLayerRectangle
        
        let cell = makeEmitterCell()
        
        particleEmitter?.emitterCells = [cell]
        self.layer.addSublayer(particleEmitter!)
        
        //disable pop, we want a short pop
        var delay = Int64(0.01 * Double(NSEC_PER_SEC))
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, delay)
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.particleEmitter?.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
        }
        
        //remove pop
        delay = Int64(2 * Double(NSEC_PER_SEC))
        delayTime = dispatch_time(DISPATCH_TIME_NOW, delay)
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.particleEmitter?.removeFromSuperlayer()
        }
    }
    
    private func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.lifetime = 0.75
        cell.blueRange = 0.33
        cell.blueSpeed = -0.33
        cell.velocity = 160
        cell.velocityRange = 40
        cell.emissionRange = CGFloat(M_PI*2)
        cell.scaleRange = 0
        cell.scaleSpeed = -0.2
        cell.yAcceleration = 250
      
        
        let texture:UIImage? = UIImage(named:Constants.AssetNames.particleImg)
        
        cell.contents = texture!.CGImage
        return cell
    }
}
