//
//  self.swift
//  sortingVisualisation
//
//  Created by sergey on 27.02.2022.
//

import UIKit

enum Mode {
    case Lines
    case Dots
}

class MyView: UIView {

    
    var lines: [(path: UIBezierPath,color: UIColor)] = []
    
    var lineWidth = 6
    
    var inset = 5
    
    var mode = Mode.Lines

    var sysColor = UIColor.black

    override func draw(_ rect: CGRect) {
        
        for line in lines {
            line.color.setStroke()
            line.path.stroke()
        }
        
        values()
    }
    
    func values() {
        
        let textSize = self.bounds.height.description.size(withAttributes: nil)
        guard textSize.width <= CGFloat(lineWidth) else {return}
        
        lines.forEach { (path: UIBezierPath, color: UIColor) in
            let x = path.currentPoint.x
            let y = path.currentPoint.y
            
            let lineHeight = path.bounds.height
            var value = ""
            
            switch mode {
            case .Lines:
                value = Int(lineHeight).description
                let size = value.size(withAttributes: nil)
                
                if lineHeight < size.height {
                    value.draw(at: CGPoint(x: x-size.width/2, y: y-size.height), withAttributes: [.foregroundColor : UIColor.black])
                } else {
                    value.draw(at: CGPoint(x: x-size.width/2, y: y), withAttributes: [.foregroundColor : UIColor.white])
                }
            case .Dots:
                value = Int(self.bounds.height-y-lineHeight).description
                let size = value.size(withAttributes: nil)
                value.draw(at: CGPoint(x: x-size.width/2, y: lineHeight/2+y-size.height/2), withAttributes: [.foregroundColor : UIColor.white])
            }
        }
    }
    
}


