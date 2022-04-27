//
//  MenuController.swift
//  sortingVisualisation
//
//  Created by sergey on 04.03.2022.
//

import UIKit

class MenuController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBubble(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "bubbleID") as! BubbleController
        present(vc, animated: true)
    }
    
    @IBAction func goShaker(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "shakerID") as! ShakerController
        present(vc, animated: true)
    }
    
    @IBAction func goInsertion(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "insertionID") as! InsertionController
        present(vc, animated: true)
    }
    
    @IBAction func goMerge(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "mergeID") as! MergeController
        present(vc, animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        displayButtons()
    }
    
    func displayButtons() {
        
        let buttons = view.subviews as! [UIButton]
        let containerWidth = view.frame.width
        let containerHeight = view.frame.height
        
        var currentOriginX: CGFloat = 0.0
        var currentOriginY: CGFloat = 0.0
        
        buttons.forEach { btn in
        
            btn.frame.size.width = containerWidth/2.7
            btn.frame.size.height = containerHeight/2.7
            
            
            let buttonSpacingX = containerWidth-btn.frame.width*2.0
            let buttonSpacingY = containerHeight-btn.frame.height*2.0
            
            // if current X + label width will be greater than container view width
            //  "move to next row"
            if currentOriginX + btn.frame.width > containerWidth {
                currentOriginX = 0.0
                currentOriginY += btn.frame.height + buttonSpacingY
            }
            
            // set the btn frame origin
            btn.frame.origin.x = currentOriginX
            btn.frame.origin.y = currentOriginY
            
            // increment current X by btn width + spacing
            currentOriginX += btn.frame.width + buttonSpacingX
            
        }
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
