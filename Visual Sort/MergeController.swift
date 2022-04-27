//
//  MergeController.swift
//  sortingVisualisation
//
//  Created by sergey on 17.03.2022.
//

import UIKit

class MergeController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myView.sysColor = .systemTeal
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
    
    
    
    var counter = 0
    @IBAction func merge(_ sender: UIButton) {
        sender.superview?.subviews[0].isUserInteractionEnabled = false
        sender.superview?.subviews[1].isUserInteractionEnabled = false
        sender.superview?.subviews[2].subviews[0].isUserInteractionEnabled = false
        
        let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        
        delayItem = DispatchWorkItem {
            usleep(UInt32(self.sleepTime*1_000_000))
            self.myView.setNeedsDisplay()
        }
        
        sortItem = DispatchWorkItem {
            print("sort started")
            
            self.myView.lines = Array(self.mergeAndSort(array: self.myView.lines[self.myView.lines.startIndex..<self.myView.lines.endIndex]))
            print(self.counter, "times compared")
            self.counter = 0
            
            
            DispatchQueue.main.async {
                sender.superview?.subviews[0].isUserInteractionEnabled = true
                sender.superview?.subviews[1].isUserInteractionEnabled = true
                sender.superview?.subviews[2].subviews[0].isUserInteractionEnabled = true
            }
        }
        
        backgroundQueue.async(execute: sortItem)
        print("sort transfered to \(backgroundQueue)")
    }
    
    
    func mergeAndSort(array: ArraySlice<(path: UIBezierPath,color: UIColor)>) -> ArraySlice<(path: UIBezierPath,color: UIColor)> {
        if array.count <= 1 {
            return array
        }
        
        let mid = array.count / 2
        
        let l = array.startIndex..<array.index(array.startIndex, offsetBy: mid)
        let r = array.index(array.startIndex, offsetBy: mid)..<array.endIndex
        
        
        let leftArray = mergeAndSort(array: array[l])
        
        let rightArray = mergeAndSort(array: array[r])
        
        return merge(leftArray: leftArray,rightArray: rightArray)
    }
    
    func merge(leftArray: ArraySlice<(path: UIBezierPath,color: UIColor)>, rightArray: ArraySlice<(path: UIBezierPath,color: UIColor)>) -> ArraySlice<(path: UIBezierPath,color: UIColor)> {
        
        let mainQueue = DispatchQueue.main
        
        var leftIndex = leftArray.startIndex
        var rightIndex = rightArray.startIndex
        var orderedArray: [CGFloat] = []
        
//        print("Left array:")
//        for i in leftArray.indices {
//            print(self.myView.lines[i].path.currentPoint)
//        }
//        print("right array:")
//        for i in rightArray.indices {
//            print(self.myView.lines[i].path.currentPoint)
//        }
        
        
//        print("L: start:",leftIndex,"R: start:",rightIndex)
//        print("L: end:",leftArray.endIndex,"R: end:",rightArray.endIndex)
        while leftIndex < leftArray.endIndex && rightIndex < rightArray.endIndex {
            
            mainQueue.sync {
                self.myView.lines[leftIndex].color = .red
                self.myView.lines[rightIndex].color = .red
                delayItem.perform()
            }
            
            if leftArray[leftIndex].0.currentPoint.y > rightArray[rightIndex].0.currentPoint.y {
                orderedArray = orderedArray + [leftArray[leftIndex].path.currentPoint.y]
                
                mainQueue.sync {
                    self.myView.lines[leftIndex].color = self.myView.sysColor
                    self.myView.lines[rightIndex].color = .black
                    delayItem.perform()
                }
                leftIndex += 1
                
                mainQueue.sync {
                    self.myView.lines[leftIndex-1].color = .black
                    
                    delayItem.perform()
                }
            } else {
                orderedArray = orderedArray + [rightArray[rightIndex].path.currentPoint.y]
                
                mainQueue.sync {
                    self.myView.lines[leftIndex].color = .black
                    self.myView.lines[rightIndex].color = self.myView.sysColor
                    delayItem.perform()
                }
                rightIndex += 1
                
                mainQueue.sync {
                    self.myView.lines[rightIndex-1].color = .black
                    
                    delayItem.perform()
                }
            }
            
            counter += 1
        }
        
        let leftoverL = Array(leftArray[leftIndex..<leftArray.endIndex])
        let leftoverR = Array(rightArray[rightIndex..<rightArray.endIndex])
        
        leftoverL.forEach { (path: UIBezierPath, color: UIColor) in
            orderedArray.append(path.currentPoint.y)
        }
        
        leftoverR.forEach { (path: UIBezierPath, color: UIColor) in
            orderedArray.append(path.currentPoint.y)
        }
        
//        print("sorted array:")
//        for i in orderedArray.indices {
//            print(orderedArray[i])
//        }
        
        var j = 0
        
        for i in leftArray.indices {
            
            let x = self.myView.lines[i].path.currentPoint.x
            
            let lineHeight = self.myView.lines[i].path.cgPath.boundingBox.height
            
            var y0: CGFloat = 0
            switch myView.mode {
            case .Lines:
                y0 = self.myView.lines[i].path.currentPoint.y+lineHeight
            case .Dots:
                y0 = orderedArray[j]+lineHeight
            }
            
            let y1 = orderedArray[j]
            
            
            let a = CGPoint(x: x, y: y0)
            let b = CGPoint(x: x, y: y1)
            
            mainQueue.sync {
                self.myView.lines[i].path.removeAllPoints()
                self.myView.lines[i].path.move(to: a)
                self.myView.lines[i].path.addLine(to: b)
                

                delayItem.perform()
            }
            j += 1
        }
        
        for i in rightArray.indices {
            let x = self.myView.lines[i].path.currentPoint.x
            
            let lineHeight = self.myView.lines[i].path.cgPath.boundingBox.height
            
            var y0: CGFloat = 0
            switch myView.mode {
            case .Lines:
                y0 = self.myView.lines[i].path.currentPoint.y+lineHeight
            case .Dots:
                y0 = orderedArray[j]+lineHeight
            }
            
            let y1 = orderedArray[j]
            
            
            let a = CGPoint(x: x, y: y0)
            let b = CGPoint(x: x, y: y1)
            
            mainQueue.sync {
                self.myView.lines[i].path.removeAllPoints()
                self.myView.lines[i].path.move(to: a)
                self.myView.lines[i].path.addLine(to: b)
                
                delayItem.perform()
            }
            j += 1
        }
        
        
        if orderedArray.count == self.myView.lines.count {
            for i in 0..<self.myView.lines.count-1 {
                if self.myView.lines[i].path.currentPoint.y >= self.myView.lines[i+1].path.currentPoint.y {
                    
                    mainQueue.sync {
                        self.myView.lines[i].color = self.myView.sysColor
                        self.myView.lines[i+1].color = self.myView.sysColor
                        delayItem.perform()
                    }
                    continue
                } else {
                    break
                }
            }
        }
        
        return self.myView.lines[leftArray.startIndex..<rightArray.endIndex]
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







