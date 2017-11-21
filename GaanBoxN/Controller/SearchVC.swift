//
//  SearchVC.swift
//  GaanBoxN
//
//  Created by Shariif on 3/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

struct SearchItem {
    
    var category : String
    var name : String
    var artistName : String
    var imageURL : String
    var mp3Url : String
    var album : Album!
    var artist : Singer!
}

class SearchVC: UIViewController, UISearchResultsUpdating{
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
 
    let searchController = UISearchController(searchResultsController: nil)
    var array_songsItem          = [SearchItem]()
        ,array_albumItem         = [SearchItem]()
        ,array_artistItem        = [SearchItem]()
        ,array_searchResult      = [SearchItem]()
    var searchCellID             = "searchCellID"
    var recentCellID             = "recentCellID"
    var didParseSongsData        = false
    var didParseAlbumData        = false
    var didParseArtistData       = false

    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set searchview
        setupSearchView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         setupSearchView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Check for internet rechability
        if !Reach.isInternet{
            
            // If internet not available show alert
            let alert =   GBAlert.shared.alertForGoToSettingPage(title: "Warring", message: "You must connect to Wi-Fi or mobile data to access GaanBox", otherButtonTitle: "OK")
            self.present(alert, animated: true, completion: nil)
        }
        
        // Keyboard show/hide notification
        NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segue_SearchVCToDetailedVC" {
            
            let controller = segue.destination as! DetailedView
            
            if searchController.isActive {
                
                var array_list : [SearchItem]?
                
                if searchController.searchBar.text != "" {
                    // load search result
                    array_list = array_searchResult
                } else {
                    if searchController.searchBar.selectedScopeButtonIndex == 1 {
                        array_list = array_albumItem
                    } else  {
                        array_list = array_artistItem
                    }
                }
                
                if searchController.searchBar.selectedScopeButtonIndex == 1 {
                    
                    controller.array_album.removeAll()
                    if let selectedPath = tableView.indexPathForSelectedRow {
                        Home.whichView = "Album"
                        controller.array_album = [(array_list?[selectedPath.item].album)!]
                    }
                } else  {
                    
                    controller.array_singer.removeAll()
                    if let selectedPath = tableView.indexPathForSelectedRow {
                        Home.whichView = "Singer"
                        controller.array_singer = [(array_list?[selectedPath.item].artist)!]
                    }
                }
            }
        }
    }
    /**
     - Initialize search controller
     - Set search bar on navigation item
     */
    func setupSearchView(){
        
        self.title = "Search"
        
        tableView.register(SearchItemTableViewCell.self, forCellReuseIdentifier: searchCellID)
        tableView.register(RecentSearchItemTableViewCell.self, forCellReuseIdentifier: recentCellID)
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Song", "Album", "Artist"]
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.changeSearchBarColor(color: UIColor.white)
       
        self.tableView.backgroundView = UIView()
    }
    /**
     - Get all songs from API
     */
    func fetchAllSongsData(callback:@escaping (Bool) -> ()) {
        
        self.array_songsItem.removeAll()
        
        if AlbumView.array_albums == nil {
            return
        }
        
        for (index,album) in (AlbumView.array_albums?.enumerated())! {
            
             let albumAPIURL = (albumSongAPIURL+String(album.albumID))
            
            APIHandler.shared.parseAPIData(albumAPIURL, dataType: "allSongs") { (responseData) in

                var songItem = SearchItem(category: "", name: "", artistName: "", imageURL: "", mp3Url: "", album: nil , artist: nil)
                let array_allSongsList = (responseData as? [Song])!
                
                for songs in array_allSongsList {
                    
                    songItem.category = "Song"
                    songItem.name = songs.songName
                    songItem.imageURL = songs.coverImageURL
                    songItem.artistName = songs.artistName
                    songItem.mp3Url = songs.songURL
                    
                    self.array_songsItem.append(songItem)
                }
                
                if index + 1 == AlbumView.array_albums?.count{
                    callback(true)
                }
            }
        }
    }
    /**
     - Get all Albums
     */
    func fetchAllAlbumData(){
        
        if AlbumView.array_albums != nil {
            
            var albumItem = SearchItem(category: "", name: "", artistName: "", imageURL: "", mp3Url: "", album: nil , artist: nil)
            self.array_albumItem.removeAll()
            
            for album in AlbumView.array_albums! {
                
                albumItem.category = "Album"
                albumItem.name = album.albumName
                albumItem.imageURL = album.albumCoverImageURL
                albumItem.album = album
                
                self.array_albumItem.append(albumItem)
            }
            self.didParseAlbumData = true
            self.tableView.reloadData()
        }
    }
    /**
     - Get all Artist
     */
    func fetchAllArtistData(){
        
        if SingerView.array_singers != nil {
            var artistItem = SearchItem(category: "", name: "", artistName: "", imageURL: "", mp3Url: "", album: nil , artist: nil)
            self.array_artistItem.removeAll()
            
            for artist in SingerView.array_singers! {
                
                artistItem.category = "Artist"
                artistItem.name = artist.singerName
                artistItem.imageURL = artist.singerImageURL
                artistItem.artist = artist
                
                self.array_artistItem.append(artistItem)
            }
            self.didParseArtistData = true
            self.tableView.reloadData()
            
        } else {
            parseSingerData()
        }
    }
    /**
     - Get all singer from API
     */
    func parseSingerData(){
        
        APIHandler.shared.parseAPIData(singerAPIURL, dataType: "singer") { (responseData) in
 
            SingerView.array_singers = responseData as? [Singer]
            self.fetchAllArtistData()
        }
    }
    /**
     - Get all songs from API
     */
    func filterContentForSearchText(searchText: String, scope: String = "Song") {
        
        var arrayFilter : [SearchItem]
        
        if scope == "Song" {
            arrayFilter = self.array_songsItem
        } else if scope == "Album" {
            arrayFilter = self.array_albumItem
        } else {
            arrayFilter = self.array_artistItem
        }
    
        array_searchResult = arrayFilter.filter { item in
            
            let categoryMatch =  (item.category == scope)
            return  categoryMatch && item.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    /**
     - Update search result
     */
    func updateSearchResults(for searchController: UISearchController) {
 
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        fetchData(scope: scope)
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
    /**
     - Get all songs from API
     */
    func fetchData(scope: String) {

        if scope == "Song" || scope == "0" {
            if !didParseSongsData {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                 fetchAllSongsData(callback: { (isParse) in
                    if isParse {
                        self.didParseSongsData = true
                        self.tableView.reloadData()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                 })
            }
        } else if scope == "Album" || scope == "1" {
            if !didParseAlbumData {
                self.fetchAllAlbumData()
            }
        } else if scope == "Artist" || scope == "2"{
            if !didParseArtistData {
                fetchAllArtistData()
            }
        }
    }
    /****
     * Adjust tableview content when keyboard Show
     */
    func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 3, 0)
            
        }
    }
    
    /**
     - Adjust tableview content when keyboard Hide
     */
    func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
  
        fetchData(scope: String(selectedScope))
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchVC : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            
            if searchController.searchBar.text != "" {
                return array_searchResult.count
            } else {
                
                if searchController.searchBar.selectedScopeButtonIndex == 0 {
                   return array_songsItem.count
                } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
                    return array_albumItem.count
                } else if searchController.searchBar.selectedScopeButtonIndex == 2{
                    return array_artistItem.count
                }
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchController.isActive {
   
            let cell = tableView.dequeueReusableCell(withIdentifier: searchCellID) as! SearchItemTableViewCell
            var item : SearchItem!
            
            if  searchController.searchBar.text != "" {
                item = array_searchResult[indexPath.item]
            } else {
                
                if searchController.searchBar.selectedScopeButtonIndex == 0 {
                    item = self.array_songsItem[indexPath.item]
                } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
                    item = self.array_albumItem[indexPath.item]
                } else if searchController.searchBar.selectedScopeButtonIndex == 2{
                    item = self.array_artistItem[indexPath.item]
                }
            }
            
            cell.item = item
            return cell
            
        } else {
            
            // Cell for recent or trending search item
            let cell = tableView.dequeueReusableCell(withIdentifier: recentCellID) as! RecentSearchItemTableViewCell
   
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        if searchController.isActive {

            if searchController.searchBar.selectedScopeButtonIndex == 0 {
                
                AudioPlayerVC.songIndex = indexPath.row
                var array_songs : [SearchItem]?
                
                if searchController.searchBar.text != "" {
                    array_songs = array_searchResult
                } else {
                    array_songs = array_songsItem
                }
      
                let playervc = storyboard?.instantiateViewController(withIdentifier: "playerVC") as! AudioPlayerVC
                playervc.array_songList.removeAll()
                playervc.notificationForPlayInterruption()
                
                for result in array_songs! {
                    
                    let songName = result.name
                    let artistName = result.artistName
                    let songURL = result.mp3Url
                    let coverImageURL = result.imageURL
                    
                    let playSong = Song(songID: "", albumID: "", artistID: "", songURL: songURL, songName: songName, coverImageURL: coverImageURL, artistName: artistName, singerInfo: [:])
                    
                    playervc.array_songList.append(playSong)
                }
                
                tabBarController?.presentPopupBar(withContentViewController: playervc, animated: true, completion: nil)
                tabBarController?.popupBar.tintColor = UIColor.defaultTintColor
                tabBarController?.popupInteractionStyle = .drag
                tabBarController?.popupContentView.popupCloseButtonStyle = .round
                
                searchController.isActive = false
                
            } else  {
                performSegue(withIdentifier: "segue_SearchVCToDetailedVC", sender: self)
            }
        }
    }
}

