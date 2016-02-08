//
//  LetterTile.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

// -----------------------------------------------------------------------------
// MARK: - LetterTileDelegate Protocol

protocol LetterTileDelegate {
    func tileDragEnded (tile: LetterTile)
    func tileDragBegan (tile: LetterTile)
}


// -----------------------------------------------------------------------------
// MARK: - LetterTile Class

class LetterTile: UIView {
    
    // MARK: - Constants
    struct Constants {
        struct AssetNames {
            static let blankTile = "tile-blank"
            static let selectedTile = "tile-blue"
        }
    }
    
    // MARK: - Variables
    private var bgImage: UIImageView!
    private var letterLabel: UILabel!
    
    var letter: String = ""
    
    var delegate: LetterTileDelegate?
    
    var selected: Bool = false {
        didSet {
            if selected {
                bgImage.image = UIImage (named: Constants.AssetNames.selectedTile)
            } else {
                bgImage.image = UIImage (named: Constants.AssetNames.blankTile)
            }
        }
    }
    
    
    // MARK: - Init Functions
    convenience init (frame: CGRect, letter: String) {
        
        self.init (frame: frame)
        
        self.letter = letter
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
        
        
     }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public Drag Functions
    func enableDrag () {
        let pan = UIPanGestureRecognizer(target:self, action:"pan:")
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.gestureRecognizers = [pan]
        
    }
    
    func disableDrag () {
        self.gestureRecognizers = nil
        self.userInteractionEnabled = false

    }

    
    // MARK: - Private Utility Functions
    var lastLocation: CGPoint = CGPointMake(0,0)
    private func pan (recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
        
        switch recognizer.state {
            case .Ended:
                selected = false
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.delegate?.tileDragEnded(self)
            default: break;
        }
    }

    
    // MARK: - Touch Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
        selected = true
        
        // Scale the object to appear "lifted"
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        self.delegate?.tileDragBegan(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        selected = false
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
    



}
