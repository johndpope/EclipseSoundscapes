//
//  InstructionsViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/18/17.
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
import Eureka

class IntructionsViewController : UIViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var backBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    
    var cellId = "cellId"
    let pages = [Page(title: "Rumble Map", message: "To use the Rumble Map, touch your screen with only one finger. The map will produce audio tones and vibrations depending on how much light is underneath that particular spot. For best results, drag your finger across the touchscreen slowly. As you move your finger onto the bright sections of the Sun, your phone will vibrate more and produce a sharper, more pronounced audio tone. As you move your finger into the dark spaces blocked by the Moon’s disk, the vibration will diminish as the audio tone darkens and disappears. At times, you may hear a metronome-like ticking sound: that means you have entered an area of total darkness, either on the face of the Moon, or in the dark space outside the sphere of the Sun. By paying close attention to the audio tones and the strength of your phone’s vibration, you can learn how much sunlight is visible at each stage of the eclipse, and even explore some of the fascinating features of the Sun’s corona such as Bailey’s Beads, Helmet Streamers, Prominences, and the Diamond Ring effect. If a specific section of an image interests you and you want to return to it later, hold down your finger in one place until you hear a “blip” noise. You’ve created a marker! Next time your finger passes over this point, you will hear the “blip” again so you can continue to explore that area. For VoiceOver users, the Rumble Map begins in an inactive state. To change the Rumble Map's state, quickly tap the image twice to turn Rumble Map on or off. The Rumble Map becomes inactive each time the it looses focus.", imageName: "Soundscapes-RumbleMap")]
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ callback: ((UIViewController) -> ())? = nil) {
        super.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        
        view.addSubview(collectionView)
        view.addSubview(backBtn)
        
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        backBtn.anchorWithConstantsToTop(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0)
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension IntructionsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        cell.isAccessibilityElement = false
        cell.accessibilityElements = [cell.infoView.contentTextView]
        
        let page = pages[(indexPath as NSIndexPath).item]
        cell.page = page
        return cell
    }
}
