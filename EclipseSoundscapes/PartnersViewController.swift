//
//  PartnersViewController.swift
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

import Eureka

struct Partner {
    var name: String
    var website: String
    var bio : String
    var photo: UIImage?
    
    init(name: String, website: String, bio: String, photo: UIImage?) {
        self.name = name
        self.website = website
        self.bio = bio
        self.photo = photo
    }
}

class PartnersViewController : FormViewController {
    
    
    var members : [Partner] = [
        Partner(name: "NASA (National Aeronautics and Space Administration)", website: "https://www.nasa.gov/", bio: "NASA is an independent agency of the United States federal government which conducts the civilian space program, aeronautics, and aerospace research. NASA is leading an educational outreach effort surrounding the August 2017 Eclipse which includes information and live coverage of the event. NASA is partnering with Eclipse Soundscapes to provide the script calculating the timing of the eclipse, as well as the funding that makes Eclipse Soundscapes possible.", photo: #imageLiteral(resourceName: "NASA")),
        
        Partner(name: "National Park Service", website: "https://www.nps.gov/", bio: "The National Parks Service (an agency of the United States Department of the Interior) manages national parks, monuments, conservation, and historical sites throughout the United States. The NPS is partnering with Eclipse Soundscapes during the August 2017 Eclipse to collect mono and binaural field recordings in parks across the country, especially those in the path of totality. They will collect data the day before, the day of, and the day after the eclipse in order to study how wildlife sounds fluctuate with the changes in light caused by the eclipse.", photo: #imageLiteral(resourceName: "National_Parkers_logo")),
        
        Partner(name: "Eclipse Mob", website: "http://eclipsemob.org", bio: "Eclipse Mob is a crowdsourced effort to conduct the largest-ever low-frequency radio wave propagation experiment during the 2017 solar eclipse. They are using radio signals to study the effect of sunlight on the ionosphere. Through crowdsourcing, Eclipse Mob will collect radio wave signals at locations across the United States, allowing them to study how the signals are affected as they travel along various paths. Eclipse Mob is partnering with Eclipse Soundscapes to provide radio wave data (a form of audio data) for the Eclipse Soundscapes database.", photo: #imageLiteral(resourceName: "eclipsemob_textlogo_large_reverse")),
        
        Partner(name: "Smithsonian Institution", website: "https://www.si.edu/", bio: "The Smithsonian Institution is a group of museums and research centers established and administered by the United States government. Among the Smithsonian’s many facilities are the National Air and Space Museum and the Harvard-Smithsonian Center for Astrophysics, where Eclipse Soundscapes is based. The Smithsonian is partnering with Eclipse Soundscapes to provide a headquarters and funding for the Eclipse Soundscapes project.", photo: #imageLiteral(resourceName: "Smithsonian_logo")),
        
        Partner(name: "National Center for Accessible Media, WGBH", website: "http://ncam.wgbh.org/", bio: "The Carl and Ruth Shapiro Family National Center for Accessible Media (NCAM) is a non-profit branch of WGBH radio in Boston which is dedicated to achieving media access equality for people with disabilities. NCAM is partnering with Eclipse Soundscapes to provide media coverage of the eclipse, including illustrated audio descriptions of the eclipse which will allow visually impaired individuals to experience the eclipse through real-time audio narrations.", photo: #imageLiteral(resourceName: "ncam_logo")),
        
        Partner(name: "Science Friday", website: "https://www.sciencefriday.com/", bio: "The Science Friday Initiative is a non-profit organization dedicated to increasing the public’s access to science and scientific information. They host a radio show distributed by Public Radio International (PRI) and produce science and technology related digital videos, original web articles, and educational resources for educators. Science Friday is partnering with Eclipse Soundscapes to provide audio recordings and social media support.", photo: #imageLiteral(resourceName: "logo-scifri")),
        
        Partner(name: "National Girls Collaborative", website: "https://ngcproject.org/", bio: "The National Girls Collaborative Project (NGC) brings together United States organizations that are committed to informing and encouraging girls to pursue careers in science, technology, engineering, and mathematics. NGC is partnering with Eclipse Soundscapes to organize listening parties where young women can experience the total solar eclipse complete with audio information.", photo: #imageLiteral(resourceName: "ngcp_theme_logo")),
        
        Partner(name: "Citizen CATE", website: "http://eclipse2017.nso.edu/citizen-cate/", bio: "The Citizen CATE (Continental-America Telescopic Eclipse) Experiment is an effort to document the 2017 Eclipse by capturing images of the inner solar corona using a network of more than 60 telescopes. CATE is working with high schools, universities, education groups, astronomy clubs, national science research labs, and corporate sponsors to produce 90 minutes of continuous, high-resolution, and rapid-cadence images detailing the Sun’s inner corona...More TBD", photo: #imageLiteral(resourceName: "nso_logo_200_a")),
        
        Partner(name: "Brigham Young University, Idaho", website: "http://www.byui.edu/eclipse-2017", bio: "Brigham Young University (BYU) is a private research university with three locations, including Rexburg, Idaho. They are partnering with Eclipse Soundscapes to provide a series of field recordings of the 2017 Eclipse, including audio of an active beehive. Because Rexburg lies in the path of totality, BYU is hosting a number of viewing and educational events with the City of Rexburg.", photo: #imageLiteral(resourceName: "byu"))
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Our Partners"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
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
                        view.jobTitleLabel.text = member.website
                        view.jobTitleLabel.textColor = UIColor(r: 0, g: 122, b: 184)
                        let gesture = WebtouchGesture(target: self, action: #selector(self.openWebsite(gesture:)))
                        gesture.website = member.website
                        view.jobTitleLabel.addGestureRecognizer(gesture)
                        
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
    
    func openWebsite(gesture : WebtouchGesture) {
        guard let wesite = gesture.website, let url = URL.init(string: wesite) else {
            return
        }
        let alert = UIAlertController(title: "Open in Safari", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sure", style: .destructive, handler: { _ in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

class WebtouchGesture : UITapGestureRecognizer {
    var website : String?
}

