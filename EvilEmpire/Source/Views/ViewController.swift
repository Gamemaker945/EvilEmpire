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
            static var letters = ["E", "V", "I", "L", "E", "M", "P", "I", "R", "E"]
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
    var activeTile: LetterTile?
   
    // Holes
    var holes: [LetterHole] = []
    
    var glass:UIImageView!
    
    
    
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
        
        uiLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(uiLayer)
        self.masterForegroundLayer.addSubview(tileLayer)
    
        createGlass()
        createTiles()
        
        createHoles ()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    private func createGlass () {
        glass = UIImageView (frame: glassLayer.bounds)
        glass.image = UIImage (named: "Glass")
        glass.alpha = 0.6
        glassLayer.addSubview(glass)
    }
    
    private func createTiles () {
        tiles = []
        
        let randomLetters = newShuffledArray(Constants.Tiles.letters)
        let availableWidth = CGRectGetWidth(tileLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let tileWidth = (availableWidth - Constants.Tiles.spacingGap * CGFloat(Constants.Tiles.count - 1)) / CGFloat(Constants.Tiles.count)
        for index in 0...Constants.Tiles.count-1 {
            let letter = randomLetters[index]
            let tile = LetterTile (frame: CGRectMake(Constants.Tiles.leftPadding + CGFloat(index) * (tileWidth + Constants.Tiles.spacingGap), CGRectGetHeight(tileLayer.frame) - tileWidth - 30, tileWidth, tileWidth), letter: letter as! String)
            tileLayer.addSubview(tile)
            tiles.append(tile)
        }
    }
    
    private func createHoles () {
        
        // Get the tile width/height
        let tileWidth = CGRectGetWidth(tiles[0].frame)
        
        let r = glass.bounds;

        let lay = CAShapeLayer ();
        let path = CGPathCreateMutable();
        
        let spacing = Constants.Tiles.spacingGap * 10

        // Create 4 holes near top, and 6 holes below that
        let availableWidth = CGRectGetWidth(tileLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let widthOf4TilesAndSpaces = tileWidth * 4 + spacing * 3
        var leftStart = (availableWidth - widthOf4TilesAndSpaces) / 2.0
        
        for i in 0...3 {
            let rect = CGRectMake(leftStart + (CGFloat(i) * (tileWidth+spacing)),40,tileWidth,tileWidth)
            let hole = LetterHole (frame: rect, letter: Constants.Tiles.letters[i])
            tileLayer.addSubview(hole)
            holes.append(hole)
            CGPathAddPath(path, nil, Utilities.newPathForRoundedRect(rect, radius:6))
        }
        
        let widthOf6TilesAndSpaces = tileWidth * 6 + spacing * 5
        leftStart = (availableWidth - widthOf6TilesAndSpaces) / 2.0
        
        for i in 0...5 {
            let rect = CGRectMake(leftStart + (CGFloat(i) * (tileWidth+spacing)),40+tileWidth+10,tileWidth,tileWidth)
            let hole = LetterHole (frame: rect, letter: Constants.Tiles.letters[i+4])
            tileLayer.addSubview(hole)
            holes.append(hole)
            CGPathAddPath(path, nil, Utilities.newPathForRoundedRect(rect, radius:6))
        }
        CGPathAddRect(path, nil, r);
        
        
        lay.path = path;
//        CGPathRelease(path);
        lay.fillRule = kCAFillRuleEvenOdd;
        glass.layer.mask = lay;
    }
    
    
    func newShuffledArray(array:NSArray) -> NSArray {
        let mutableArray = array.mutableCopy() as! NSMutableArray
        let count = mutableArray.count
        if count>1 {
            for var i=count-1;i>0;--i{
                mutableArray.exchangeObjectAtIndex(i, withObjectAtIndex: Int(arc4random_uniform(UInt32(i+1))))
            }
        }
        return mutableArray as NSArray
    }

}


