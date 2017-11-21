//
//  FavoritesVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import Foundation

class Favorite {
    
    // singleton shared instance
    static let shared = Favorite()
    
    /**
     - Add audio to favorite list
     */
    func addAudio(toFavorite song :Song) {
        
        FavoritesVC.array_favoriteAudioSong.insert(song, at: 0)
        updateFavoriteAudioList()
    }
    /**
     - Remove audio from favorite list
     */
    func removeAudio(fromFavoriteList song : Song) {
        
        for (index, value) in FavoritesVC.array_favoriteAudioSong.enumerated() {
            
            if value.songURL == song.songURL {
                FavoritesVC.array_favoriteAudioSong.remove(at: index)
                updateFavoriteAudioList()
            }
        }
    }
    /**
     - Check is favorite song
     */
    func isFavoriteAudioSong(url : String) -> Bool {
        
        for fSong in FavoritesVC.array_favoriteAudioSong {
            
            if fSong.songURL == url {
                return true
            }
        }
        return false
    }
    /**
     - Update archived list
     */
    func updateFavoriteAudioList(){
        
        let arraydata = NSKeyedArchiver.archivedData(withRootObject: FavoritesVC.array_favoriteAudioSong)
        UserDefaults.standard.set(arraydata, forKey: "ARRAY_FAVORITE_AUDIO")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_favorite_list"), object: nil)
    }
}
