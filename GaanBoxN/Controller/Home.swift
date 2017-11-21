//
//  Home.swift
//  GaanBoxN
//
//  Created by Machintos on 3/30/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import LNPopupController

class Home: UIViewController{
    
    @IBOutlet weak var tableview: UITableView!
    static var whichView = ""
 
    // MARK: Override func
    override func viewDidLoad() {
        
        // Initialize tableview cell
        tableview.register(SlideView.self, forCellReuseIdentifier: "slide_cell")
        tableview.register(HitSongView.self, forCellReuseIdentifier: "hit_songs_cell")
        tableview.register(AlbumView.self, forCellReuseIdentifier: "album_cell")
        tableview.register(SingerView.self, forCellReuseIdentifier: "singer_cell")
        
        // Set Title image on nav bar
        let titleImageView = UIImageView(image:#imageLiteral(resourceName: "title-logo"))
        self.navigationItem.titleView = titleImageView
    }

    override func viewWillAppear(_ animated: Bool) {
        /**
         - Notifications for Network rechability
         - Perform segue for detailed view, see all and playerview
         */
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
     
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueForDetailedView), name:NSNotification.Name(rawValue: "perform_segue_for_detailed_view"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueForSeeAllView), name:NSNotification.Name(rawValue: "perform_segue_for_see_all_view"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueForPlayerView), name:NSNotification.Name(rawValue: "perform_segue_for_player_view"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(showNoInternetAlert), name:NSNotification.Name(rawValue: "AlertForNoInternet"), object: nil)
        
        // Update internet status
        updateInternetStatus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Remove observe notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Show detailed album, singer info
        if segue.identifier == "segue_detailedView" {

            let controller = segue.destination as! DetailedView
            
            // Album detail
            if Home.whichView == "Album" {
                
                controller.array_album.removeAll()
                controller.selectedIndex = AlbumView.selectedAlbumIndex
                
                if let array = AlbumView.array_albums {
                    controller.array_album = array
                }
            }
            // Singer detail
            else if Home.whichView == "Singer" {
                
                controller.array_singer.removeAll()
                controller.selectedIndex = SingerView.selectedSingerIndex
                
                if let array = SingerView.array_singers {
                    controller.array_singer = array
                }
            }
        }
        // See all hit songs list
        else if segue.identifier == "segue_seeAllView" {
            
            let controller = segue.destination as! AllHitSongsVC
            controller.array_hitSongsList.removeAll()
            
            if let array = HitSongView.array_hitSongs {
                controller.array_hitSongsList = array
            }
        }
        // See all albums and singers in collectionview
        else if segue.identifier == "segue_collectionView" {
            
            let controller = segue.destination as! CollectionViewVC
            controller.array_seeAllList.removeAll()
            
            // All albums
            if Home.whichView == "Album" {
                if let array = AlbumView.array_albums {
                    controller.array_seeAllList = array
                    controller.navTitle = "All Album"
                }
            }
            // All singers
            else if Home.whichView == "Singer" {
                if let array = SingerView.array_singers {
                    controller.array_seeAllList = array
                    controller.navTitle = "All Artist"
                }
            }
        }
    }
    
    // MARK: Custom func
    /**
     - Show detailed view
     */
    func performSegueForDetailedView(){
        performSegue(withIdentifier: "segue_detailedView", sender: self)
    }
    /**
     - Show see all view
     */
    func performSegueForSeeAllView(){
        
        if Home.whichView == "Album" || Home.whichView == "Singer"  {
            performSegue(withIdentifier: "segue_collectionView", sender: self)
        } else {
            performSegue(withIdentifier: "segue_seeAllView", sender: self)
        }
    }
    /**
     - Show playerview
     */
    func performSegueForPlayerView(){
        
        // Initialize player view
        let playerVC = storyboard?.instantiateViewController(withIdentifier: "playerVC") as! AudioPlayerVC
        playerVC.array_songList.removeAll()
        playerVC.notificationForPlayInterruption()
        
        // play song by tap on slide image
        if Home.whichView == "slide" {
            
            // Get all slide songs from API
            for result in APIHandler.shared.slideSongList()
            {
                let songName = result.slideSongName
                let artistName = result.slideSongArtistName
                let songURL = result.slideSongMP3
                let coverImageURL = result.slideSongImage

                let playSong = Song(songID: "", albumID: "", artistID: "", songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: [:])
                
                playerVC.array_songList.append(playSong)
            }
        }
        // Otherwise play from all song list
        else {
        
            // Get all hit songs
            for result in HitSongView.array_hitSongs!
            {
                let songName = result.hitSongName
                let artistName = "Unknown"
                let songURL = result.hitSongMp3
                let coverImageURL = result.hitSongURL
    
                let playSong = Song(songID: "", albumID: "", artistID: "", songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: [:])
                
                playerVC.array_songList.append(playSong)
            }
        }
        // Open mini player
        tabBarController?.presentPopupBar(withContentViewController: playerVC, animated: true, completion: nil)
        tabBarController?.popupBar.tintColor = UIColor.defaultTintColor
        tabBarController?.popupInteractionStyle = .drag
        tabBarController?.popupContentView.popupCloseButtonStyle = .round
    }
    /**
     - Show no internet alert
     */
    func showNoInternetAlert() {
        
        let alert = GBAlert.shared.alertForGoToSettingPage(title: "Warning", message: "Turn on mobile data or use Wi-Fi to access GaanBox", otherButtonTitle: "OK")
        
        self.present(alert, animated: true, completion: nil)
    }
    /**
     - Functionality if interneter status changed
     */
    func networkStatusChanged(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo
        let status = userInfo?["Status"] as! String
        
        switch status {
        case "Offline":
            self.navigationItem.addSettingButtonOnRight()
        default:
            self.navigationItem.removeNoInternetButton()
        }
    }
    /**
     - Update internet status
     */
    func updateInternetStatus(){
        
        if Reach.isInternet {
            self.navigationItem.removeNoInternetButton()
        } else {
            self.navigationItem.addSettingButtonOnRight()
        }
    }
}

extension Home : UITableViewDelegate, UITableViewDataSource {

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 || indexPath.row == 1 {
            // height for slide and hit songs cell
            return  UIScreen.main.bounds.height / 3.5
            
        } else {
            // height for others cell
            return UIScreen.main.bounds.height / 3
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
     }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!
        
        if indexPath.row == 0 {
            if let slideCell = tableView.dequeueReusableCell(withIdentifier: "slide_cell") {
                cell = slideCell as! SlideView
            }
        } else if indexPath.row == 1{
            
            if let  hitSongCell = tableView.dequeueReusableCell(withIdentifier: "hit_songs_cell") {
                cell = hitSongCell as! HitSongView
                cell.backgroundColor = UIColor.clear
            }
        } else if indexPath.row == 2{
            
            if let  albumCell = tableView.dequeueReusableCell(withIdentifier: "album_cell") {
                
                cell = albumCell as! AlbumView
                cell.backgroundColor = UIColor.clear
            }
        } else if indexPath.row == 3{
            
            if let  artistCell = tableView.dequeueReusableCell(withIdentifier: "singer_cell") {
                
                cell = artistCell as! SingerView
                cell.backgroundColor = UIColor.clear
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}
