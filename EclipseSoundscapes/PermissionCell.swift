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
    
    weak var delegate: PermissionCellDelegate? {
        didSet {
            self.permissionView.delegate = delegate
        }
    }
    var permissionView : PermissionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        permissionView = PermissionView(for: [.locationWhenInUse,.notification])
        self.addSubview(permissionView)
        permissionView.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}
