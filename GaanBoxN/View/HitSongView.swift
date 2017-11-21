//
//  HitSongView.swift
//  GaanBoxN
//
//  Created by Machintos on 3/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit


class HitSongView: CommonTableViewCell {
    
    static var array_hitSongs : [HitSong]?
    static let shared = HitSongView()
    var isParsed = false
 
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HitSongCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset.left = 15
        collectionView.contentInset.right = 15
        lb_title.text = "Hit Songs"
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(seeAllHitsongs(_:)))
        gesture.numberOfTapsRequired = 1
        lb_seeAll.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)
        
        setup()
    }
    
    func updateInterface() {
        collectionView.reloadData()
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
                parseHitSongData()
            }
        }
    }
    
    func seeAllHitsongs(_ sender: UITapGestureRecognizer) {
        
        Home.whichView = "HitSong"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_see_all_view"), object: nil)
    }
    
    func parseHitSongData(){
        
        APIHandler.shared.parseAPIData(hitSongsAPIURL, dataType: "hitsong") { (responseData) in
    
            HitSongView.array_hitSongs = responseData as? [HitSong]
            self.collectionView.reloadData()
            self.isParsed = true
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HitSongCollectionViewCell: CommonCollectionViewCell {
    
    var hitSong : HitSong? {
        
        didSet {
            if let url = hitSong?.hitSongURL {
                iv_coverImage.af_setImage(withURL: URL(string: url)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            }
     
            if let sName = hitSong?.hitSongName  {
                lb_songName.text = sName
                lb_songName.backgroundColor = UIColor.clear
            }
            if let aName = hitSong?.artistName  {
                lb_singerName.text = aName
                lb_singerName.backgroundColor = UIColor.clear
            }
            /**
             - change the currently playing songs text color
             */
            if let songURL = AudioPlayerVC.nowPlayingItem?.songURL {
                
                if songURL == hitSong?.hitSongMp3 {
                    
                    lb_songName.textColor = UIColor.defaultTintColor
                }
                else {
                    lb_songName.textColor = UIColor.white
                }
            }
        }
    }

    let iv_coverImage : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.appBlack
        return iv
    }()
    
    let lb_songName : UILabel = {
        let label = UILabel()
        label.text = " "
        label.backgroundColor = UIColor.appBlack
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.titleColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let lb_singerName : UILabel = {
        let label = UILabel()
        label.text = " "
        label.backgroundColor = UIColor.appBlack
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {

        addSubview(iv_coverImage)
        addSubview(lb_songName)
        addSubview(lb_singerName)
        
        iv_coverImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        iv_coverImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        iv_coverImage.widthAnchor.constraint(equalToConstant: frame.height).isActive = true
        iv_coverImage.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        
        lb_songName.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -2).isActive = true
        lb_songName.leadingAnchor.constraint(equalTo: iv_coverImage.trailingAnchor, constant: 10).isActive = true
        lb_songName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        lb_singerName.topAnchor.constraint(equalTo: lb_songName.bottomAnchor, constant: 2).isActive = true
        lb_singerName.leadingAnchor.constraint(equalTo: lb_songName.leadingAnchor).isActive = true
        lb_singerName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}

extension HitSongView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HitSongCollectionViewCell
       cell.hitSong = HitSongView.array_hitSongs?[indexPath.item]
  
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !Reach.isInternet && HitSongView.array_hitSongs == nil{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AlertForNoInternet"), object: nil)
            return
        }
        
        if HitSongView.array_hitSongs != nil {
            /**
             - realod table to change the currently palying songs name
             */
            collectionView.reloadData()
            
            Home.whichView = "HitSong"
            AudioPlayerVC.songIndex = indexPath.row
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_player_view"), object: nil)
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (frame.width / 2) + 40, height:  (frame.height - 70) / 3 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
