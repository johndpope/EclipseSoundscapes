//
//  EclipseTouchViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/15/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

class EclipseTouchViewController: UIViewController {
    @IBOutlet weak var eclipseImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerPanGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerPanGesture() {
        eclipseImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
    }
    
    func unregisterGesture(for view: UIView) {
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: recognizer.view)
            let scale = eclipseImageView.grayScale(point: location)
            print(scale)
            break
        case .changed:
            let location = recognizer.location(in: recognizer.view)
            let scale = eclipseImageView.grayScale(point: location)
            print(scale)
            break
        default:
            break
        }

    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        let touch = touches.first
//        if let point = touch?.location(in: view) {
//            let scale = eclipseImageView.grayScale(point: point)
//            print(scale)
//        }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        let touch = touches.first
//        if let point = touch?.location(in: view) {
//            let scale = eclipseImageView.grayScale(point: point)
//            print(scale)
//        }
//    }
}
