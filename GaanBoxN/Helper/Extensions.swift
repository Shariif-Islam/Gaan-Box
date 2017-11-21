//
//  Extensions.swift
//  GaanBoxN
//
//  Created by AdBox on 4/5/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

extension UIButton {
    /**
     - Button zoominOut animation
     */
    func animationZoomInOut(){
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.5) {
                            self.transform = CGAffineTransform.identity
                        }
        })
        
    }
}

extension UIColor {
    
    static func titleColor() -> UIColor {
        return UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    static func subTitleColor() -> UIColor {
        return UIColor.init(red: 204/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    static var defaultTintColor: UIColor {
        
        get {
            return UIColor.init(red: 255/255, green: 57/255, blue: 0/255, alpha: 1)
        }
    }
    
    static var appBlack: UIColor {
        
        get {
            return UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        }
    }
    
    static var appBackground: UIColor {
        
        get {
            return UIColor.init(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        }
    }
}

extension UISearchBar {
    
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    
                    subSubView.backgroundColor = UIColor.red
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    break
                }
            }
        }
    }
}

extension UINavigationItem {
    
    func addSettingButtonOnRight(){
    
        //icon_noInternet
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named : "icon_noInternet")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.red
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = UIColor.clear
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.addTarget(self, action: #selector(gotSettingPage), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button)

        self.rightBarButtonItem = barButton
    }
    
    func removeNoInternetButton(){
        self.rightBarButtonItem = nil
    }
    
    func gotSettingPage(){
        GBAlert.shared.openSettingsPage()
    }
}
