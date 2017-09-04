//
//  PrivacyPolicyViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/15/17.
//  Copyright © 2017 Arlindo Goncalves. All rights reserved.
//

import UIKit
import Eureka

class PrivacyPolicyViewController: UIViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    var infoTextView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .left
        tv.font = UIFont.getDefautlFont(.meduium, size: 17)
        tv.isEditable = false
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10)
        tv.backgroundColor = UIColor(r: 249, g: 249, b: 249)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Privacy Policy"
        self.navigationItem.addSqeuuzeBackBtn(self, action: #selector(close), for: .touchUpInside)
        
        
        view.addSubview(infoTextView)
        self.infoTextView.anchorToTop(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        setText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setText() {
        let bullet1 = "\u{2022}Crashlytics:\n\tFor the capture and collection of anonymous crash logs to help us identify bugs in our software. The Crashlytics Privacy Policy can be found at \nhttp://try.crashlytics.com/terms/\n\n"
        let bullet2 = "\u{2022}Fabric SDK:\n\tProvides us with the ability to capture and collect anonymous crash logs through the Crashlytics service: \nhttps://fabric.io/terms\n\n"
        let bullet3 = "\u{2022}Apple Analytics:\n\t(If enabled by user) For the collection of anonymous analytical data to help us better understand how our customers and users use our Services. App analytics is covered under the Apple Privacy Policy: \nhttps://www.apple.com/privacy/\n\n"
        
        let policys = bullet1+bullet2+bullet3
        
        infoTextView.text = policys
    }
    
    
    func createParagraphAttribute() ->NSParagraphStyle {
        var paragraphStyle: NSMutableParagraphStyle
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 0, options: NSDictionary() as! [String : AnyObject])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 15
        
        return paragraphStyle
    }
    

    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
