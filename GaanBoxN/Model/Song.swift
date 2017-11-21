

import UIKit

class Song: NSObject , NSCoding {
    
    var songID          : String = ""
    var albumID         : String = ""
    var artistID        : String = ""
    var songURL         : String = ""
    var songName        : String = ""
    var coverImageURL   : String = ""
    var artistName      : String = ""
    var singerInfo      : NSDictionary  = [:]
    
    
    init(songID : String, albumID : String, artistID : String, songURL : String, songName : String, coverImageURL : String, artistName : String, singerInfo : NSDictionary) {
    
        self.songID = songID
        self.albumID = albumID
        self.artistID = artistID
        self.songURL = songURL
        self.songName = songName
        self.coverImageURL = coverImageURL
        self.artistName = artistName
        self.singerInfo = singerInfo
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let songID = aDecoder.decodeObject(forKey: "songID") as! String
        let albumID = aDecoder.decodeObject(forKey: "albumID") as! String
        let artistID = aDecoder.decodeObject(forKey: "artistID") as! String
        let songURL = aDecoder.decodeObject(forKey: "songURL") as! String
        let songName = aDecoder.decodeObject(forKey: "songName") as! String
        let coverImageURL = aDecoder.decodeObject(forKey: "coverImageURL") as! String
        let artistName = aDecoder.decodeObject(forKey: "artistName") as! String
        let singerInfo = aDecoder.decodeObject(forKey: "singerInfo") as! NSDictionary
        
        self.init(songID: songID, albumID: albumID, artistID: artistID, songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: singerInfo)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(songID, forKey: "songID")
        aCoder.encode(albumID, forKey: "albumID")
        aCoder.encode(artistID, forKey: "artistID")
        aCoder.encode(songURL, forKey: "songURL")
        aCoder.encode(songName, forKey: "songName")
        aCoder.encode(coverImageURL, forKey: "coverImageURL")
        aCoder.encode(artistName, forKey: "artistName")
        aCoder.encode(singerInfo, forKey: "singerInfo")
    }
}

class VideoSong: NSObject, NSCoding{
    
    var id              : String = ""
    var thumbnailName   : String = ""
    var videoTitle      : String = ""
    var videoURL        : String = ""
    var videoSubtitle   : String = ""
    
    init(id : String, thumbnailName : String, videoTitle : String, videoURL : String, videoSubtitle : String) {
        
        self.id = id
        self.thumbnailName = thumbnailName
        self.videoTitle = videoTitle
        self.videoURL = videoURL
        self.videoSubtitle = videoSubtitle
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeObject(forKey: "videoID") as! String
        let thumbnailName = aDecoder.decodeObject(forKey: "thumbnailName") as! String
        let videoTitle = aDecoder.decodeObject(forKey: "videoTitle") as! String
        let videoURL = aDecoder.decodeObject(forKey: "videoURL") as! String
        let videoSubtitle = aDecoder.decodeObject(forKey: "videoSubtitle") as! String
        
        self.init(id: id, thumbnailName: thumbnailName, videoTitle: videoTitle, videoURL: videoURL, videoSubtitle: videoSubtitle)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(id, forKey: "videoID")
        aCoder.encode(thumbnailName, forKey: "thumbnailName")
        aCoder.encode(videoTitle, forKey: "videoTitle")
        aCoder.encode(videoURL, forKey: "videoURL")
        aCoder.encode(videoSubtitle, forKey: "videoSubtitle")

    }
}

