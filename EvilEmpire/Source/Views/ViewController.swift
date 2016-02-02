//
//  ViewController.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Constants
    struct Constants {
        struct MasterLayerPadding {
            static let width:CGFloat = 15.0
            static let height:CGFloat = 15.0
        }
        
        struct Tiles {
            static let count = 10
            static let letters = ["E", "V", "I", "L", "E", "M", "P", "I", "R", "E"]
            static let spacingGap:CGFloat = 5
            static let leftPadding:CGFloat = 25
            static let rightPadding:CGFloat = 25
        }
    }
    
    
    // MARK: - Variables
    // Layer vars
    var spaceEffectsLayer: UIView!
    var masterForegroundLayer: UIView!
    var glassLayer: UIView!
    var tileLayer: UIView!
    var uiLayer: UIView!
    
    // Tiles
    var tiles: [LetterTile] = []
    
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the game layers
        spaceEffectsLayer = UIView (frame: self.view.bounds)
        self.view.addSubview(spaceEffectsLayer)
        
        let spaceBG = UIImageView (frame: spaceEffectsLayer.bounds)
        spaceBG.image = UIImage (named: "StarField")
        self.spaceEffectsLayer.addSubview(spaceBG)
        
        // Extend the interace several pixels beyond the edges of the screen. This will allow
        // for the "explosion shaking" effect (I hope)
        let masterFGFrame = CGRectMake(Constants.MasterLayerPadding.width * -1.0, Constants.MasterLayerPadding.height * -1.0, CGRectGetWidth(self.view.frame) + Constants.MasterLayerPadding.width * 2.0, CGRectGetHeight(self.view.frame) + Constants.MasterLayerPadding.height * 2.0)
        masterForegroundLayer = UIView (frame: masterFGFrame)
        self.view .addSubview(masterForegroundLayer)
        
        glassLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(glassLayer)
        
        tileLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(tileLayer)
        
        uiLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(uiLayer)
    
        createTiles()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    private func createTiles () {
        tiles = []
        
        let availableWidth = CGRectGetWidth(spaceEffectsLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let tileWidth = (availableWidth - Constants.Tiles.spacingGap * CGFloat(Constants.Tiles.count - 1)) / CGFloat(Constants.Tiles.count)
        for index in 0...Constants.Tiles.count-1 {
            let letter = Constants.Tiles.letters[index]
            let tile = LetterTile (frame: CGRectMake(Constants.Tiles.leftPadding + CGFloat(index) * (tileWidth + Constants.Tiles.spacingGap), 50, tileWidth, tileWidth), letter: letter)
            tileLayer.addSubview(tile)
        }
    }

}

