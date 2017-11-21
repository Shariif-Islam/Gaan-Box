//
//  SearchVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import Foundation

class RecentSearchItemTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
        
        setUp()
    }
    
    var view_content : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var lb_title : UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setUp() {
        
        view_content.addSubview(lb_title)
        contentView.addSubview(view_content)
        
        view_content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        view_content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3).isActive = true
        view_content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3).isActive = true
        view_content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        lb_title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        lb_title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
