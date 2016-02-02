//
//  ViewController.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct Constants {
        struct MasterLayerPadding {
            static let width:CGFloat = 15.0
            static let height:CGFloat = 15.0
        }
    }
    
    
    var spaceEffectsLayer: UIView!
    var masterForegroundLayer: UIView!
    var glassLayer: UIView!
    var tileLayer: UIView!
    var uiLayer: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the game layers
        spaceEffectsLayer = UIView (frame: self.view.bounds)
        self.view .addSubview(spaceEffectsLayer)
        
        // Extend the interace several pixels beyond the edges of the screen. This will allow
        // for the "explosion shaking" effect (I hope)
        let masterFGFrame = CGRectMake(Constants.MasterLayerPadding.width * -1.0, Constants.MasterLayerPadding.height * -1.0, CGRectGetWidth(self.view.frame) + Constants.MasterLayerPadding.width * 2.0, CGRectGetHeight(self.view.frame) + Constants.MasterLayerPadding.height * 2.0)
        masterForegroundLayer = UIView (frame: masterFGFrame)
        self.view .addSubview(masterForegroundLayer)
        
        let glassLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(glassLayer)
        
        let tileLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(tileLayer)
        
        let uiLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(uiLayer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

