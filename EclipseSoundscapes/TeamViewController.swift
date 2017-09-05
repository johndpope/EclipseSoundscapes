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
import Material

class TeamViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Our Team", titleColor: .black)
        view.backgroundColor = Color.NavBarColor
        view.maxHeaderHeight = 60
        view.isShrinkable = false
        return view
    }()
    
    lazy var backBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    var members : [TeamMember] = [
        TeamMember(name: "Dr. Henry Winter", jobTitle: "Principal Investigator", bio: "Dr. Henry 'Trae' Winter III, an astrophysicist at the Harvard-Smithsonian Center for Astrophysics (CfA), has worked on eight NASA missions observing the Sun. His primary research focus is improving computer simulations to explore energy is released in the Sun's atmosphere, the corona, and in other stars. Dr. Winter has designed video wall exhibits for the Cooper-Hewitt National Design Museum, the National Air and Space Museum, North Carolina State University’s Hunt Library, and the Harvard Art Museums’ Lightbox Gallery. In addition to Eclipse Soundscapes, his current project “The Tactile Sun” aims to engage the blind and visually disabled community with universally designed solar exhibits. Dr. Winter has spearheaded many efforts to engage the public in scientific discovery, including work with the Montana Space Grant Consortium's Space Public Outreach Team, the Yohkoh Public Outreach Project, and science education programs at the Salish-Kootenai Flathead Lake Reservation. Currently Dr. Winter is the Chairperson of the Astrolabe Advisory Board, Chairperson of the AAS Eclipse Task Force Education Committee, active member of the Education and Public Outreach Committee for the Solar Physics Division (SPD) of the AAS, Press Officer for the SPD, and Co-Director of the CfA's Solar REU Summer Intern Program sponsored by the National Science Foundation.", photo: #imageLiteral(resourceName: "Henry Winter")),
        TeamMember(name: "MaryKay Severino", jobTitle: "Project Manager", bio: "MaryKay Severino is originally from Somerville, Massachusetts, but only recently returned to the Boston area. After earning a business degree from Villanova University, she worked in South Carolina and California as a Program Manager and Marketing Consultant. Realizing she was ready for a change, she went on to earn her Master's degree in Education and worked in public school systems and universities in Italy, Taiwan, and South Korea. Living abroad, immersed in other cultures and navigating daily life with language and literacy barriers, gave MaryKay a strong understanding of the challenges faced by anyone who communicates differently. For this reason, the Eclipse Soundscapes project was a natural fit. She is excited to use her program management skills to promote, plan and execute a project which will bring the amazement and wonder of an eclipse to a more inclusive demographic.", photo: #imageLiteral(resourceName: "MaryKay Severino")),
        TeamMember(name: "Arlindo Goncalves", jobTitle: "iOS Developer", bio: "Arlindo Goncalves is an iOS developer from Brockton, Massachusetts, and a computer science student at the University of Massachusetts, Boston. He aspires to develop applications that help schools and other institution engage youth, making education a focus point in their lives. In his free time, Arlindo enjoys playing soccer and cooking for his family and friends.", photo: #imageLiteral(resourceName: "Arlindo")),
        TeamMember(name: "Miles Gordon", jobTitle: "Audio Engineer", bio: "Miles Gordon is an audio engineer and multi-media artist from New England. Between mixing and mastering tracks for his friends and his work on the Eclipse Soundscapes project, he also enjoys tinkering with machines and editing papers for a Chinese translation company. When he grows up, he wants to be a supporting character in a William Gibson novel. Miles got involved in the Eclipse Soundscapes Project after a mutual friend introduced him to Dr. Winter. Their shared enthusiasm for innovation in audio engineering led to a collaboration on Eclipse Soundscapes.", photo: #imageLiteral(resourceName: "Miles Gordon")),
        TeamMember(name: "Christina Migliore", jobTitle: "Image Analysis Intern", bio: "Originally from a small town in New Jersey, Christina is an undergraduate student studying physics and math at Northeastern University. She works on image and video analysis for the Eclipse Soundscapes project and numerically modeling solar flares at the Harvard-Smithsonian Center for Astrophysics. She became involved with Eclipse Soundscapes because she enjoys scientific outreach and is interested in conveying numerical information in new ways. Christina hopes to continue studying in the field of plasma physics as a graduate student.", photo: #imageLiteral(resourceName: "Christina Migliore")),
        TeamMember(name: "Kristin DiVona", jobTitle: "Graphic Designer", bio: "Kristin DiVona is the Visual Information Specialist for NASA's Chandra X-Ray Observatory. An award-winning designer and illustrator, she is responsible for the creation of printed materials, exhibits, and interactive educational tools that visually interpret concepts related to astrophysics and x-ray astronomy— connecting everyday life to science exploration and technology. (Yes, it's as cool as it sounds.) She is a graduate of Rhode Island School of Design. Kristin is waiting not-so-patiently for this amazing astronomical event, and is excited to work with the Eclipse Soundscapes team on this inclusive design project", photo: #imageLiteral(resourceName: "Kristin Divona")),
        TeamMember(name: "Kelsey Perrett", jobTitle: "Social Media Coordinator and Content Writer", bio: "Kelsey Perrett is a Massachusetts-based freelance writer, editor, web producer, and social media specialist. She enjoys writing about travel, health and fitness, and the environment. When she isn’t writing, she can be found outside exploring trails, at the gym/yoga studio, or attempting to conquer an ever-expanding reading list. Kelsey got involved in the Eclipse Soundscapes Project due to her interest in environmental reporting, and is thrilled to work with a talented group to make the wonders of space accessible to everyone.", photo: #imageLiteral(resourceName: "Kelsey Perrett")),
        TeamMember(name: "Dr. Wanda Diaz Merced", jobTitle: "Consultant", bio: "Development in South Africa. When Dr. Winter invited Wanda to join the Eclipse Soundscapes team as a blind person and an astrophysicist, she accepted, saying she hoped the project could bring an innovative experience to the blind and visually impaired, to people who are not visually oriented, and to people who have never experienced an eclipse.", photo: #imageLiteral(resourceName: "Wanda"))
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initializeForm()
    }
    
    func setupViews() {
        view.backgroundColor = headerView.backgroundColor
        view.addSubview(headerView)
        
        headerView.headerHeightConstraint = headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: headerView.maxHeaderHeight).last!
        
        headerView.addSubviews(backBtn)
        backBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        backBtn.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10).isActive = true
        
        tableView.anchorWithConstantsToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    private func initializeForm() {
        
        for member in members {
            addMember(member)
        }
        
        let section = form.allSections[0]
        section.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
        section.header?.height = {CGFloat.leastNormalMagnitude}
    }
    
    func addMember(_ member: TeamMember) {
        form
            +++ TeamMemberRow { row in
                row.value = member
                if let cell = row.cell {
                    cell.memberImageView.alpha = 0
                    cell.nameLabel.alpha = 0
                    cell.jobTitleLabel.alpha = 0
                    UIView.animate(withDuration: 2.0, animations: { [weak cell = cell] in
                        cell?.memberImageView.alpha = 1
                        cell?.nameLabel.alpha = 1
                        cell?.jobTitleLabel.alpha = 1
                    })
                    cell.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak cell = cell] in
                        cell?.layer.transform = CATransform3DIdentity
                    })
                }
            }
            <<< TextAreaRow(){
                $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 65)
                let cell = $0.cell
                cell?.layer.borderColor = UIColor.clear.cgColor
                cell?.textView.isEditable = false
                cell?.isUserInteractionEnabled = false
                
                cell?.textView.alpha = 0
                UIView.animate(withDuration: 2.0, animations: { [weak view = cell?.textView] in
                    view?.alpha = 1
                })
                cell?.textView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                UIView.animate(withDuration: 1.0, animations: { [weak view = cell?.textView] in
                    view?.layer.transform = CATransform3DIdentity
                })
                }.cellUpdate({ (cell, row) in
                    cell.textView.text = member.bio
                    cell.accessibilityLabel = cell.textView.text
                    cell.accessibilityTraits = UIAccessibilityTraitStaticText
                    cell.textView.isAccessibilityElement = false
                    cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                    
                })
        
        
        
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
