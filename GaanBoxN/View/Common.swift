//
//  CommonClass.swift
//  GaanBoxN
//
//  Created by Machintos on 3/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class CommonCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
    }
}


class CommonTableViewCell: UITableViewCell {

    let cellID = "cellID"
    
    let view_separator : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    let lb_title : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Chalkboard SE", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        return label
    }()
    
    let lb_seeAll : UILabel = {
        let label = UILabel()
        label.text = "  See All  "
        label.textColor = UIColor.white
        label.font = UIFont(name: "Chalkboard SE", size: 10)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 3
        return label
    }()
    
    func setup(){

        addSubview(lb_title)
        addSubview(lb_seeAll)
        addSubview(collectionView)
        addSubview(view_separator)
        
        lb_title.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        lb_title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        lb_title.heightAnchor.constraint(equalToConstant: 15)
        
        lb_seeAll.bottomAnchor.constraint(equalTo: lb_title.bottomAnchor).isActive = true
        lb_seeAll.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        lb_seeAll.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: lb_title.bottomAnchor, constant: 10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view_separator.topAnchor, constant: -15).isActive = true
        
        view_separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        view_separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        view_separator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view_separator.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
    }
}
