//
//  MoreVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {
    
    var cellID = "cellID"
    var miniPlayerStyle = "default"

    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.title = "More"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MoreVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MoreTableViewCell
        cell.iv_icon.image = UIImage(named: "icon_moreCat")?.withRenderingMode(.alwaysTemplate)
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.lb_title.text = "About"
        } else if indexPath.row == 1 {
            cell.lb_title.text = "Mini player style - \(miniPlayerStyle)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            performSegue(withIdentifier: "segue_aboutVC", sender: self)
            
        } else if indexPath.row == 1 {
            
            if miniPlayerStyle == "default" {
                tabBarController?.popupBar.barStyle = .compact
                miniPlayerStyle = "compact"
            } else {
                tabBarController?.popupBar.barStyle = .default
                miniPlayerStyle = "default"
            }
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
}
