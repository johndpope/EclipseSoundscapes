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
import Eureka


/// Walkthrough Controller
class WalkthroughViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TypedRowControllerType {
    
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    
    /// Bool if the walktrhough is showing for the first time ever
    private var isBegining = true
    
    /// CollectionView that manages each page of the WalkThrough
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
    
    
    /// Cell reuse id
    let cellId = "cellId"
    
    /// Permission cell reuse id
    let PermissionCellId = "permissionCellId"
    
    //MARK: Constraints to animate controls on and off screen
    var pageLabelbottomAnchor: NSLayoutConstraint?
    var skipButtonRightAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    var previousButtonTopAnchor : NSLayoutConstraint?
    
    /// Each page of the walkthrough
    let pages: [Page] = {
        let firstPage = Page(title: "Welcome", message: "Thank you for downloading the Eclipse Soundscapes app, a multi-sensory experience for people of all learning styles to engage with astronomical events, including total solar eclipses. Inside this app, you will find countdowns to major astronomical events in your area, and real time narrations of those events with illustrative audio descriptions provided by the National Center for Accessible Media. You can also explore the cosmos with high quality photos, educational information, and accessible learning tools.", imageName: "artwork")
        
        let secondPage = Page(title: "Rumble Map", message: "Our Rumble Map tool is designed for you to hear and feel astronomical phenomena, such as eclipses, using the touchscreen and the speakers on your smartphone. For example: the Rumble Map will display photos of the Moon passing in front of the Sun during the most engaging and educational moments of an eclipse. When you touch the image on the screen, the app will read the grayscale value of a pixel underneath your finger, and play an audio tone which will vibrate your phone with a strength relative to the brightness of that section. As you move your finger onto the bright sections of the Sun, your phone will vibrate more. As you move your finger into the dark spaces blocked by the Moon’s disk, the vibration will diminish and disappear. By paying close attention to the audio tones and the strength of your phone’s vibration, you can learn how much sunlight is visible at each stage of the eclipse, and explore some of the fascinating features of the Sun’s corona.", imageName: "Soundscapes-RumbleMap")
        
        let thirdPage = Page(title: "Eclipse Center", message: "The Eclipse Center is your go-to destination for learning about eclipses in your area so you can discover them as they happen. When you open the Eclipse Center, it will ask to pinpoint your geographic location. Once you accept, you will find a countdown to the next eclipse, information on whether you will experience a total or a partial solar eclipse in your area, and the exact start time, peak time, and end time of the eclipse.", imageName: "Soundscapes-Eclipse Center")
        
        let fourthPage = Page(title: "Audio Descriptions", message: "When it is time for the next eclipse to start, you will receive a notification to open Eclipse Soundscapes. The app will then guide you through the main event with illustrative audio descriptions of an eclipse’s most important moments. These audio descriptions, provided by the National Center for Accessible Media, are explanations of photos developed with specialized language to help people who are blind and visually impaired engage with an eclipse. After each audio description ends, you will have the option to either hear more educational information or explore that feature of an eclipse using the Rumble Map. If VoiceOver is active during one of these audio descriptions and if the text that provided with the audio description is selected, the audio will stop playing and VoiceOver will begin to read the provided text. During a Realtime event, text that is provided with the audio descriptions will not be available to VoiceOver users.", imageName: "Soundscapes-AudioRecordings")
        
        return [firstPage, secondPage, thirdPage, fourthPage]
    }()
    
    /// Current Page in WalkThrough
    var currentPage = 0 {
        didSet {
            switch currentPage {
            case 0:
                pageLabel.textColor = .white
                previousButton.isHidden = true
                if isBegining {
                    skipButton.accessibilityLabel = "Skip to end of Walk Through"
                }
                break
            case 1:
                pageLabel.textColor = .black
                previousButton.isHidden = false
                nextButton.isHidden = false
                self.previousButton.tintColor = UIColor.init(r: 227, g: 94, b: 5)
                if isBegining {
                    skipButton.accessibilityLabel = "Skip to end of Walk Through"
                }
                break
                
            case 2:
                pageLabel.textColor = .black
                previousButton.isHidden = false
                nextButton.isHidden = false
                self.previousButton.tintColor = UIColor.init(r: 227, g: 94, b: 5)
                if isBegining {
                    skipButton.accessibilityLabel = "Skip to end of Walk Through"
                }
                break
            case 3:
                pageLabel.textColor = .black
                previousButton.isHidden = false
                self.previousButton.tintColor = UIColor.init(r: 227, g: 94, b: 5)
                if isBegining {
                    skipButton.accessibilityLabel = "Skip to end of Walk Through"
                } else {
                    nextButton.isHidden = true
                }
                break
            case 4:
                previousButton.isHidden = false
                self.previousButton.tintColor = .black
                if isBegining {
                    skipButton.accessibilityLabel = "Can not Skip Anymore"
                }
                break
            default:
                break
            }
            
            pageLabel.text = "Page \(currentPage+1) of \(isBegining ?  pages.count+1 : pages.count)"
            pageLabel.accessibilityLabel = "Walk Through Page \(currentPage+1) of \(isBegining ?  pages.count+1 : pages.count)"
        }
    }
    
    
    /// Sets the accessible elements for each page
    ///
    /// - Parameters:
    ///   - page: current page
    ///   - cell: page cell
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
        case 1:
            self.view.accessibilityElements = [previousButton, nextButton, skipButton, pageLabel]
            if let cellElements = pageCell?.accessibilityElements {
                view.accessibilityElements?.append(cellElements)
            }
            break
        case 2:
            self.view.accessibilityElements = [previousButton, nextButton,skipButton, pageLabel]
            if let cellElements = pageCell?.accessibilityElements {
                view.accessibilityElements?.append(cellElements)
            }
            break
        case 3:
            self.view.accessibilityElements = [previousButton, skipButton, pageLabel]
            if isBegining {
                view.accessibilityElements?.insert(nextButton, at: 1)
            }
            if let cellElements = pageCell?.accessibilityElements {
                view.accessibilityElements?.append(cellElements)
            }
            break
        case 4:
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
    
    
    /// Page # Tracker
    var pageLabel : UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 11)
        label.textAlignment = .right
        return label
    }()
    
    
    /// Skip WalkThrough Button
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.addTarget(self, action: #selector(skip), for: .touchUpInside)
        button.setTitleColor(UIColor.init(r: 227, g: 94, b: 5), for: .normal)
        button.accessibilityLabel = "Skip to end of Walk Through"
        return button
    }()
    
    
    /// Skips the WalkThrough
    func skip() {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.previousButton)
        currentPage = pages.count
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        moveControlConstraintsOffScreen()
        self.previousButton.tintColor = .black
        
    }
    
    
    /// Next Page Button
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Right_Arrow"), for: .normal)
        button.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        button.accessibilityLabel = "Next Page"
        button.accessibilityTraits |= UIAccessibilityTraitCausesPageTurn
        return button
    }()
    
    
    /// Previous Page Button
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
    
    
    /// Performs Paging to Next Page Cell
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
        if indexPath.section < collectionView.numberOfSections {
            if indexPath.row < collectionView.numberOfItems(inSection: indexPath.section) {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                currentPage += 1
            }
        }
    }
    
    /// Performs Paging to Previous Page Cell
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
        if indexPath.row >= 0 {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentPage -= 1
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ callback: ((UIViewController) -> ())? = nil) {
        super.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
        
        if UserDefaults.standard.bool(forKey: "WalkThrough"){
            changeViewForRegularUse()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityElements = [collectionView, nextButton, skipButton, pageLabel]
        
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        
        pageLabelbottomAnchor = pageLabel.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: view.frame.height/3 + 15 + 10, rightConstant: 4, widthConstant: 0, heightConstant: 10).first
        
        skipButtonRightAnchor = skipButton.anchor(nextButton.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 60, heightConstant: 0)[1]
        
        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
        
        previousButtonTopAnchor = previousButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first
        
        //use autolayout instead
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        registerCells()
        
        
        pageLabel.text = "Page 1 of \(isBegining ? pages.count+1 : pages.count)"
        pageLabel.accessibilityLabel = "Walk Through Page 1 of \(isBegining ? pages.count+1 : pages.count)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0))
        setAccessibleElements(for: currentPage, cell: cell)
    }
    
    
    /// Change the WalkThrough for use after the first use
    func changeViewForRegularUse() {
        isBegining = false
        skipButton.removeTarget(self, action: #selector(skip), for: .touchUpInside)
        skipButton.setTitle("Close", for: .normal)
        skipButton.accessibilityLabel = "Close Walk Through"
        skipButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    var pageControlRightConstant : CGFloat = 0
    var skipButtonRightConstant : CGFloat = 0
    var nextButtonTopConstant : CGFloat = 0
    var previousButtonTopConstant : CGFloat = 0
    
    
    /// Track the Current Page after a scroll drag is perfomed
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
    
    /// Track the Current Page after a scroll is perfomed from next/previous button press
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let scrollOffset = scrollView.contentOffset.x
        let pageNumber = Int(scrollOffset / view.frame.width)
        
        let cell = collectionView.cellForItem(at: IndexPath(item: pageNumber, section: 0))
        
        setAccessibleElements(for: pageNumber, cell: cell)
    }
    
    /// Moves the walkThrough control buttons and page label off screen
    fileprivate func moveControlConstraintsOffScreen() {
        
        skipButtonRightAnchor?.constant = 80
        nextButtonTopAnchor?.constant = -40
        pageLabelbottomAnchor?.constant = -10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// Moves the walkThrough control buttons and page label on screen
    fileprivate func moveControlConstraintsOnScreen() {
        
        skipButtonRightAnchor?.constant = -4
        nextButtonTopAnchor?.constant = 16
        previousButtonTopAnchor?.constant = 16
        pageLabelbottomAnchor?.constant = -(view.frame.height/3 + 15 + 10)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    /// Register collectionView cells for programmatic use
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PermissionCell.self, forCellWithReuseIdentifier: PermissionCellId)
    }
    
    //MARK: CollectionView datasource and delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isBegining ? pages.count + 1 : pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pages.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PermissionCellId, for: indexPath) as! PermissionCell
            cell.delegate = self
            cell.isAccessibilityElement = false
            cell.accessibilityElements = [cell.permissionView]
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
    
    ///Manages the change in orientation
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
    
    
    /// Closes the walkthrough
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
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
