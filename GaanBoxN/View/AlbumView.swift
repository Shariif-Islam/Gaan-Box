//
//  AlbumView.swift
//  GaanBoxN
//
//  Created by Machintos on 3/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit


class AlbumView: CommonTableViewCell {
    
    static var array_albums : [Album]?
    static var selectedAlbumIndex = 0
    var isParsed = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
  
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset.left = 7
        collectionView.contentInset.right = 7
   
        lb_title.text = "Album"
        
        setup()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(seeAllAlbum(_:)))
        gesture.numberOfTapsRequired = 1
        lb_seeAll.addGestureRecognizer(gesture)
        
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
                parseAlbumData()
            }
        }
    }
    
    func seeAllAlbum(_ sender: UITapGestureRecognizer) {
        
        Home.whichView = "Album"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_see_all_view"), object: nil)
    }
    
    
    func parseAlbumData(){
        
        APIHandler.shared.parseAPIData(albumAPIURL, dataType: "album") { (responseData) in
    
            AlbumView.array_albums = responseData as? [Album]
            self.collectionView.reloadData()
            self.isParsed = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AlbumCollectionViewCell: CommonCollectionViewCell {
    
    var album : Album?{
        
        didSet{
            if let url = album?.albumCoverImageURL {
                iv_coverImage.af_setImage(withURL: URL(string: (url))!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            }
            
            if let albumName = album?.albumName {
                lb_albumName.text = albumName
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
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.titleColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = UIColor.appBlack
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

extension AlbumView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AlbumCollectionViewCell
        cell.album = AlbumView.array_albums?[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !Reach.isInternet && AlbumView.array_albums == nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AlertForNoInternet"), object: nil)
            return
        }
        if AlbumView.array_albums != nil  {
            AlbumView.selectedAlbumIndex = indexPath.row
            Home.whichView = "Album"
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
