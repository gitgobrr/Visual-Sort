//
//  ShakerController.swift
//  sortingVisualisation
//
//  Created by sergey on 02.03.2022.
//

import UIKit

class ShakerController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myView.sysColor = .systemPurple
        updateData(self)
    }
    
    @IBAction func switchMode(_ sender: Any) {
        switch myView.mode {
        case .Lines:
            myView.mode = .Dots
        case .Dots:
            myView.mode = .Lines
        }
        updateData(self)
    }
    
    @IBOutlet weak var myView: MyView!
    
    var sleepTime:Float = 0
    
    @IBAction func widthSet(_ sender: UITextField) {
        guard sender.text != nil else {return}
        guard Int(sender.text!) != nil else {return}
        guard Int(sender.text!)! > 0 else {return}
        
        if myView.mode == .Dots, Int(sender.text!)! > Int(myView.bounds.height-1)  {
            return
        }
        
        myView.lineWidth = Int(sender.text!)!
        updateData(self)
    }
    
    @IBAction func insetSet(_ sender: UITextField) {
        guard sender.text != nil else {return}
        guard Int(sender.text!) != nil else {return}
        guard Int(sender.text!)! >= 0 else {return}
        
        myView.inset = Int(sender.text!)!
        updateData(self)
    }
    
    @IBAction func sleepSet(_ sender: UITextField) {
        guard sender.text != nil else {return}
        guard let n = Float(sender.text!), (n >= 0 && n <= 1) else {return}
        sleepTime = Float(sender.text!)!
    }
    
    
    var sortItem = DispatchWorkItem {}
    var delayItem = DispatchWorkItem {}
    
    @IBAction func shaker(_ sender: UIButton) {
        sender.superview?.subviews[0].isUserInteractionEnabled = false
        sender.superview?.subviews[1].isUserInteractionEnabled = false
        sender.superview?.subviews[2].subviews[0].isUserInteractionEnabled = false
        
        var sorted = true
        
        let mainQueue = DispatchQueue.main
        let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        
        delayItem = DispatchWorkItem {
            usleep(UInt32(self.sleepTime*1_000_000))
            self.myView.setNeedsDisplay()
        }
        
        sortItem = DispatchWorkItem {
            print("sort started")
        out: for i in 0..<self.myView.lines.count {
            sorted = true
            
            for j in i..<self.myView.lines.count-1-i {
                if self.sortItem.isCancelled { return }
                if self.delayItem.isCancelled { return }
                
                
                mainQueue.sync {
                    self.myView.lines[j].color = .red
                    self.myView.lines[j+1].color  = .red

                    self.delayItem.perform()
                }
                
                if self.myView.lines[j].path.currentPoint.y < self.myView.lines[j+1].path.currentPoint.y {
                    
                    sorted = false
                    
                    let lineI = self.myView.lines[j]
                    let lineJ = self.myView.lines[j+1]
                    
                    
                    let iX = lineI.path.currentPoint.x
                    let jX = lineJ.path.currentPoint.x
                    
                    mainQueue.sync {
                        lineI.path.apply(CGAffineTransform(translationX: jX-iX, y: 0))
                        lineJ.path.apply(CGAffineTransform(translationX: iX-jX, y: 0))
                        
                        self.myView.lines[j].path = lineJ.path
                        self.myView.lines[j+1].path = lineI.path
                        
                        self.myView.lines[j+1].color = .green
                        
                        self.delayItem.perform()
                    }
                }
                
                mainQueue.sync {
                    self.myView.lines[j].color = .black
                    self.myView.lines[j+1].color  = .black
                    
                    self.delayItem.perform()
                }
            }
            
            if sorted { break out }
            
            sorted = true
            
            //            from right to left
            
            for j in (1+i..<self.myView.lines.count-i).reversed() {
                if self.sortItem.isCancelled { return }
                if self.delayItem.isCancelled { return }
                
                mainQueue.sync {
                    self.myView.lines[j].color = .red
                    self.myView.lines[j-1].color  = .red
                    
                    self.delayItem.perform()
                }
                
                if self.myView.lines[j-1].path.currentPoint.y < self.myView.lines[j].path.currentPoint.y {
                    
                    sorted = false
                    
                    let lineI = self.myView.lines[j]
                    let lineJ = self.myView.lines[j-1]
                    
                    let iX = lineI.path.currentPoint.x
                    let jX = lineJ.path.currentPoint.x
                    
                    mainQueue.sync {
                        lineI.path.apply(CGAffineTransform(translationX: jX-iX, y: 0))
                        lineJ.path.apply(CGAffineTransform(translationX: iX-jX, y: 0))
                        
                        self.myView.lines[j].path = lineJ.path
                        self.myView.lines[j-1].path = lineI.path
                        
                        self.myView.lines[j].color = .green
                        
                        self.delayItem.perform()
                    }
                }
                
                mainQueue.sync {
                    self.myView.lines[j].color = .black
                    self.myView.lines[j-1].color  = .black
                    
                    self.delayItem.perform()
                }
            }
            
            if sorted { break out }
            
        }
            
            
            for i in 0..<self.myView.lines.count-1 {
                if self.myView.lines[i].path.currentPoint.y >= self.myView.lines[i+1].path.currentPoint.y {
                    
                    mainQueue.sync {
                        self.myView.lines[i].color = self.myView.sysColor
                        self.myView.lines[i+1].color = self.myView.sysColor

                        self.delayItem.perform()
                    }
                    continue
                } else {
                    break
                }
            }
            
            
            DispatchQueue.main.async {
                sender.superview?.subviews[0].isUserInteractionEnabled = true
                sender.superview?.subviews[1].isUserInteractionEnabled = true
                sender.superview?.subviews[2].subviews[0].isUserInteractionEnabled = true
                
            }
        }
        
        backgroundQueue.async(execute: sortItem)
        print("sort transfered to \(backgroundQueue)")
    }
    
    @IBAction func updateData(_ sender: Any) {
        myView.lines = []
        
        let lWidth = CGFloat(myView.lineWidth)
        let inset = CGFloat(myView.inset)
        
        for i in 0..<Int(myView.bounds.width/(lWidth+inset)) {
            let line = UIBezierPath()
            let bottom = myView.bounds.height
            line.lineWidth = CGFloat(lWidth)
            
            switch myView.mode {
            case .Lines:
                
                let a = CGPoint(x: (lWidth+inset)*CGFloat(i)+lWidth/2, y: bottom)
                let b = CGPoint(x: (lWidth+inset)*CGFloat(i)+lWidth/2, y: bottom-CGFloat(Int.random(in: 1...Int(bottom))))
                
                line.move(to: a)
                line.addLine(to: b)
            case .Dots:
                
                let b = CGPoint(x: (lWidth+inset)*CGFloat(i)+lWidth/2, y: bottom-CGFloat(Int.random(in: 1...Int(bottom-lWidth))))
                
                line.move(to: b)
                line.addLine(to: CGPoint(x: b.x, y: b.y-lWidth))
            }
            
            myView.lines.append((line,.black))
        }
        print("that many: ",myView.lines.count)
        myView.setNeedsDisplay()
    }
    
    @IBAction func back(_ sender: Any) {
        delayItem.cancel()
        sortItem.cancel()
        self.dismiss(animated: true)
    }
    
}
