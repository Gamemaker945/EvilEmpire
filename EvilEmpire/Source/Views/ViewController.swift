//
//  ViewController.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit
import AVFoundation


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
    var shipLayer: UIView!
    var tileLayer: UIView!
    var uiLayer: UIView!
    
    // Tiles
    var tiles: [LetterTile] = []
    var activeTile: LetterTile?
    var startLoc: CGPoint?
    var platforms: [UIImageView] = []

   
    // Holes
    var holes: [LetterHole] = []
    
    var glass:UIImageView!
    
    var masterFGFrame:CGRect!
    
    var explosionAudio:AVAudioPlayer!
    var glassAudio:AVAudioPlayer!
    var alarmAudio:AVAudioPlayer!
    var windAudio:AVAudioPlayer!
    
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
        masterFGFrame = CGRectMake(Constants.MasterLayerPadding.width * -1.0, Constants.MasterLayerPadding.height * -1.0, CGRectGetWidth(self.view.frame) + Constants.MasterLayerPadding.width * 2.0, CGRectGetHeight(self.view.frame) + Constants.MasterLayerPadding.height * 2.0)
        masterForegroundLayer = UIView (frame: masterFGFrame)
        self.view .addSubview(masterForegroundLayer)
        
        glassLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(glassLayer)

        shipLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(shipLayer)

        tileLayer = UIView (frame: masterForegroundLayer.bounds)
        
        uiLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(uiLayer)
        self.masterForegroundLayer.addSubview(tileLayer)
    
        loadSounds()
        createGlass()
        createShip()
        createTiles()
        
        createOxygenTank ()
        
        
        
        
        //activeTiles()
        
        let time = dispatch_time(DISPATCH_TIME_NOW, 4)
        dispatch_after(time, dispatch_get_main_queue(), {
            self.explosionAudio.play()
            self.shakeScreen()
        })
        
        
    }
    
    func loadSounds () {
        
        let explosionSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Explosion", ofType: "mp3")!)
        let glassSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("glassBreak", ofType: "mp3")!)
        let alarmSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("RedAlert", ofType: "mp3")!)
        let windSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Wind", ofType: "mp3")!)
        
        explosionAudio = AVAudioPlayer()
        glassAudio = AVAudioPlayer()
        alarmAudio = AVAudioPlayer()
        windAudio = AVAudioPlayer()
        
        
        do {
            
            glassAudio = try AVAudioPlayer(contentsOfURL: glassSound, fileTypeHint: nil)
            glassAudio.prepareToPlay()
            
            explosionAudio = try AVAudioPlayer(contentsOfURL: explosionSound, fileTypeHint: nil)
            explosionAudio.prepareToPlay()

            windAudio = try AVAudioPlayer(contentsOfURL: windSound, fileTypeHint: nil)
            windAudio.numberOfLoops = -1
            windAudio.prepareToPlay()

            alarmAudio = try AVAudioPlayer(contentsOfURL: alarmSound, fileTypeHint: nil)
            alarmAudio.numberOfLoops = 2
            alarmAudio.prepareToPlay()
            
            
        } catch _ {
            
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    private func createOxygenTank () {
        let tank = OxygenTank (frame: CGRectMake(CGRectGetWidth(self.shipLayer.frame) - 100, CGRectGetMidY(self.shipLayer.frame) - 115, 50, 200), levelDuration:60)
        tank.delegate = self
        shipLayer.addSubview(tank)
        
        tank.beginCountdown()
    }
    
    private func createGlass () {
        glass = UIImageView (frame: glassLayer.bounds)
        glass.image = UIImage (named: "Glass")
        glass.alpha = 0.6
        glassLayer.addSubview(glass)
    }
    
    private func createShip () {
        let ship = UIImageView (frame: shipLayer.bounds)
        ship.image = UIImage (named: "Ship")
        shipLayer.addSubview(ship)
    }
    
    private func createTiles () {
        tiles = []
        
        let randomLetters = newShuffledArray(Constants.Tiles.letters)
        let availableWidth = CGRectGetWidth(tileLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let tileWidth = (availableWidth - Constants.Tiles.spacingGap * CGFloat(Constants.Tiles.count - 1)) / CGFloat(Constants.Tiles.count)
        for index in 0...Constants.Tiles.count-1 {
            let letter = randomLetters[index]
            let tile = LetterTile (frame: CGRectMake(Constants.Tiles.leftPadding + CGFloat(index) * (tileWidth + Constants.Tiles.spacingGap), CGRectGetHeight(tileLayer.frame), tileWidth, tileWidth), letter: letter as! String)
            tile.delegate = self
            tileLayer.addSubview(tile)
            tiles.append(tile)
            
            let platform = UIImageView (frame: CGRectMake(tile.frame.origin.x, CGRectGetMaxY(tile.frame), tileWidth, tileWidth / 3))
            platform.image = UIImage (named: "tile-platform")
            tileLayer.addSubview(platform)
            platforms.append (platform)
        }
    }
    
    private func createScrollingAlert () {
        let alert = ScrollingAlert (frame: CGRectMake(0, CGRectGetMaxY(uiLayer.frame), CGRectGetWidth(uiLayer.frame), 40))
        alert.setAlertMessage("ALERT!!! .... Hull Breach .... Plug holes to avoid oxygen loss .... ALERT!!!!")
        tileLayer.addSubview(alert)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var f = alert.frame
            f.origin.y -= 55
            alert.frame = f
            }) { (done) -> Void in
                
        }
    }
    
    private func createHoles () {
        
        // Get the tile width/height
        let tileWidth = CGRectGetWidth(tiles[0].frame)
        
        let r = glass.bounds;

        let lay = CAShapeLayer ();
        let path = CGPathCreateMutable();
        
        let spacing = Constants.Tiles.spacingGap * 4

        // Create 4 holes near top, and 6 holes below that
        let availableWidth = CGRectGetWidth(tileLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let widthOf4TilesAndSpaces = tileWidth * 4 + spacing * 3
        var leftStart = (availableWidth - widthOf4TilesAndSpaces) / 2.0 + 25
        
        for i in 0...3 {
            let rect = CGRectMake(leftStart + (CGFloat(i) * (tileWidth+spacing)),100,tileWidth,tileWidth)
            let hole = LetterHole (frame: rect, letter: Constants.Tiles.letters[i])
            tileLayer.addSubview(hole)
            holes.append(hole)
            CGPathAddPath(path, nil, Utilities.newPathForRoundedRect(rect, radius:6))
        }
        
        let widthOf6TilesAndSpaces = tileWidth * 6 + spacing * 5
        leftStart = (availableWidth - widthOf6TilesAndSpaces) / 2.0 + 25
        
        for i in 0...5 {
            let rect = CGRectMake(leftStart + (CGFloat(i) * (tileWidth+spacing)),100+tileWidth+10,tileWidth,tileWidth)
            let hole = LetterHole (frame: rect, letter: Constants.Tiles.letters[i+4])
            tileLayer.addSubview(hole)
            holes.append(hole)
            CGPathAddPath(path, nil, Utilities.newPathForRoundedRect(rect, radius:6))
        }
        CGPathAddRect(path, nil, r);
        
        
        lay.path = path;
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
    
    func activateTiles () {
        for index in 0 ... tiles.count - 1 {
            let tile = tiles[index]
            let platform = platforms[index]
            UIView.animateWithDuration(0.2 + (0.1 * Double(index)), animations: { () -> Void in
                var tileF = tile.frame
                tileF.origin.y = tileF.origin.y - tileF.size.height - CGFloat(70)
                tile.frame = tileF
                
                var platF = platform.frame
                platF.origin.y = platF.origin.y - tileF.size.height - CGFloat(70)
                platform.frame = platF
                }, completion: { (done) -> Void in
                    tile.enableDrag()
            })
        }
    }
    
    var timesShaken = 0
    func shakeScreen () {
        var mainF = masterForegroundLayer.frame
        if timesShaken > 20 {
            self.masterForegroundLayer.frame = self.masterFGFrame
            createHoles ()
            glassAudio.play()
            alarmAudio.play()
            windAudio.play()
            createScrollingAlert()
            activateTiles ()
            return
        }
        
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            
            let mod = self.timesShaken % 5
            switch mod {
            case 0: mainF.origin.x += 5
            case 1: mainF.origin.y += 5
            case 2: mainF.origin.x -= 10
            case 3: mainF.origin.y -= 10
            case 4: mainF = self.masterFGFrame
            default: break
            }
            self.masterForegroundLayer.frame = mainF
            }) { (done) -> Void in
                self.timesShaken += 1
                self.shakeScreen()
        }
    }

}

extension ViewController : LetterTileDelegate {

    
    func tileDragEnded (tile: LetterTile) {
        var found = false
        for hole in self.holes {
            if hole.didPlugHole(tile) {
                
                if hole.letter == tile.letter {
                    tile.center = hole.center
                    tile.disableDrag()
                    hole.stopSmoke()
                    self.activeTile = nil
                    self.startLoc = nil
                    found = true
                    break
                } else {
                    returnActiveTile()
                }
            }
        }
        
        if found == false {
            returnActiveTile()
        }
    }
    
    func tileDragBegan (tile: LetterTile) {
        activeTile = tile
        startLoc = tile.center
    }
    
    private func returnActiveTile () {
        if let tile = self.activeTile {
            if let pos = self.startLoc {
                tile.center = pos
                activeTile = nil
                startLoc = nil
            }
        }
    }
}

extension ViewController : OxygenTankDelegate {
    
    func tankDepleted () {
        
    }
}
