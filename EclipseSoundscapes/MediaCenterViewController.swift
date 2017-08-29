//
//  MediaCenterViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/3/17.
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
import Material

class MediaCenterViewController : UIViewController {
    
    let cellId = "cellId"
    
    
    var mediaContainer : [Media]?
    
    var fillerView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.eclipseOrange
        return view
    }()
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Media")
        view.backgroundColor = Color.eclipseOrange
        view.delegate = self
        return view
    }()
    
    lazy var tableView : UITableView = {
        var tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorInset = .zero
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        loadDataSource()
        setupView()
        
        NotificationHelper.addObserver(self, reminders: [.allDone,.totality,.contact1], selector: #selector(catchReminderNotification(notification:)))
        
    }
    
    func registerCell() {
        self.tableView.register(MediaCell.self, forCellReuseIdentifier: cellId)
    }
    
    
    
    func setupView() {
        
        self.view.addSubview(fillerView)
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        
        fillerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: headerView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        headerView.headerHeightConstraint = headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: headerView.maxHeaderHeight).last!
        
        tableView.anchorWithConstantsToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        
        let parallavView = ParallaxView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        parallavView.backgroundColor = headerView.backgroundColor
        self.tableView.tableHeaderView  = parallavView
    }
    
    
    
    func catchReminderNotification(notification: Notification) {
        guard let reminder = notification.userInfo?["Reminder"] as? Reminder else {
            return
        }
        reloadMedia(for: reminder)
        
    }
    
    func reloadMedia(for reminder: Reminder) {
        if reminder.contains(.allDone) || reminder.contains(.totality) {
            
            let totality = Media.init(name: "Totality", resourceName: "Totality_full", infoRecourceName: "Totality", mediaType: .mp3, image: #imageLiteral(resourceName: "Totality"))
            
            let sunAsAStar = Media.init(name: "Sun as a Star", resourceName: "Sun_as_a_Star_full", infoRecourceName: "Sun as a Star", mediaType: .mp3, image: #imageLiteral(resourceName: "Sun as a Star"))
            
            let totalityExperience = RealtimeEvent(name: "Totality Experience", resourceName: "Realtime_Eclipse_Shorts", mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Totality"), media:
                RealtimeMedia(name: "Baily's Beads", infoRecourceName: "Baily's Beads-Short", image: #imageLiteral(resourceName: "Baily's Beads"), startTime: 0, endTime: 24),
                                                   RealtimeMedia(name: "Totality", infoRecourceName: "Totality-Short", image: #imageLiteral(resourceName: "Totality"), startTime: 120, endTime: 145),
                                                   RealtimeMedia(name: "Diamond Ring", infoRecourceName: "Diamond Ring-Short", image: #imageLiteral(resourceName: "Diamond Ring"), startTime: 200, endTime: 213),
                                                   RealtimeMedia(name: "Sun as a Star", infoRecourceName: "Sun as a Star", image: #imageLiteral(resourceName: "Sun as a Star"), startTime: 320, endTime: 355))
            
            if !(mediaContainer?.contains(where: { (media) -> Bool in
                return media.name == totality.name
            }))! {
                mediaContainer?.append(totality)
            }
            if !(mediaContainer?.contains(where: { (media) -> Bool in
                return media.name == sunAsAStar.name
            }))! {
                mediaContainer?.append(sunAsAStar)
            }
            if !(mediaContainer?.contains(where: { (media) -> Bool in
                return media.name == totalityExperience.name
            }))! {
                mediaContainer?.append(totalityExperience)
            }
            
        } else if reminder.contains(.contact1) {
            self.mediaContainer?.insert(Media.init(name: "First Contact", resourceName: "First_Contact_full_with_date", infoRecourceName: "First Contact", mediaType: .mp3, image: #imageLiteral(resourceName: "First Contact")), at: 0)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    func loadDataSource() {
        self.mediaContainer = [
            Media.init(name: "Baily's Beads", resourceName: "Bailys_Beads_full", infoRecourceName: "Baily's Beads" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Baily's Beads")),
            Media.init(name: "Prominence", resourceName: "Prominence_full", infoRecourceName: "Prominence" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Prominence")),
            Media.init(name: "Corona", resourceName: "Corona_full", infoRecourceName: "Corona" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Corona")),
            Media.init(name: "Helmet Streamers", resourceName: "Helmet_Streamers_full", infoRecourceName: "Helmet Streamers" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Helmet Streamers")),
            Media.init(name: "Diamond Ring", resourceName: "Diamond_Ring_full", infoRecourceName: "Diamond Ring" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Diamond Ring")),
        ]
        
        if UserDefaults.standard.bool(forKey: "Contact1Done") {
            reloadMedia(for: .contact1)
        }
        
        if UserDefaults.standard.bool(forKey: "TotalityDone") {
            reloadMedia(for: .totality)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MediaCenterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let media = mediaContainer?[indexPath.row] else {
            return
        }
        
        let playbackVc = PlaybackViewController()
        
        playbackVc.media = media
        
        //        if media is RealtimeEvent {
        //            playbackVc.isRealtimeEvent = true
        //        }
        
        self.present(playbackVc, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaContainer?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MediaCell
        cell.media = mediaContainer?[indexPath.row]
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableViewheaderView = self.tableView.tableHeaderView as! ParallaxView
        tableViewheaderView.scrollViewDidScroll(scrollView: scrollView)
        headerView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerView.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        headerView.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

extension MediaCenterViewController : ShrinkableHeaderViewDelegate {
    func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
}


