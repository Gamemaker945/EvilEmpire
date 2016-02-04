//
//  LetterTile.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class LetterTile: UIView {
    
    struct Constants {
        struct AssetNames {
            static let blankTile = "tile-blank"
            static let selectedTile = "tile-blue"
        }
    }
    
    var bgImage: UIImageView!
    var letterLabel: UILabel!
    
    var selected: Bool = false {
        didSet {
            if selected {
                bgImage.image = UIImage (named: Constants.AssetNames.selectedTile)
            } else {
                bgImage.image = UIImage (named: Constants.AssetNames.blankTile)
            }
        }
    }
    
    
    convenience init (frame: CGRect, letter: String) {
        
        self.init (frame: frame)
        
        letterLabel.text = letter
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Create the background
        bgImage = UIImageView (frame: self.bounds)
        bgImage.image = UIImage (named: Constants.AssetNames.blankTile)
        self.addSubview(bgImage)
        
        letterLabel = UILabel (frame: self.bounds)
        letterLabel.font = UIFont.systemFontOfSize(30)
        letterLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(letterLabel)
        
        
        let pan = UIPanGestureRecognizer(target:self, action:"pan:")
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.gestureRecognizers = [pan]
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var lastLocation: CGPoint = CGPointMake(0,0)
    func pan (recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
        
        switch recognizer.state {
        case .Ended:
            selected = false
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        default: break;
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
        selected = true
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        selected = false
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
    



}
