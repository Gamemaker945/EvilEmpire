//
//  LetterHole.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/4/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit
import AVFoundation

enum LetterBounceDirection: Int {
    case Stationary = 0
    case MovingUp
    case MovingDown
}

class LetterHole: UIView {

    private var letterLabel: UILabel!
    private var holeImageView: UIImageView!
    
    private var particleEmitter:CAEmitterLayer!
    
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
        
        var delay = arc4random_uniform(4) * UInt32(NSEC_PER_SEC)
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
    
    func showHole () {
        startSmoke()
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
    
    private func startSmoke () {
        particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        particleEmitter.emitterMode = kCAEmitterLayerAdditive
        particleEmitter.emitterShape = kCAEmitterLayerRectangle
        particleEmitter.emitterSize = CGSizeMake(40, 40)
        
        let cell = makeEmitterCell()
        
        particleEmitter.emitterCells = [cell]
        self.layer.addSublayer(particleEmitter)
    }
    
    func stopSmoke () {
        particleEmitter.removeFromSuperlayer()
        particleEmitter = nil
    }
    
    func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 5
        cell.lifetime = 0.5
        cell.color = UIColor.whiteColor().CGColor
        cell.name = "cell"
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = CGFloat(M_PI*2)
        cell.spin = 0
        cell.alphaRange = 0.1
        cell.spinRange = 3
        cell.scaleRange = 0.03
        cell.scaleSpeed = -0.2
        
        let texture:UIImage? = UIImage(named:"smoke")
        assert(texture != nil, "particle image not found")
        
        cell.contents = texture!.CGImage
        return cell
    }
}
