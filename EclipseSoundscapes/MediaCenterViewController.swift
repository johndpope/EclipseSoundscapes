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

public class Media : NSObject {
    var name: String!
    var resourceName : String!
    var infoRecourceName : String!
    var audioUrl : URL?
    var image: UIImage?
    var mediaType : FileType?
    
    init(name: String, resourceName : String, infoRecourceName: String , mediaType: FileType? = nil, image: UIImage? = nil) {
        self.name = name
        self.resourceName = resourceName
        self.image = image
        self.mediaType = mediaType
        self.infoRecourceName = infoRecourceName
    }
    
    func getInfo() -> String {
        return Utility.getFile(infoRecourceName, type: "txt") ?? "No Info Provided"
    }
    
}

class MediaCenterViewController : UIViewController {
    
    let cellId = "cellId"
    
    
    var mediaContainer : [Media]?
    
    var fillerView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.eclipseOrange
        return view
    }()
    
    var headerView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.eclipseOrange
        return view
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.bold, size: 20)
        label.text = "Media"
        label.accessibilityTraits = UIAccessibilityTraitHeader
        return label
    }()
    
    
    lazy var tableView : UITableView = {
        var tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorInset = .zero
        tv.tableFooterView = UIView()
        return tv
    }()
    
    var comingSoonLabel : UILabel = {
        var label = UILabel()
        label.text = "More content coming soon..."
        label.font = UIFont.getDefautlFont(.bold, size: 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        loadDataSource()
        setupView()
        comingSoonLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
        tableView.tableFooterView = comingSoonLabel
    }
    
    func registerCell() {
        self.tableView.register(MediaCell.self, forCellReuseIdentifier: cellId)
    }
    
    
    func setupView() {
        
        self.view.addSubview(fillerView)
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        fillerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: headerView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: 60)
        
        headerView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        tableView.anchorWithConstantsToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func loadDataSource() {
        self.mediaContainer = [
            Media.init(name: "Helmet Streamers", resourceName: "helmetstrmrs", infoRecourceName: "Helmet Streamers" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Helmet Streamers"))]
        
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
        let playbackVc = PlaybackViewController()
        playbackVc.media = mediaContainer?[indexPath.row]
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
}
