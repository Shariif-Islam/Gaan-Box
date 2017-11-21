//
//  GBAlert.swift
//  GaanBoxN
//
//  Created by AdBox on 6/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class GBAlert {
    
    static let shared = GBAlert()
    
    func alertForGoToSettingPage(title: String, message: String, otherButtonTitle: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let setting = UIAlertAction(title: "Settings", style: .default) { (action) in
            self.openSettingsPage()
        }
        
        let ok = UIAlertAction(title: otherButtonTitle , style: .default) { (action) in}
        
        alert.addAction(setting)
        alert.addAction(ok)
        
        return alert
    }
    
    func openSettingsPage() {
        
        guard let settingsUrl = URL(string: "App-Prefs:root=")
            else {
                return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
}
