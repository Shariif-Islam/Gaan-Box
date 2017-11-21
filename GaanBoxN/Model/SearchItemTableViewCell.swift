//
//  SearchVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import Foundation

class SearchItemTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
        
        setUp()
    }
    
    var item : SearchItem? {
        
        didSet{
            
            if let url = item?.imageURL {
                iv_coverImage.af_setImage(withURL: URL(string: (url))!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            }
            lb_title.text = item?.name
        }
    }
    
    let view_content : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let iv_coverImage : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pf")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    let lb_title : UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setUp() {
        
        view_content.addSubview(iv_coverImage)
        view_content.addSubview(lb_title)
        contentView.addSubview(view_content)
        
        view_content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        view_content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3).isActive = true
        view_content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3).isActive = true
        view_content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        iv_coverImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iv_coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        iv_coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        iv_coverImage.widthAnchor.constraint(equalTo: iv_coverImage.heightAnchor).isActive = true
        
        lb_title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        lb_title.leadingAnchor.constraint(equalTo: iv_coverImage.trailingAnchor, constant: 10).isActive = true
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
