//
//  Chip8.swift
//  Chip8
//
//  Created by Wilbur on 2016/02/22.
//  Copyright © 2016 Retroforce. All rights reserved.
//

let COUNT_KEYS = 16
let COUNT_DISPLAY_BUFFERS = 64*32
let COUNT_GPIO = 16
let COUNT_STACK = 16
let COUNT_MEMORY = 4096

protocol Chip8CPUDelegate {
    func drawScreen(screenBuffer:[UInt8])
    func clearScreen()
    func playSound()
}

import Foundation

class Chip8CPUCore {
    
    var delegate:Chip8CPUDelegate?
    
    /*** Input */
    
    //  Keyboard input 16 keys
    var keyInput:[UInt8] = []
    
    /*** Output */
     
    //  Display output 64x32 pixels
    private var displayBuffer:[UInt8] = []
    
    /*** CPU */
    
    //  Registers 16 8-bit registers
    private var gpio:[UInt8] = []
    
    //  Index register which is 16-bit
    private var index:UInt16 = 0
    
    //  Program counter is also 16-bit
    private var pc:UInt16 = 0
    
    //  Stack pointer 16 16-bit
    private var stack:[UInt16] = []
    
    //  Timer Registers
    private var soundTimer:UInt8 = 0
    private var delayTimer:UInt8 = 0
    
    /*** Memory */

    //  Memory 4096 bytes max
    private var memory:[UInt8] = []
    
    /*** FONTS */
    
    //  Chip8 fontset
    let fontset:[UInt8] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ];
    
    //  System Defaults
    private var hasExited = false
    private var exit = false
    private var shouldDraw = false
    private var opcode:UInt16 = 0
    private var rom = ""
    
    init(rom:String, delegate:Chip8CPUDelegate?=nil) {
        
        self.rom = rom
        if let delegate = delegate { self.delegate = delegate }
    }
   
    func start() {
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            self.hasExited = true
            self.initialise()
            self.loadRomImage(self.rom)
            self.cpuMainLoop()
        })
        
    }
    
    //  MARK: - Main CPU loop
    func cpuMainLoop() {
        
        while !hasExited {
            
            let start : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
            
            cycle()
            draw()
            shouldDraw = false
            
            let end : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
            let delta = end - start
            //let deletaInMs = useconds_t(delta*1000)
            let timeToSleep = 0.001 - delta
            
            if (timeToSleep > 0) {
                let timeToSleepMicroSec = useconds_t(timeToSleep * 100)
                usleep(useconds_t(timeToSleepMicroSec))
            }
            
            hasExited = exit
        }
    }
    
    func stop() {
        self.exit = true
    }
    
    func initialise() {
        
        keyInput = [UInt8](count: COUNT_KEYS, repeatedValue: 0)
        displayBuffer = [UInt8](count: COUNT_DISPLAY_BUFFERS, repeatedValue: 0)
        gpio = [UInt8](count: COUNT_GPIO, repeatedValue: 0)
        index = 0
        pc = 0x200
        stack = [UInt16](count: COUNT_STACK, repeatedValue: 0)
        soundTimer = 0
        delayTimer = 0
        memory = [UInt8](count: COUNT_MEMORY, repeatedValue: 0)
        hasExited = false
        shouldDraw = false
        exit = false
        opcode = 0
        
        //  Load fonts
        var i = 0
        while i < fontset.count {
            //  load 80-char font set
            memory[i] = fontset[i]
            i += 1
        }
        
    }
    
    func loadRomImage(rom:String) {
        
        let filePath = NSBundle.mainBundle().pathForResource(rom, ofType: "ch8")
        
        if let data = NSData(contentsOfFile : filePath!) {
            
            let ptr = UnsafePointer<UInt8>(data.bytes)
            let bytes = UnsafeBufferPointer<UInt8>(start:ptr, count:data.length)
            let length = data.length
            
            data.getBytes((&memory + 0x200), length: length)
        }else{
            print("Failed to load rom image")
        }
    
    }
    
    func dispatchEvents() {
        
    }
    
    func cycle() {
        
        //  Get opcode
        let hi = memory[Int(pc)]
        let lo = memory[Int(pc+1)]
        opcode = UInt16(hi) << 8 | UInt16(lo)
        let firstByte:UInt16 = (opcode & 0xF000)
        
        let x = Int(opcode & 0x0F00) >> 8
        let y = Int(opcode & 0x00F0) >> 4
        
        //  Perform opcode actions here
        switch firstByte {
            
        case 0x0000:
            switch opcode {
            case 0x00E0: // Clears the screen.
                logOpcode(firstByte, message: "0x00E0: // Clears the screen.")
                clearsTheScreen()
                pc += 2
                
            case 0x00EE: // Returns from a subroutine.
                logOpcode(firstByte, message: "0x00EE: // Returns from a subroutine.")
                pc = stack.removeLast()
                
            default:
                hasExited = true
                unknownOptocode(opcode)
            }
            
        case 0x1000: // Jumps to address NNN.
            logOpcode(firstByte, message: "0x1000: // Jumps to address NNN.")
            pc = (opcode & 0x0FFF)
        
        case 0x2000: // Call subroutine at nnn.
            logOpcode(firstByte, message: "0x2000: // Call subroutine at nnn.")
            stack.append(pc + 2)
            pc = opcode & 0x0FFF
        
        case 0x3000: // Skip next instruction if Vx = kk.
            logOpcode(firstByte, message: "0x3000: // Skip next instruction if Vx = kk.")
            if Int(gpio[x]) == Int(opcode & 0x00FF) {
                pc += 4
            }else{
                pc += 2
            }
            
        case 0x4000: // Skip next instruction if Vx != kk.
            logOpcode(firstByte, message: "0x4000: // Skip next instruction if Vx != kk.")
            //The interpreter compares register Vx to kk, and if they are not equal, increments the program counter by 2.
            if gpio[x] != UInt8((opcode & 0x00FF)) {
                pc += 4
            }else{
                pc += 2
            }
        
        case 0x5000: // Skip next instruction if Vx = Vy.
            logOpcode(firstByte, message: "0x5000: // Skip next instruction if Vx = Vy.")
            if gpio[x] == gpio[y] {
                pc += 4
            }else{
                pc += 2
            }
            
        case 0x6000: // The interpreter puts the value kk into register Vx.
            logOpcode(firstByte, message: "0x6000: // The interpreter puts the value kk into register Vx.")
            gpio[x] = UInt8(opcode & 0x00FF)
            pc += 2
            
        case 0x7000: // Adds the value kk to the value of register Vx, then stores the result in Vx.
            logOpcode(firstByte, message: "0x7000: // Adds the value kk to the value of register Vx, then stores the result in Vx.")
            var result = UInt32(gpio[x]) + UInt32((opcode & 0x00FF))
            //  TODO: May need to check if result is bigger then 255
            if result > 255 {
                result -= (255 + 1)
            }
            gpio[x] = UInt8(result)
            pc += 2
        
        case 0x8000:
            switch opcode & 0xF00F {
            case 0x8000: // Sets VX to the value of VY.
                logOpcode(firstByte, message: "0x8000: // Sets VX to the value of VY.")
                gpio[x] = gpio[y]
                pc += 2
                
            case 0x8001:
                gpio[x] = gpio[x] | gpio[y]
                pc += 2
                
            case 0x8002:
                gpio[x] = gpio[x] & gpio[y]
                pc += 2
                
            case 0x8003:
                gpio[x] = gpio[x] ^ gpio[y]
                pc += 2
                
            case 0x8004:
                var addResult:Int = Int(gpio[x]) + Int(gpio[y])
                if addResult > 255 {
                    gpio[0xF] = 1
                    addResult -= (255 + 1)
                } else {
                    gpio[0xF] = 0
                }
                gpio[x] = UInt8(addResult)
                pc += 2
                
            case 0x8005:
                let VY = gpio[y]
                let VX = gpio[x]
                var result = Int(VX) - Int(VY)
                if result<0 {
                    gpio[0xF] = 0
                    result += 256
                } else {
                    gpio[0xF] = 1
                }
                
                gpio[x] = UInt8(result)
                pc += 2
                
            case 0x8006:
                gpio[0xF] = gpio[x] & 0x01
                gpio[x] = gpio[x] >> 1
                pc += 2
                
            case 0x8007:
                var result = Int(gpio[y]) - Int(gpio[x])
                if result<0 {
                    gpio[0xF] = 0
                    result += 256
                } else {
                    gpio[0xF] = 1
                }
                
                gpio[x] = UInt8(result)
                pc += 2

                
            case 0x800E: // Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
                logOpcode(firstByte, message: "0x800E: // Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.")
                gpio[0xF] = gpio[x] & 0x80
                gpio[x] = gpio[x] << 1
                pc += 2
                
            default:
                hasExited = true
                unknownOptocode(opcode)
            }
            
        case 0x9000: // Skips the next instruction if VX doesn't equal VY.
            logOpcode(firstByte, message: "0x9000: // Skips the next instruction if VX doesn't equal VY.")
            if gpio[x] != gpio[y] {
                pc += 4
            }else{
                pc += 2
            }
            
        case 0xA000: // The value of register I is set to nnn.
            logOpcode(firstByte, message: "0xA000: // The value of register I is set to nnn.")
            index = UInt16(opcode & 0x0FFF)
            pc += 2
            
        case 0xC000: // Set Vx = random byte AND kk.
            logOpcode(firstByte, message: "0xC000: // Set Vx = random byte AND kk.")
            let randomValue = UInt8(arc4random_uniform(255)) & UInt8(opcode & 0x00FF)
            gpio[x] = randomValue
            pc += 2
            
        case 0xD000: // Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.
            logOpcode(firstByte, message: "0xD000: // Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.")
            
            let x = gpio[Int(opcode & 0x0F00) >> 8]
            let y = gpio[Int(opcode & 0x00F0) >> 4]
            let height = Int(opcode & 0x000F)
            
            gpio[0xF] = 0
            for var yline = 0; yline < height; yline++ {
                let pixel = memory[Int(index + UInt16(yline))]
                
                for var xline = 0; xline < 8; xline++ {
                    
                    if (pixel & UInt8(0x80 >> xline)) != 0 {
                        
                        
                        let pixelX = Int(x) + xline
                        let pixelY = Int(y) + yline
                        let pixelIndex = pixelX + pixelY * 64
                        
                        if pixelIndex < 2048 {
                            if displayBuffer[pixelIndex] == 1 {
                                gpio[0xF] = 1
                                
                            }
                            displayBuffer[pixelIndex] ^= 1
                        }
                    }
                }
            }
            
            shouldDraw = true
            pc += 2
            
        case 0xE000:
            switch opcode & 0x00FF {
            case 0x009E: // Skips the next instruction if the key stored in VX is pressed.
                logOpcode(firstByte, message: "0x009E: // Skips the next instruction if the key stored in VX is pressed.")
                if keyInput[Int(gpio[x])] == 1 {
                    pc += 4
                    shouldDraw = true
                }else{
                    pc += 2
                }
                
            case 0x00A1: // Skips the next instruction if the key stored in VX isn't pressed.
                logOpcode(firstByte, message: "0x00A1: // Skips the next instruction if the key stored in VX isn't pressed.")
                if keyInput[Int(gpio[x])] == 0 {
                    pc += 4
                }else{
                    pc += 2
                }
                
            default:
                hasExited = true
                unknownOptocode(opcode)
            }
            
        case 0xF000:
            switch opcode & 0x00FF {
                
            case 0x007: // Sets VX to the value of the delay timer.
                logOpcode(firstByte, message: "0x007: // Sets VX to the value of the delay timer.")
                gpio[x] = delayTimer
                pc += 2
                
            case 0x000A: // A key press is awaited, and then stored in VX.
                logOpcode(firstByte, message: "0x000A: // A key press is awaited, and then stored in VX.")
                for var i = 0; i < 16; i++ {
                    if keyInput[i] > 0 {
                        gpio[x] = UInt8(i)
                        pc += 2
                    }
                }
                
            case 0x0015: // Sets the delay timer to VX.
                logOpcode(firstByte, message: "0x0015: // Sets the delay timer to VX.")
                delayTimer = gpio[x]
                pc += 2
                
            case 0x0018: // Sets the sound timer to VX.
                logOpcode(firstByte, message: "0x0018: // Sets the sound timer to VX.")
                soundTimer = gpio[x]
                pc += 2
                
            case 0x001E: // Adds VX to I. Set overflow buffer VF to 1 of result bigger then 255.
                logOpcode(firstByte, message: "0x001E: // Adds VX to I. Set overflow buffer VF to 1 of result bigger then 255.")
                let result = Int(index) + Int(gpio[x])
                
                if result > 0xFFF {
                    gpio[0xF] = 1
                    index = UInt16(result - Int(0xFFF + 1))
                }else{
                    gpio[0xF] = 0
                    index = UInt16(result)
                }
                pc += 2
                
            case 0x0029:
                index = UInt16(gpio[x]*5)
                pc += 2
                
            case 0x0033:
                var number = gpio[x]
                
                for var i = 3; i > 0; i-- {
                    let value = number % 10
                    let ind = Int(index) + Int(i - 1)
                    self.memory[ind] = value
                    // this.memory[this.i + i - 1] = parseInt(number % 10);
                    number /= 10;
                }
                pc += 2
                
            case 0x0055:
                for var i=0; i<=x; i++ {
                    let ind : Int = Int(index + UInt16(i))
                    self.memory[ind] = gpio[i]
                }
                pc += 2
                
            case 0x0065: // Fills V0 to VX with values from memory starting at address I.
                logOpcode(firstByte, message: "0x0065: // Fills V0 to VX with values from memory starting at address I.")
                //  TODO: Might have an issue here
                for var i=0; i<=x; i++ {
                    let address = Int(index + UInt16(i))
                    gpio[i] = memory[address]
                }
                pc += 2
                
            default:
                hasExited = true
                unknownOptocode(opcode)
            }
            
        default:
            hasExited = true
            unknownOptocode(opcode)
        }

        //  Decrement timers
        if delayTimer > 0 { delayTimer -= 1 }
        if soundTimer > 0 {
            soundTimer -= 1
            
            if soundTimer == 0 {
                //  Play a sound
                if let delegate = delegate {
                    delegate.playSound()
                }
            }
        }
    }
    
    func draw() {
        if shouldDraw {
            if let delegate = self.delegate {
                delegate.drawScreen(self.displayBuffer)
            }
        }
    }
    
    func logOpcode(first:UInt16, message:String) {
//        print("First-byte: \(NSString(format: "%2X", first)) -> \(message)")
//        print("")
    }
    
    func unknownOptocode(let optocode: UInt16) {
        let optocodeInHex = String(optocode, radix: 16)
        print("UNKNOWN OPCODE: \(optocodeInHex)")
    }
    
    func clearsTheScreen(){
        if let delegate = delegate {
            delegate.clearScreen()
        }
        displayBuffer = [UInt8](count: COUNT_DISPLAY_BUFFERS, repeatedValue: 0)
        shouldDraw = true
    }
    
}













