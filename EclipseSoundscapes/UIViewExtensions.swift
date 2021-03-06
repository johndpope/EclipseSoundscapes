// UIViewExtensions.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 apegroup
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import  UIKit

extension UIView {
    
    /**
     Slide in view from the top.
    */
    func slideInFromTop(_ duration: TimeInterval = 0.3, completionDelegate: AnyObject? = nil) {
        let slideInFromTopTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromTopTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        slideInFromTopTransition.type = kCATransitionPush
        slideInFromTopTransition.subtype = kCATransitionFromBottom
        slideInFromTopTransition.duration = duration
        slideInFromTopTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromTopTransition.fillMode = kCAFillModeRemoved
        
        self.layer.add(slideInFromTopTransition, forKey: "slideInFromTopTransition")
    }
}
