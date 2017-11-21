//
//  DetailedVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class DetailedView : UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var view_top: UIView!
    @IBOutlet weak var iv_background: UIImageView!
    @IBOutlet weak var iv_posterImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view_loadingTableData: UIView!
    @IBOutlet weak var indicator_loading: UIActivityIndicatorView!
    @IBOutlet weak var cons_topView: NSLayoutConstraint!
    
    var array_detailed          = [DetailedInfo]()
    var array_album             = [Album]()
    var array_singer            = [Singer]()
    var selectedIndex = 0
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        initializeDetailedData()
        
        // Enable swipe gesture recognizer
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(getSwipeAction(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(getSwipeAction(_:)))
        swipeRight.direction = .right
        view_top.addGestureRecognizer(swipeLeft)
        view_top.addGestureRecognizer(swipeRight)

    }
  
    override func viewDidLayoutSubviews() {
        cons_topView.constant = self.view.frame.height / 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
  
        self.updateInternetStatus()
        
        // Notification for network rechability and update interface
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Remove observer
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)
    }
    
    // MARK: Custom func
    func updateInterface() {
        tableView.reloadData()
    }
    
    /**
     - Get swipe direction
     */
    func getSwipeAction( _ recognizer : UISwipeGestureRecognizer){
        
        if recognizer.direction == .left {
           nextItem() 
        } else {
            previousItem()
        }  
    }
    /**
     - Swipe next
     */
    func nextItem(){
        
        let array = detailedArray()
  
        if selectedIndex + 1 >= array.count {
            Animation.shared.animateNoNextTrackBounce(iv_posterImage.layer)
            return
        }

        if selectedIndex + 1 < array.count {
            selectedIndex += 1
            array_detailed.removeAll()
            tableView.reloadData()
            initializeDetailedData()
            self.updateInternetStatus()
        }
        Animation.shared.animateContentChange(kCATransitionFromRight, layer: iv_posterImage.layer)
    }
    /**
     - Get detailed array
     */
    func detailedArray() -> Array<Any> {
    
        if Home.whichView == "Album" || Home.whichView == "Category" {
            return array_album
        } else {
            return array_singer
        }
    }
    /**
     - Swipe previous item
     */
    func previousItem() {
        
        let array = detailedArray()

        if selectedIndex - 1 < 0 {
            Animation.shared.animateNoPreviousTrackBounce(iv_posterImage.layer)
            return
        }
        if(selectedIndex - 1 >= 0 && selectedIndex < array.count) {
            selectedIndex -= 1
            array_detailed.removeAll()
            tableView.reloadData()
            initializeDetailedData()
            self.updateInternetStatus()
        }
        Animation.shared.animateContentChange(kCATransitionFromLeft, layer: iv_posterImage.layer)
    }
    /**
     - Initialize detailed info
     */
    func initializeDetailedData() {
        
        if Home.whichView == "Album" || Home.whichView == "Category" {
            
            setBackgroundImage(url: URL(string: array_album[selectedIndex].albumCoverImageURL)!)
            self.title = array_album[selectedIndex].albumName
            iv_posterImage.af_setImage(withURL: URL(string: array_album[selectedIndex].albumCoverImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            
            self.albumDetailedInfo()
            
        } else if Home.whichView == "Singer" {
            
            setBackgroundImage(url: URL(string: array_singer[selectedIndex].singerImageURL)!)
            self.title = array_singer[selectedIndex].singerName
            iv_posterImage.af_setImage(withURL: URL(string: array_singer[selectedIndex].singerImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            
            self.artistDetailedInfo()
        }
    }
    /**
     - Album detail info
     */
    func albumDetailedInfo(){
  
        let albumAPIURL = (albumSongAPIURL+String(array_album[selectedIndex].albumID))
        
        view_loadingTableData.isHidden = false
        indicator_loading.startAnimating()
        
        APIHandler.shared.parseAPIData(albumAPIURL, dataType: "albumSong") { (responseData) in
            
            print("😀😀😀 Parsing Album song Data from API is Successfull 😀😀😀")
            
            self.indicator_loading.stopAnimating()
            self.view_loadingTableData.isHidden = true
            
            self.array_detailed.removeAll()
            let array_albumSongList = responseData as! [Song]
            
            if array_albumSongList.isEmpty {
                
                Animation.shared.animateTable(tableView: self.tableView)
                return
            }
            
            for albumSong in array_albumSongList {
                
                let detailed = DetailedInfo()
                
                detailed.songName = albumSong.songName
                detailed.coverImageURL = self.array_album[self.selectedIndex].albumCoverImageURL
                detailed.songURL = albumSong.songURL
                detailed.albumOrSingerName = self.array_album[self.selectedIndex].albumName
                
                let dic_singer = albumSong.singerInfo
                detailed.singerName = dic_singer["name"] as! String
                
                self.array_detailed.append(detailed)
                self.tableView.reloadData()
                Animation.shared.animateTable(tableView: self.tableView)
            }
        }
    }
    /**
     - Artist detailed info
     */
    func artistDetailedInfo(){
        
        let singerAPIURL = (singerSongAPIURL+String(array_singer[selectedIndex].singerID))
        
        view_loadingTableData.isHidden = false
        indicator_loading.startAnimating()
        
        APIHandler.shared.parseAPIData(singerAPIURL, dataType: "singerSong") { (responseData) in
            
            print("😀😀😀 Parsing singer song Data from API is Successfull 😀😀😀")
            
            self.indicator_loading.stopAnimating()
            self.view_loadingTableData.isHidden = true
     
            self.array_detailed.removeAll()
            let array_singerSongList = responseData as! [Song]
            
            for singerSong in array_singerSongList
            {
                let detailed = DetailedInfo()
                
                detailed.songName = singerSong.songName
                detailed.coverImageURL = self.array_singer[self.selectedIndex].singerImageURL
                detailed.songURL = singerSong.songURL
                detailed.albumOrSingerName = self.array_singer[self.selectedIndex].singerName
                detailed.singerName = self.array_singer[self.selectedIndex].singerName
                
                self.array_detailed.append(detailed)
                self.tableView.reloadData()
                Animation.shared.animateTable(tableView: self.tableView)
            }
        }
    }
    /**
     - Set detail view background image
     */
    func setBackgroundImage(url: URL) {
        iv_background.af_setImage(withURL: url, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
    }
    
    /* +++++++++++++++++++++++++++++++++++
     *        Network Reachability
     * +++++++++++++++++++++++++++++++++++
     */
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        
        let status = userInfo?["Status"] as! String
    
        switch status {
        case "Offline":
            break
        default:
            if array_detailed.isEmpty{
                if Home.whichView == "Album" || Home.whichView == "Category"{
                    
                    self.albumDetailedInfo()
                }
                else if Home.whichView == "Singer"{
                    self.artistDetailedInfo()
                }
            }
        }
    }
    /**
     - Update internet status
     */
    func updateInternetStatus(){
        
        if !Reach.isInternet && array_detailed.isEmpty {
            let alert =   GBAlert.shared.alertForGoToSettingPage(title: "Warring", message: "You must connect to Wi-Fi or mobile data to access GaanBox", otherButtonTitle: "OK")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DetailedView : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 12;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_detailed.count  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailed_table_view_cell", for: indexPath) as! DetailedTableViewCell

        cell.lb_serialNo.text = String(describing: indexPath.row + 1)
        cell.lb_songName?.text = array_detailed[indexPath.row].songName
        cell.btn_playSong.isHidden = true
        
        /**
         - change the currently playing songs text color
         */
        if let songURL = AudioPlayerVC.nowPlayingItem?.songURL {
        
            if songURL == array_detailed[indexPath.row].songURL {
                
                cell.lb_songName.textColor = UIColor.defaultTintColor
            }
            else {
                cell.lb_songName.textColor = UIColor.white
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayerVC.songIndex = indexPath.row
   
        let playerVC = storyboard?.instantiateViewController(withIdentifier: "playerVC") as! AudioPlayerVC
        playerVC.array_songList.removeAll()
        playerVC.notificationForPlayInterruption()
        
        /** 
         - realod table to change the currently palying songs name
         */
        tableView.reloadData()
   
        for result in array_detailed {
            
            let songName   = result.songName
            let artistName = result.singerName
            let songURL    = result.songURL
            let coverImageURL   = result.coverImageURL
            
            let playSong = Song(songID: "", albumID: "", artistID: "", songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: [:])
            
            playerVC.array_songList.append(playSong)
        }
        tabBarController?.presentPopupBar(withContentViewController: playerVC, animated: true, completion: nil)
        tabBarController?.popupBar.tintColor = UIColor.defaultTintColor
        tabBarController?.popupInteractionStyle = .drag
        tabBarController?.popupContentView.popupCloseButtonStyle = .round
    }
    
    //Enable cell editing methods.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let detailed = array_detailed[indexPath.row]
        
        let songName        = detailed.songName
        let artistName      = detailed.singerName
        let songURL         = detailed.songURL
        let coverImageURL   = detailed.coverImageURL
        
        let song = Song(songID: "", albumID: "", artistID: "", songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: [:])
        
        let add = UITableViewRowAction(style: .normal, title: " Like ") { action, index in
            self.isEditing = false
            
            Favorite.shared.addAudio(toFavorite: song)
            self.tableView.reloadRows(at: [indexPath], with: .middle)
        }
        add.backgroundColor = UIColor.defaultTintColor
        
        let remove = UITableViewRowAction(style: .normal, title: "Unlike") { action, index in
            self.isEditing = false
            
            Favorite.shared.removeAudio(fromFavoriteList: song)
            self.tableView.reloadRows(at: [indexPath], with: .middle)
        }
        remove.backgroundColor = UIColor.defaultTintColor
        
        if Favorite.shared.isFavoriteAudioSong(url: songURL){
            return [remove]
        }
        return [add]
    }
}
