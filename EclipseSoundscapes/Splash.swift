//
//  Splash.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/26/17.
//
//  Copyright © 2017 Arlindo Goncalves.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see [http://www.gnu.org/licenses/].
//
//  For Contact email: arlindo@eclipsesoundscapes.org

import UIKit

class Splash : UIView {
    
    var imageView : UIImageView = {
        var iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupView()
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.center(in: self)
        imageView.setSize(125, height: 125)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class func splash(over view: UIView, image: UIImage = #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"), backgroundColor: UIColor = .white, completion: (()-> Void)? = nil) {
        let splashView = Splash(frame: view.bounds)
        splashView.backgroundColor = backgroundColor
        splashView.imageView.image = image
        
        view.addSubview(splashView)
        splashView.animate(completion)
    }
    
    private func animate(_ completion: (()-> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveLinear, animations: {
            self.imageView.transform = CGAffineTransform.init(scaleX: 2.0, y: 2.0)
        }) { (_) in
            UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveLinear, animations: {
                self.imageView.transform = .identity
                self.imageView.alpha = 0.0
                self.alpha = 0.0
            }) { [weak self] (_)  in
                completion?()
                self?.removeFromSuperview()
            }
        }
    }
}
