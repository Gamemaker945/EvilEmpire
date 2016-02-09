//
//  ViewController.swift
//  EvilEmpire
//
//  Created by Christian Henne on 2/2/16.
//  Copyright © 2016 Christian Henne. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

// -----------------------------------------------------------------------------
// MARK: - ViewController Class

class ViewController: UIViewController {

    // MARK: - Constants
    struct Constants {
        
        struct Assets {
            static let tryAgainButton = "tryAgainButton"
        }
        
        struct Level {
            static let timeToComplete = 60
        }
        
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
        
        struct UIImageNames {
            static let starfieldImg = "StarField"
            static let glassImg = "Glass"
            static let shipImg = "Ship"
            static let tilePlatformImg = "tile-platform"
        }
        
        struct ScrollingMsgs {
            static let alertMsg = "ALERT!!! .... Hull Breach .... Plug holes to avoid oxygen loss .... ALERT!!!!"
            static let successMsg = "Well Done!!! You saved thousands of lives today!!"
            static let levelFailedMsg = "Level Failed"
        }
        
        struct ShakeValues {
            static let shakeCount = 20
            static let shakeDist = 10
        }
        
        struct Misc {
            static let strobeAlpha = 0.5
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
    var holesPlugged = 0
    
    // Alert Scroller
    var alert:ScrollingAlert!
    
    // Alarm Strobe
    var strobeView:UIView!
    var strobeTimer: NSTimer?
    
    // Glass Image
    var glass:UIImageView!
    
    // Oxygen Tank
    var tank: OxygenTank?
    
    // Master Foreground Frame (used for initial shake)
    var masterFGFrame:CGRect!
    
    // Audio Controller
    var audioController: AudioController?
    
    
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the game layers
        spaceEffectsLayer = UIView (frame: self.view.bounds)
        self.view.addSubview(spaceEffectsLayer)
        createStarfield ()
        
        // Extend the interace several pixels beyond the edges of the screen. This will allow
        // for the "explosion shaking" effect (I hope)
        masterFGFrame = CGRectMake(Constants.MasterLayerPadding.width * -1.0,
            Constants.MasterLayerPadding.height * -1.0,
            CGRectGetWidth(self.view.frame) + Constants.MasterLayerPadding.width * 2.0,
            CGRectGetHeight(self.view.frame) + Constants.MasterLayerPadding.height * 2.0)
        
        // Create the master layer
        masterForegroundLayer = UIView (frame: masterFGFrame)
        self.view .addSubview(masterForegroundLayer)
        
        // Create the glass layer
        glassLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(glassLayer)
        createGlass()

        // Create the hull layer
        shipLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(shipLayer)
        createShip()
        createOxygenTank ()

        // Create the tile layer
        tileLayer = UIView (frame: masterForegroundLayer.bounds)
        createTiles()
        
        // Create the UI Layer
        uiLayer = UIView (frame: masterForegroundLayer.bounds)
        self.masterForegroundLayer.addSubview(uiLayer)
        self.masterForegroundLayer.addSubview(tileLayer)
    
        // Setup audio
        audioController = AudioController()
        
        // Shake the screen for the initial explosion
        let time = dispatch_time(DISPATCH_TIME_NOW, 4)
        dispatch_after(time, dispatch_get_main_queue(), {
            self.audioController?.playSound(.Explosion)
            self.shakeScreen()
        })
        
        createStrobe()
        
        
    }
    

    // MARK: - Creation Methods

    private func createOxygenTank () {
        tank = OxygenTank (frame: CGRectMake(CGRectGetWidth(self.shipLayer.frame) - 100,
            CGRectGetMidY(self.shipLayer.frame) - 115, 50, 200), levelDuration:Constants.Level.timeToComplete)
        tank?.delegate = self
        shipLayer.addSubview(tank!)
        
    }
    
    private func createStarfield () {
        let spaceBG = UIImageView (frame: spaceEffectsLayer.bounds)
        spaceBG.image = UIImage (named: Constants.UIImageNames.starfieldImg)
        self.spaceEffectsLayer.addSubview(spaceBG)
    }
    
    private func createGlass () {
        glass = UIImageView (frame: glassLayer.bounds)
        glass.image = UIImage (named: Constants.UIImageNames.glassImg)
        glass.alpha = 0.6
        glassLayer.addSubview(glass)
    }
    
    private func createShip () {
        let ship = UIImageView (frame: shipLayer.bounds)
        ship.image = UIImage (named: Constants.UIImageNames.shipImg)
        shipLayer.addSubview(ship)
    }
    
    private func createTiles () {
        tiles = []
        platforms = []
        
        // Shuffle the array of letters
        let randomLetters = newShuffledArray(Constants.Tiles.letters)
        
        // Size the letters to fit the screen
        let availableWidth = CGRectGetWidth(tileLayer.frame) - Constants.Tiles.leftPadding - Constants.Tiles.rightPadding
        let tileWidth = (availableWidth - Constants.Tiles.spacingGap * CGFloat(Constants.Tiles.count - 1)) / CGFloat(Constants.Tiles.count)
        
        // Line the tiles up along the bottom ready for display
        for index in 0...Constants.Tiles.count-1 {
            // Create the tile
            let letter = randomLetters[index]
            let tile = LetterTile (frame: CGRectMake(Constants.Tiles.leftPadding + CGFloat(index) * (tileWidth + Constants.Tiles.spacingGap), CGRectGetHeight(tileLayer.frame), tileWidth, tileWidth), letter: letter as! String)
            tile.delegate = self
            tileLayer.addSubview(tile)
            tiles.append(tile)
            
            // Create the platform under the tile
            let platform = UIImageView (frame: CGRectMake(tile.frame.origin.x, CGRectGetMaxY(tile.frame), tileWidth, tileWidth / 3))
            platform.image = UIImage (named: Constants.UIImageNames.tilePlatformImg)
            tileLayer.addSubview(platform)
            platforms.append (platform)
        }
    }
    
    private func createScrollingAlert () {
        alert = ScrollingAlert (frame: CGRectMake(0, CGRectGetMaxY(uiLayer.frame), CGRectGetWidth(uiLayer.frame), 40))
        alert.setAlertMessage(Constants.ScrollingMsgs.alertMsg, usingColor:UIColor.redColor())
        alert.beginScroll()
        tileLayer.addSubview(alert)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var f = self.alert.frame
            f.origin.y -= 55
            self.alert.frame = f
            }) { (done) -> Void in
        }
    }
    
    let gradientLayer = CAGradientLayer()
    private func createStrobe () {
        strobeView = UIView (frame: uiLayer.bounds)
        self.strobeView.alpha = 0
        self.strobeView.userInteractionEnabled = false
        
        let color1 = UIColor.redColor().CGColor
        let color2 = UIColor.clearColor().CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.frame = strobeView.bounds
        gradientLayer.locations = [0.0, 0.35]
        strobeView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        tileLayer.addSubview(strobeView)
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
    
    // Shuffle the input array
    private func newShuffledArray (array:NSArray) -> NSArray {
        let mutableArray = array.mutableCopy() as! NSMutableArray
        let count = mutableArray.count
        if count>1 {
            for var i=count-1; i > 0; --i {
                mutableArray.exchangeObjectAtIndex(i, withObjectAtIndex: Int(arc4random_uniform(UInt32(i+1))))
            }
        }
        return mutableArray as NSArray
    }
    
    // MARK: - Utility Methods

    // This method will make the tiles visible and enable dragging once complete
    private func activateTiles () {
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
    
    // Shake the screen to simulate and explosion
    var timesShaken = 0
    private func shakeScreen () {
        var mainF = masterForegroundLayer.frame
        if timesShaken > Constants.ShakeValues.shakeCount {
            self.masterForegroundLayer.frame = self.masterFGFrame
            createHoles ()
            audioController?.playSound(.GlassBreak)
            audioController?.playSound(.Alarm)
            audioController?.playSound(.Wind)
            createScrollingAlert()
            activateTiles ()
            tank?.beginCountdown()
            
            self.strobeTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("switchStrobe:"), userInfo: nil, repeats: true)
            return
        }
        
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            
            let mod = self.timesShaken % 5
            switch mod {
            case 0: mainF.origin.x += CGFloat (Constants.ShakeValues.shakeDist / 2)
            case 1: mainF.origin.y += CGFloat (Constants.ShakeValues.shakeDist / 2)
            case 2: mainF.origin.x -= CGFloat (Constants.ShakeValues.shakeDist)
            case 3: mainF.origin.y -= CGFloat (Constants.ShakeValues.shakeDist)
            case 4: mainF = self.masterFGFrame
            default: break
            }
            self.masterForegroundLayer.frame = mainF
            }) { (done) -> Void in
                self.timesShaken += 1
                self.shakeScreen()
       
        }
    }
    
    func switchStrobe (timer : NSTimer) {
        
        if self.strobeView.alpha == 0 {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.strobeView.alpha = CGFloat(Constants.Misc.strobeAlpha)
            })
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.strobeView.alpha = 0
            })
        }
    }
    
    // The user has successfull plugged the holes. Acknowledge
    private func playSuccess() {
        self.strobeView.alpha = 0
        strobeTimer?.invalidate()
        
        audioController?.stopAllSounds()
        
        self.tank?.reset()
        for hole in self.holes {
            hole.createPop()
        }
        alert.setAlertMessage(Constants.ScrollingMsgs.successMsg, usingColor:UIColor.greenColor())
    }
    
    private func playFailure() {
        audioController?.stopAllSounds()
        
        let fadeToBlackView = UIView (frame: self.view.bounds)
        fadeToBlackView.backgroundColor = UIColor.blackColor()
        fadeToBlackView.alpha = 0
        self.view.addSubview(fadeToBlackView)
        UIView .animateWithDuration(0.5, animations: { () -> Void in
            fadeToBlackView.alpha = 1
            }) { (done) -> Void in
                let endLabel = UILabel (frame: fadeToBlackView.bounds)
                endLabel.textAlignment = .Center
                endLabel.font = UIFont.systemFontOfSize(40)
                endLabel.text = Constants.ScrollingMsgs.levelFailedMsg
                endLabel.textColor = UIColor.redColor()
                fadeToBlackView.addSubview(endLabel)
                
                let tryAgainButton = UIButton (frame: CGRectMake (CGRectGetMidX(fadeToBlackView.frame) - 97,
                    CGRectGetMaxY(fadeToBlackView.frame) - 80, 194, 61 ))
                tryAgainButton.setImage(UIImage(named: Constants.Assets.tryAgainButton), forState: .Normal)
                tryAgainButton.addTarget(self, action: "tryAgainPressed:", forControlEvents: .TouchUpInside)
                fadeToBlackView.addSubview(tryAgainButton)
        }
    }

    func tryAgainPressed (button: UIButton) {
        
        audioController?.stopAndReset()
        timesShaken = 0
        for v in self.view.subviews {
            v.removeFromSuperview()
        }
        self.viewDidLoad()
        
    }


}




// -----------------------------------------------------------------------------
// MARK: - Extension to handle LetterTileDelegate

extension ViewController : LetterTileDelegate {

    // Tile dragging has ended. Check to see if the tile is in range of a hole
    // If so, see if it plugs the correct hole. If not, return it to its original
    // location
    func tileDragEnded (tile: LetterTile) {
        
        for hole in self.holes {
            if hole.didPlugHole(tile) {
                
                // Letter matches. Pop it into position
                if hole.letter == tile.letter {
                    tile.center = hole.center
                    tile.disableDrag()
                    
                    self.activeTile = nil
                    self.startLoc = nil
                    holesPlugged += 1
                    if holesPlugged == Constants.Tiles.count {
                        playSuccess()
                    }
                    return
                    
                } else {
                    break
                }
            }
        }
        
        // It did not plug any holes. Return it to its location
        
        returnActiveTile()
    }
    
    // Dragging began. Store the active tile to return it if need be
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
                audioController?.playSound(.Notice)
            }
        }
    }
    

}

// -----------------------------------------------------------------------------
// MARK: - Extension to handle OxygenTankDelegate

extension ViewController : OxygenTankDelegate {
    
    // The O2 Tank has depleted. Signal the end of the game
    func tankDepleted () {
        playFailure()
    }
}
