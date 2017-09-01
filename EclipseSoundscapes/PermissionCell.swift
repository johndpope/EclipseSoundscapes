//
//  PermissionCell
//  audible
//
//  Created by Arlindo Goncalves on 7/30/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

/// Hanldes Permissions for the app
class PermissionCell: UICollectionViewCell {
    
    
    /// Permission Delegate that is passed to the PermissionView
    weak var delegate: PermissionViewDelegate? {
        didSet {
            self.permissionView.delegate = delegate
        }
    }
    
    
    /// Local PermissionView
    var permissionView : PermissionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Setup and layout view's subviews
    func setupView() {
        permissionView = PermissionView(for: [.locationWhenInUse,.notification])
        self.addSubview(permissionView)
        permissionView.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}
