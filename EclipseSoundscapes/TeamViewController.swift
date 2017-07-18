//
//  TeamViewController.swift
//  
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

import Eureka

struct TeamMember {
    var name: String
    var jobTitle: String
    var bio : String
    var photo: UIImage?
    
    init(name: String, jobTitle: String, bio: String, photo: UIImage?) {
        self.name = name
        self.jobTitle = jobTitle
        self.bio = bio
        self.photo = photo
    }
}

class TeamViewController : FormViewController {
    
    
    var members : [TeamMember] = [
        TeamMember(name: "Arlindo Goncalves", jobTitle: "iOS Developer", bio: "Arlindo is an iOS developer from Brockton, Ma and also a Computer Science student at UMass Boston. He has aspirations to develop applications that help schools or any other institution engage the youth and make education a focus point in their lives. Besides  that, Arlindo spends his time playing soccer and cooking for his family and friends.", photo: #imageLiteral(resourceName: "Arlindo")),
        TeamMember(name: "Miles Gordon", jobTitle: "Audio Engineer", bio: "Miles is an audio engineer and multi-media artist from New England. Between mixing and mastering tracks for his friends, and his work on the Eclipse Soundscapes project, he also enjoys tinkering with machines and editing papers for a Chinese translation company. When he grows up, he wants to be a supporting character in a William Gibson novel.", photo: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Our Team"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
    }
    
    private func initializeForm() {
            
        for member in members {
            form
                +++ Section() {
                    var header = HeaderFooterView<BioView>(.nibFile(name: "BioView", bundle: nil))
                    header.onSetupView = { (view, section) -> () in
                        if let photo = member.photo {
                            view.imageView.image = photo
                        }
                        view.nameLabel.text = member.name
                        view.jobTitleLabel.text = member.jobTitle
                        
                        view.imageView.alpha = 0
                        view.nameLabel.alpha = 0
                        view.jobTitleLabel.alpha = 0
                        UIView.animate(withDuration: 2.0, animations: { [weak view] in
                            view?.imageView.alpha = 1
                            view?.nameLabel.alpha = 1
                            view?.jobTitleLabel.alpha = 1
                        })
                        view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view] in
                            view?.layer.transform = CATransform3DIdentity
                        })
                    }
                    $0.header = header
                    
                }
                <<< TextAreaRow(){
                    $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 65)
                    $0.cell.layer.borderColor = UIColor.clear.cgColor
                    $0.cell.textView.isEditable = false
                    $0.cell.isUserInteractionEnabled = false
                    }.cellUpdate({ (cell, row) in
                        cell.textView.text = member.bio
                        cell.accessibilityLabel = cell.textView.text
                        cell.accessibilityTraits = UIAccessibilityTraitStaticText
                        cell.textView.isAccessibilityElement = false
                        cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                        
                        cell.textView.alpha = 0
                        UIView.animate(withDuration: 2.0, animations: { [weak view = cell.textView] in
                            view?.alpha = 1
                        })
                        cell.textView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                        UIView.animate(withDuration: 1.0, animations: { [weak view = cell.textView] in
                            view?.layer.transform = CATransform3DIdentity
                        })
                    })

        }

        
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
