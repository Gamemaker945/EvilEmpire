//
//  LetterHole.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/4/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class LetterHole: UIView {

    var letterLabel: UILabel!

    convenience init (frame: CGRect, letter: String) {
        
        self.init (frame: frame)
        
        letterLabel.text = letter
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // Create the background
        letterLabel = UILabel (frame: self.bounds)
        letterLabel.font = UIFont.systemFontOfSize(30)
        letterLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(letterLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
