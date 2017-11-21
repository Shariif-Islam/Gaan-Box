//
//  AllHitSongsVC.swift
//  GaanBoxN
//
//  Created by Machintos on 3/29/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class AllHitSongsVC: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var array_hitSongsList = [HitSong]()
    let cellID = "cellID"
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title
        self.title = "Hit Songs"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name:NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateInterface() {
        tableView.reloadData()
    }
}

extension AllHitSongsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UIScreen.main.bounds.height / 10
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_hitSongsList.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! SeeAllTableViewCell
 
        if let url = URL(string: array_hitSongsList[indexPath.row].hitSongURL) {
            
            cell.iv_coverImage.af_setImage(withURL: url, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
        }
        
        cell.lb_albumName.text = array_hitSongsList[indexPath.row].hitSongName
        cell.lb_numberOfSongs.text = array_hitSongsList[indexPath.row].artistName
        
        /**
         - change the currently playing songs text color
         */
        if let songURL = AudioPlayerVC.nowPlayingItem?.songURL {
            
            if songURL == array_hitSongsList[indexPath.row].hitSongMp3 {
                cell.lb_albumName.textColor = UIColor.defaultTintColor
            } else {
                cell.lb_albumName.textColor = UIColor.white
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
        
        for result in array_hitSongsList {
     
            let songName   = result.hitSongName
            let artistName = "Unknown"
            let songURL    = result.hitSongMp3
            let coverImageURL   = result.hitSongURL
            
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
        
        let hitSong = array_hitSongsList[indexPath.row]
        
        let songName   = hitSong.hitSongName
        let artistName = "Unknown"
        let songURL    = hitSong.hitSongMp3
        let coverImageURL   = hitSong.hitSongURL
        
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
