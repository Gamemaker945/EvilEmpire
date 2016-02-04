//
//  Utilities.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/4/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class Utilities {

    class func newPathForRoundedRect (rect:CGRect, radius:CGFloat) -> CGMutablePathRef
    {
        let retPath = CGPathCreateMutable();
        
        let innerRect = CGRectInset(rect, radius, radius);
        
        let inside_right = innerRect.origin.x + innerRect.size.width;
        let outside_right = rect.origin.x + rect.size.width;
        let inside_bottom = innerRect.origin.y + innerRect.size.height;
        let outside_bottom = rect.origin.y + rect.size.height;
        
        let inside_top = innerRect.origin.y;
        let outside_top = rect.origin.y;
        let outside_left = rect.origin.x;
        
        CGPathMoveToPoint(retPath, nil, innerRect.origin.x, outside_top);
        
        CGPathAddLineToPoint(retPath, nil, inside_right, outside_top);
        CGPathAddArcToPoint(retPath, nil, outside_right, outside_top, outside_right, inside_top, radius);
        CGPathAddLineToPoint(retPath, nil, outside_right, inside_bottom);
        CGPathAddArcToPoint(retPath, nil,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
        
        CGPathAddLineToPoint(retPath, nil, innerRect.origin.x, outside_bottom);
        CGPathAddArcToPoint(retPath, nil,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
        CGPathAddLineToPoint(retPath, nil, outside_left, inside_top);
        CGPathAddArcToPoint(retPath, nil,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
        
        CGPathCloseSubpath(retPath);
        
        return retPath;
    }

}