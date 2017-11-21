
import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage


class APIManager: NSObject {
    
    // Singleton shared instance
    static let shared   = APIManager()
    
    var array_slideObject       = [Slide] ()
        ,array_hitSongObject    = [HitSong]()
        ,array_albumObject      = [Album]()
        ,array_singerObject     = [Singer]()
        ,array_allSongsObject   = [Song]()

    /***
     - Request for all audio songs data
     */
    open func parseAPIData(_ apiURL : String, dataType : String, callback:@escaping ([Any]) -> ()) {
        
        var json : JSON = ""
        
        // Display activity indicator in status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // request with URL
        Alamofire.request(apiURL ).responseJSON{ (responseData) -> Void in
            
            // stop and hide avtivity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // Check if reponse data is nil 
            if((responseData.result.value) != nil) {
                
                Reach.isInternet = true 
                json = JSON(responseData.result.value!)
                
                // check for which type data is requested
                if dataType == "imageSlider" {
                    
                    if let resData = json["promotedSongs"].arrayObject {
                        
                        self.array_slideObject.removeAll()
                        
                        for result in resData as[AnyObject] {
                            
                            let slide = Slide()
                            let imageURL = result["image"] as! String
                            let songURL = result["audio_file"] as! String
                            
                            slide.slideSongName = result["banner_name"] as! String
                            slide.slideSongMP3 = (commonURL + songURL).replacingOccurrences(of: " ", with: "%20")
                            slide.slideSongImage =  (commonURL + imageURL).replacingOccurrences(of: " ", with: "%20")
                 
                            self.array_slideObject.append(slide)
                        }
                        callback(self.array_slideObject)
                    }
                } else if dataType == "hitsong" {
                    
                    if let resData = json["hitSongs"].arrayObject {
       
                        self.array_hitSongObject.removeAll()
                        
                        for result in resData as[AnyObject] {
                            
                            let hitSong = HitSong()
                            let audioURL = result["audio_file"] as! String
                            let imageURL = result["image"] as! String
                            
                            hitSong.hitSongID = String(describing: result["id"] as! NSNumber)
                            hitSong.hitSongName = result["name"] as! String
                            hitSong.artistName = "Unknown"
                            hitSong.hitSongMp3 = (commonURL + audioURL).replacingOccurrences(of: " ", with: "%20")
                            hitSong.hitSongURL = (commonURL + imageURL).replacingOccurrences(of: " ", with: "%20")
                          
                            self.array_hitSongObject.append(hitSong)
                        }
                        callback(self.array_hitSongObject)
                    }
                } else if dataType == "album" {
                    
                    if let resData = json["albums"].arrayObject {
                        
                        self.array_albumObject.removeAll()
                    
                        for result in resData as[AnyObject] {
                            
                            let album = Album()
                            let coverImageURL = result["image"] as! String
                            
                            album.albumID = String(describing: result["id"] as! NSNumber)
                            album.albumName = result["name"] as! String
                            album.albumCoverImageURL = (commonURL + coverImageURL).replacingOccurrences(of: " ", with: "%20")
                            album.albumCategoryID = String(describing: result["category_id"] as! NSNumber)
                            album.hitAlbumStatus = String(describing: result["hit_album_status"] as! NSNumber)
                            album.dic_category = result["category"] as! NSDictionary
                            
                            self.array_albumObject.append(album)
                        }
                     callback(self.array_albumObject)
                    }
                } else if dataType == "albumSong" {
                    
                    if let resData = json["songs"].arrayObject {
                        
                        var array_albumSongObject = [Song]()
                        
                        for result in resData as[AnyObject] {
                   
                            let songID = String(describing: result["id"] as! NSNumber)
                            let albumID = String(describing: result["album_id"] as! NSNumber)
                            let artistID = String(describing: result["singer_id"] as! NSNumber)
                            let songName = result["name"] as! String
                            let songURL = (commonURL + (result["audio_file"] as! String)).replacingOccurrences(of: " ", with: "%20")
                            let singerInfo = result["album"] as! NSDictionary
                            
                            let song = Song(songID: songID, albumID: albumID, artistID: artistID, songURL: songURL, songName: songName, coverImageURL: "", artistName: "", singerInfo: singerInfo)
 
                            array_albumSongObject.append(song)
                        }
                        callback(array_albumSongObject)
                    }
                } else if dataType == "singer" {
                    
                    if let resData = json["singers"].arrayObject {
                        
                        self.array_singerObject.removeAll()
                        
                        for result in resData as[AnyObject] {
                            
                            let singer = Singer()
                            let imagelink = result["image"] as! String
                            
                            singer.singerID = String(describing: result["id"] as! NSNumber)
                            singer.singerName = result["name"] as! String
                            singer.singerImageURL = (commonURL + imagelink).replacingOccurrences(of: " ", with: "%20")
                           
                            self.array_singerObject.append(singer)
                        }
                        callback(self.array_singerObject)
                    }
                } else if dataType == "singerSong" {
                    
                    if let resData = json["songs"].arrayObject {
                        
                        var array_singerSongObject = [Song]()
                        
                        for result in resData as[AnyObject] {
                            
                         
                            let songID = String(describing: result["id"] as! NSNumber)
                            let albumID = String(describing: result["album_id"] as! NSNumber)
                            let artistID = String(describing: result["singer_id"] as! NSNumber)
                            let songName = result["name"] as! String
                            let songURL = (commonURL + (result["audio_file"] as! String)).replacingOccurrences(of: " ", with: "%20")
                            
                            let song = Song(songID: songID, albumID: albumID, artistID: artistID, songURL: songURL, songName: songName, coverImageURL: "", artistName: "", singerInfo: [:])

                            array_singerSongObject.append(song)
                        }
                        callback(array_singerSongObject)
                    }
                } else if dataType == "allSongs" {
                    
                    if let resData = json["songs"].arrayObject {
                        
                        self.array_allSongsObject.removeAll()
                        
                        for result in resData as[AnyObject] {
                            
                          
                            let albumDic = result["album"] as! NSDictionary
                            let songURL = albumDic["image"] as! String
                            let songFileURL = result["audio_file"] as! String
                            
                            let songID = String(describing: result["id"] as! NSNumber)
                            let albumID = String(describing: result["album_id"] as! NSNumber)
                            let artistID = String(describing: result["singer_id"] as! NSNumber)
                            let songName = result["name"] as! String
                            let coverImageURL = (commonURL + songURL).replacingOccurrences(of: " ", with: "%20")
                            let mp3songURL = (commonURL + songFileURL).replacingOccurrences(of: " ", with: "%20")
                            
                            let song = Song(songID: songID, albumID: albumID, artistID: artistID, songURL: mp3songURL, songName: songName, coverImageURL: coverImageURL, artistName: "", singerInfo: [:])
                            
                            self.array_allSongsObject.append(song)
                        }
                        callback(self.array_allSongsObject)
                    }
                }
            } else {
                print("🐞🐞🐞 - response data data is nill - 🐞🐞🐞")
                
                // reachability status - offline
                Reach.isInternet = false
                // Notification for no internet
                NotificationCenter.default.post(name: Notification.Name(rawValue: ReachabilityStatusChangedNotification),
                                                object: nil,
                                            userInfo: ["Status": "Offline"])
            }
        }
    }
    /***
     - Request for all video songs data
     */
    func parseSubscriptionStatusRequest(_ apiURL : String, callback:@escaping (String) -> ()) {
        Alamofire.request(apiURL ).responseJSON{(responseData) -> Void in
            
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)

                if let resData = json.dictionaryObject {
                    callback(resData["message"] as! String )
                }
            } else {
                print("🐞🐞🐞 response data data is nill 🐞🐞🐞")
            }
        }
    }
    /***
     - Request for image
     */
    func parseImage(_ apiURL : String, callback:@escaping (UIImage) -> ())  {
 
        Alamofire.request(apiURL).responseImage { response in
        
            if let image = response.result.value {
                callback(image)
            }
        }
    }
    /***
     - Send slide image list
     */
    func slideSongList() -> [Slide] {
        return array_slideObject
    }
}

