//
//  ViewController.swift
//  Chip8
//
//  Created by Wilbur on 2016/02/22.
//  Copyright © 2016 Retroforce. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, Chip8CPUDelegate {

    var audio:AudioPlayer!
    var chipCPU:Chip8CPUCore!
    var drawing = false
    let deviceFrame = UIScreen.mainScreen().bounds
    var filename = ""
    
    @IBOutlet weak var canvas: UIImageView!
    
    @IBAction func close(sender: AnyObject) {
        chipCPU.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func resume(sender: AnyObject) {
        chipCPU.start()
    }
    
    @IBAction func buttonDown(sender: AnyObject) {
        chipCPU.keyInput[sender.tag] = 1
    }
    
    @IBAction func buttonUp(sender: AnyObject) {
        chipCPU.keyInput[sender.tag] = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        audio = AudioPlayer.defaultPlayer(soundFile: "beep")
        chipCPU = Chip8CPUCore(rom: filename, delegate: self)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.chipCPU.start()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func drawScreen(screenBuffer: [UInt8]) {
        
        if !self.drawing {
            self.drawBuffer(screenBuffer)
        }

    }
    
    func clearScreen() {
    }
    
    
    func drawBuffer(buffer:[UInt8]) {
        
        dispatch_sync(dispatch_get_main_queue(), {
            self.drawing = true
            self.canvas.image = BitBlitter.blitScreenBuffer(canvasWidth: self.canvas.bounds.width, canvasHeight: self.canvas.bounds.height, screenBuffer: buffer)
            self.drawing = false
        })

    }
    
    func playSound() {
        audio.play()
    }
    

    
}

