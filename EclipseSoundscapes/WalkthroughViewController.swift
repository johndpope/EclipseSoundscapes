//
//  WalkthroughViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/30/17.
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

class WalkthroughViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
    
    let cellId = "cellId"
    let PermissionCellId = "permissionCellId"
    
    let pages: [Page] = {
        let firstPage = Page(title: "Welcome", message: "Thank you for downloading the Eclipse Soundscapes app. We hope to create an engaging multi-sensory experience of the August 21, 2017 eclipse for all participants, including people who are blind or visually impaired. Inside, you will find a countdown to the eclipse in your area, with illustrative audio descriptions of the eclipse in real time, provided by the National Center for Accessible Media.", imageName: "artwork")
        
        let secondPage = Page(title: "Rumble Map", message: "Our Rumble Map tool is designed for you to hear and feel the eclipse at various stages in its progression. The Rumble Map displays photos of the eclipse at its most engaging and educational moments. When you touch the image on the screen, the app will read the grayscale value of a pixel underneath your finger, and play an audio tone which will vibrate your phone with a strength relative to the brightness of that section. By paying close attention to the audio tones and the strength of your phone’s vibration, you can learn how much sunlight is visible at each stage of the eclipse, and explore some of the fascinating features of the sun’s corona.", imageName: "Soundscapes-RumbleMap")
        
        let thirdPage = Page(title: "Eclipse Center", message: "The Eclipse Center is your go-to destination for learning about the eclipse in your area and discovering this exciting astronomical event as it happens. Once you accept a location permission, you will find a countdown to the eclipse, information on whether you will experience a total or a partial solar eclipse in your area, and the exact start time, peak time, and end time of the eclipse.", imageName: "Soundscapes-Eclipse Center")
        
        return [firstPage, secondPage, thirdPage]
    }()
    
    var pageCell : PageCell?
    var permissionCell : PermissionCell?
    
    
    var currentPage = 0 {
        didSet {
            switch currentPage {
            case 0:
                pageLabel.textColor = .white
                previousButton.isHidden = true
                skipButton.accessibilityLabel = "Skip to end of Walk Through"
                break
            case 1,2:
                pageLabel.textColor = .black
                previousButton.isHidden = false
                self.previousButton.tintColor = UIColor.init(r: 227, g: 94, b: 5)
                skipButton.accessibilityLabel = "Skip to end of Walk Through"
                break
            case 3:
                previousButton.isHidden = false
                self.previousButton.tintColor = .black
                skipButton.accessibilityLabel = "Can not Skip Anymore"
                break
            default:
                break
            }
            
            pageLabel.text = "Page \(currentPage+1) of 4"
            pageLabel.accessibilityLabel = "Walk Through Page \(currentPage+1) of 4"
        }
    }
    
    func setAccessibleElements(for page: Int, cell: UICollectionViewCell?){
        guard let cell = cell else {
            return
        }
        var pageCell : PageCell?
        var permissionCell : PermissionCell?
        if cell is PageCell {
            pageCell = cell as? PageCell
        }
        
        if cell is PermissionCell {
            permissionCell = cell as? PermissionCell
        }
        
        self.view.accessibilityElements = nil
        switch currentPage {
        case 0:
            self.view.accessibilityElements = [nextButton, skipButton, pageLabel]
            if let cellElements = pageCell?.accessibilityElements {
                view.accessibilityElements?.append(cellElements)
            }
            break
        case 1, 2:
            self.view.accessibilityElements = [previousButton, nextButton, skipButton, pageLabel]
            if let cellElements = pageCell?.accessibilityElements {
                view.accessibilityElements?.append(cellElements)
            }
            break
        case 3:
            self.view.accessibilityElements = [previousButton, pageLabel]
            if let cellElements = permissionCell?.accessibilityElements {
                for i in 0..<cellElements.count {
                    view.accessibilityElements?.insert(cellElements[i], at: i+1)
                }
            }
            break
        default:
            break
        }
    }
    
    
    var pageLabel : UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 11)
        label.textAlignment = .right
        label.text = "Page 1 of 4"
        return label
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.init(r: 227, g: 94, b: 5), for: .normal)
        button.addTarget(self, action: #selector(skip), for: .touchUpInside)
        button.accessibilityLabel = "Skip to end of Walk Through"
        return button
    }()
    
    func skip() {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.previousButton)
        currentPage = pages.count
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        moveControlConstraintsOffScreen()
        self.previousButton.tintColor = .black
        
    }
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Right_Arrow"), for: .normal)
        button.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        button.accessibilityLabel = "Next Page"
        button.accessibilityTraits |= UIAccessibilityTraitCausesPageTurn
        return button
    }()
    
    lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Left_Arrow"), for: .normal)
        button.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        button.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityLabel = "Previous Page"
        button.accessibilityTraits |= UIAccessibilityTraitCausesPageTurn
        return button
    }()
    
    func nextPage() {
        //we are on the last page
        if currentPage == pages.count {
            return
        }
        
        //second last page
        if currentPage == pages.count - 1 {
            moveControlConstraintsOffScreen()
        }
        
        let indexPath = IndexPath(item: currentPage+1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentPage += 1
    }
    
    func previousPage() {
        //on the first page
        if currentPage == 0 {
            return
        }
        
        //last page
        if currentPage == pages.count {
            moveControlConstraintsOnScreen()
        }
        
        let indexPath = IndexPath(item: currentPage - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentPage -= 1
        
    }
    
    var pageLabelbottomAnchor: NSLayoutConstraint?
    var skipButtonRightAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    var previousButtonTopAnchor : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboardNotifications()
        
        self.view.accessibilityElements = [collectionView, nextButton, skipButton, pageLabel]
        
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        
        pageLabelbottomAnchor = pageLabel.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: view.frame.height*1/4 + 10, rightConstant: 4, widthConstant: 0, heightConstant: 10).first
        
        skipButtonRightAnchor = skipButton.anchor(nextButton.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 60, heightConstant: 0)[1]
        
        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
        
        previousButtonTopAnchor = previousButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
        
        //use autolayout instead
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        registerCells()
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -100 : -50
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: nil)
    }
    
    var lastOffset : CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    var pageControlRightConstant : CGFloat = 0
    var skipButtonRightConstant : CGFloat = 0
    var nextButtonTopConstant : CGFloat = 0
    var previousButtonTopConstant : CGFloat = 0
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollOffset = targetContentOffset.pointee.x
        let pageNumber = Int(scrollOffset / view.frame.width)
        currentPage = pageNumber
        
        //we are on the last page
        if currentPage == pages.count {
            moveControlConstraintsOffScreen()
        } else {
            //back on regular pages
            moveControlConstraintsOnScreen()
        }
        
        let cell = collectionView.cellForItem(at: IndexPath(item: pageNumber, section: 0))
        
        setAccessibleElements(for: pageNumber, cell: cell)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("Finished Scrolling")
        
        let scrollOffset = scrollView.contentOffset.x
        let pageNumber = Int(scrollOffset / view.frame.width)
        
        let cell = collectionView.cellForItem(at: IndexPath(item: pageNumber, section: 0))
        
        setAccessibleElements(for: pageNumber, cell: cell)
    }
    
    fileprivate func moveControlConstraintsOffScreen() {
        
        skipButtonRightAnchor?.constant = 80
        nextButtonTopAnchor?.constant = -40
        pageLabelbottomAnchor?.constant = -10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func moveControlConstraintsOnScreen() {
        
        skipButtonRightAnchor?.constant = -4
        nextButtonTopAnchor?.constant = 16
        previousButtonTopAnchor?.constant = 16
        pageLabelbottomAnchor?.constant = -(view.frame.height*1/4 + 10)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PermissionCell.self, forCellWithReuseIdentifier: PermissionCellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pages.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PermissionCellId, for: indexPath) as! PermissionCell
            cell.delegate = self
            cell.isAccessibilityElement = false
            cell.accessibilityElements = [cell.titleLabel, cell.locationBtn, cell.notificationBtn, cell.laterBtn]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        cell.isAccessibilityElement = false
        cell.accessibilityElements = [cell.infoView.contentTextView]
        
        let page = pages[(indexPath as NSIndexPath).item]
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        //scroll to indexPath after the rotation is going
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadData()
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension WalkthroughViewController: PermissionCellDelegate {
    func didFinish() {
        UserDefaults.standard.set(true, forKey: "WalkThrough")
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = stb.instantiateViewController(withIdentifier: "Tab") as! TabViewController
        self.present(tabBarController, animated: true)
    }
}