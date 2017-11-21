//
//  SingerView.swift
//  GaanBoxN
//
//  Created by Machintos on 3/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class SingerView: CommonTableViewCell {
    
    static var array_singers : [Singer]?
    static var selectedSingerIndex = 0
    var isParsed = false
    static let shared = SingerView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        parseSingerData()
  
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SingerCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset.left = 7
        
        lb_title.text = "Artist"
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(seeAllSinger(_:)))
        gesture.numberOfTapsRequired = 1
        lb_seeAll.addGestureRecognizer(gesture)
        
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        
        let status = userInfo?["Status"] as! String
    
        switch status {
        case "Offline":
            break
        default:
            if !isParsed {
                parseSingerData()
            }
        }
    }
    
    func seeAllSinger(_ sender: UITapGestureRecognizer){
    
        Home.whichView = "Singer"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_see_all_view"), object: nil)
    }
    
    func parseSingerData(){
        
        APIHandler.shared.parseAPIData(singerAPIURL, dataType: "singer") { (responseData) in

            SingerView.array_singers = responseData as? [Singer]
            self.collectionView.reloadData()
            self.isParsed = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SingerCollectionViewCell: CommonCollectionViewCell {
    
    var singer : Singer?{
        
        didSet{
            if let url = singer?.singerImageURL {
                iv_coverImage.af_setImage(withURL: URL(string: (url))!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            }
            
            if let singerName = singer?.singerName {
                lb_albumName.text = singerName
                lb_albumName.backgroundColor = UIColor.clear
            }
        }
    }
    
    let iv_coverImage : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.appBlack
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let lb_albumName : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.appBlack
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.titleColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    override func setupViews() {

        addSubview(iv_coverImage)
        addSubview(lb_albumName)
        
        iv_coverImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iv_coverImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        iv_coverImage.widthAnchor.constraint(equalToConstant: frame.height - 16).isActive = true
        iv_coverImage.heightAnchor.constraint(equalToConstant: frame.height - 16).isActive = true
        
        lb_albumName.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2).isActive = true
        lb_albumName.leadingAnchor.constraint(equalTo: iv_coverImage.leadingAnchor, constant: 0).isActive = true
        lb_albumName.trailingAnchor.constraint(equalTo: iv_coverImage.trailingAnchor, constant: 0).isActive = true
        lb_albumName.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}

extension SingerView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SingerCollectionViewCell
        cell.singer = SingerView.array_singers?[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !Reach.isInternet && SingerView.array_singers == nil{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AlertForNoInternet"), object: nil)
            return
        }
        
        if SingerView.array_singers != nil {
            SingerView.selectedSingerIndex = indexPath.row
            Home.whichView = "Singer"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_detailed_view"), object: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height - 68, height:  frame.height - 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -14
    }
}
