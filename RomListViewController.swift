//
//  RomListViewController.swift
//  Chip8
//
//  Created by Wilbur on 2016/02/24.
//  Copyright © 2016 Retroforce. All rights reserved.
//

import UIKit

class RomListViewController: UITableViewController {

    
    var tableData = [
        "15 Puzzle [Roger Ivie] (alt)",
        "15 Puzzle [Roger Ivie]",
        "Addition Problems [Paul C. Moews]",
        "Airplane",
        "Animal Race [Brian Astle]",
        "Astro Dodge [Revival Studios, 2008]",
        "Biorhythm [Jef Winsor]",
        "Blinky [Hans Christian Egeberg, 1991]",
        "Blinky [Hans Christian Egeberg] (alt)",
        "Blitz [David Winter]",
        "Bowling [Gooitzen van der Wal]",
        "Breakout (Brix hack) [David Winter, 1997]",
        "Breakout [Carmelo Cortez, 1979]",
        "Brick (Brix hack, 1990)",
        "Brix [Andreas Gustafsson, 1990]",
        "Cave",
        "Coin Flipping [Carmelo Cortez, 1978]",
        "Connect 4 [David Winter]",
        "Craps [Camerlo Cortez, 1978]",
        "Deflection [John Fort]",
        "Figures",
        "Filter",
        "Guess [David Winter] (alt)",
        "Guess [David Winter]",
        "Hi-Lo [Jef Winsor, 1978]",
        "Hidden [David Winter, 1996]",
        "Kaleidoscope [Joseph Weisbecker, 1978]",
        "Landing",
        "Lunar Lander (Udo Pernisz, 1979)",
        "Mastermind FourRow (Robert Lindley, 1978)",
        "Merlin [David Winter]",
        "Missile [David Winter]",
        "Most Dangerous Game [Peter Maruhnic]",
        "Nim [Carmelo Cortez, 1978]",
        "Paddles",
        "Pong (1 player)",
        "Pong (alt)",
        "Pong [Paul Vervalin, 1990]",
        "Pong 2 (Pong hack) [David Winter, 1997]",
        "Programmable Spacefighters [Jef Winsor]",
        "Puzzle",
        "Reversi [Philip Baltzer]",
        "Rocket [Joseph Weisbecker, 1978]",
        "Rocket Launch [Jonas Lindstedt]",
        "Rocket Launcher",
        "Rush Hour [Hap, 2006] (alt)",
        "Rush Hour [Hap, 2006]",
        "Russian Roulette [Carmelo Cortez, 1978]",
        "Sequence Shoot [Joyce Weisbecker]",
        "Shooting Stars [Philip Baltzer, 1978]",
        "Slide [Joyce Weisbecker]",
        "Soccer",
        "Space Flight",
        "Space Intercept [Joseph Weisbecker, 1978]",
        "Space Invaders [David Winter] (alt)",
        "Space Invaders [David Winter]",
        "Spooky Spot [Joseph Weisbecker, 1978]",
        "Squash [David Winter]",
        "Submarine [Carmelo Cortez, 1978]",
        "Sum Fun [Joyce Weisbecker]",
        "Syzygy [Roy Trevino, 1990]",
        "Tank",
        "Tapeworm [JDR, 1999]",
        "Tetris [Fran Dachille, 1991]",
        "Tic-Tac-Toe [David Winter]",
        "Timebomb",
        "Tron",
        "UFO [Lutz V, 1992]",
        "Vers [JMN, 1991]",
        "Vertical Brix [Paul Robson, 1996]",
        "Wall [David Winter]",
        "Wipe Off [Joseph Weisbecker]",
        "Worm V4 [RB-Revival Studios, 2007]",
        "X-Mirror",
        "ZeroPong [zeroZshadow, 2007]"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dest = segue.destinationViewController as! ViewController
        dest.filename = tableData[tableView.indexPathForSelectedRow!.row]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("emulator", sender: nil)
    }
}
