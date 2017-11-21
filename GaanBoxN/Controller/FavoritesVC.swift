//
//  FavoritesVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class FavoritesVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    static var array_favoriteAudioSong = [Song]()
    var segmentSelectedIndex = 0
    var cellID  = "cellID"

    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation title
        self.title = "Favorites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        /**
         - Update favorite list when add/remove item from favorite list
        */
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteList), name:NSNotification.Name(rawValue: "update_favorite_list"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteList), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)

        /**
         - Update favorite list when view Appear
         */
        updateFavoriteList()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: IB Action
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        /**
         - Segment select action. Default selection is audio
         */
        if sender.selectedSegmentIndex == 0 {
            segmentSelectedIndex = 0
            tableView.reloadData()
            
        } else {
            segmentSelectedIndex = 1
            tableView.reloadData()
        }
    }
    // MARK: Custom func
    func updateFavoriteList(){
        tableView.reloadData()
    }
}

extension FavoritesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesVC.array_favoriteAudioSong.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! FavoritesTableViewCell
        
        // Set audio cell cover image width height
        cell.cons_coverImageWidth.constant = (UIScreen.main.bounds.height / 10) - 3
        cell.cons_coverImageHeight.constant = (UIScreen.main.bounds.height / 10) - 3
        
        let array = FavoritesVC.array_favoriteAudioSong
        // Set audio cover image to imageview
        cell.iv_coverImage.af_setImage(withURL: URL(string: array[indexPath.row].coverImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
        // Set song and artist name
        let songName = array[indexPath.row].songName
        let singerName = array[indexPath.row].artistName
        // set unknown if song or artis name is not available
        cell.lb_songName.text = songName == "" ? "Unknown" : songName
        cell.lb_artistName.text = singerName == "" ? "Unknown" : singerName
        
        /**
         - change the currently playing songs text color
         */
        if let songsURL = AudioPlayerVC.nowPlayingItem?.songURL {
            
            if songsURL == array[indexPath.row].songURL {
                cell.lb_songName.textColor = UIColor.defaultTintColor
            } else {
                cell.lb_songName.textColor = UIColor.white
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Play song index
        AudioPlayerVC.songIndex = indexPath.row
        // Instantiate player view from storyboard
        let playerVC = storyboard?.instantiateViewController(withIdentifier: "playerVC") as! AudioPlayerVC
        playerVC.array_songList.removeAll()
        // Add observer for audio interruption
        playerVC.notificationForPlayInterruption()
        
        /**
         - realod table to change the currently palying songs name text color
         */
        tableView.reloadData()
        
        for result in FavoritesVC.array_favoriteAudioSong {
            
            let songName        = result.songName
            let artistName      = result.artistName
            let songURL         = result.songURL
            let coverImageURL   = result.coverImageURL
            
            let song = Song(songID :"",
                            albumID :"",
                            artistID :"",
                            songURL :songURL,
                            songName :songName,
                            coverImageURL :coverImageURL,
                            artistName :artistName,
                            singerInfo : [:])
            
            playerVC.array_songList.append(song)
        }
        
        // open player view as popupbar controller
        tabBarController?.presentPopupBar(withContentViewController: playerVC, animated: true, completion: nil)
        tabBarController?.popupBar.tintColor = UIColor.defaultTintColor
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
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") {
            action, index in
            
            self.isEditing = true
            Favorite.shared.removeAudio(fromFavoriteList: FavoritesVC.array_favoriteAudioSong[indexPath.row])

            self.tableView.reloadData()
        }
        
        remove.backgroundColor = UIColor.defaultTintColor
        return [remove]
    }
}
