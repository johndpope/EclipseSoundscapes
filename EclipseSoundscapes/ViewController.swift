//
//  ViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    deinit {
        Authenticator.auth()?.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let manager = ResourceManager.manager()
        manager?.loadCoreData()
        
        let recording = manager?.createRecording()
        
        recording?.latitude = -71.90242
        recording?.longitude = 80.9876354
        
        let locationString  = Locator.buildString(withLatitude: (recording?.latitude)!, longitude: (recording?.longitude)!)
        let locationKey : [String: String] = [(recording?.id)! : locationString]
        
        
        Authenticator.auth()?.login(withEmail: "devbyarlindo@gmail.com", password: "***REMOVED***", completion: { (user, error) in
            guard error == nil else {
                print("Error")
                return
            }
            Uploader.init().storeReference(reference: locationKey) { (error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "No Error")
                    return
                }
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

