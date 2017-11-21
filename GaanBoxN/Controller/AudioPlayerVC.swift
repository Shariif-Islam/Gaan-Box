//
//  AudioPlayerVC.swift
//  GaanBoxN
//
//  Created by Machintos on 3/30/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import LNPopupController

public struct GBNowPlayingItem {
    let songURL :String
    let songName :String
    let albumName :String
    let artistName :String
    let coverImageURL :String
}

class AudioPlayerVC: UIViewController, STKAudioPlayerDelegate
{
    /******************************************************************/
    // MARK: - IBOutlet
    /******************************************************************/
    @IBOutlet weak var  cons_cv_nextItemBottom: NSLayoutConstraint!
    @IBOutlet weak var  btn_addToFavorite: UIButton!
    @IBOutlet weak var  iv_animation: UIImageView!
    @IBOutlet weak var  slider_volume: UISlider!
    @IBOutlet weak var  view_volume: UIView!
    @IBOutlet weak var  view_coverImage: UIView!
    @IBOutlet weak var  iv_posterImage: UIImageView!
    @IBOutlet weak var  lb_songName: UILabel!
    @IBOutlet weak var  lb_singerName: UILabel!
    @IBOutlet weak var  lb_currentPlayTime: UILabel!
    @IBOutlet weak var  lb_remaingTime: UILabel!
    @IBOutlet weak var  slider: UISlider!
    @IBOutlet weak var  btn_shuffle: UIButton!
    @IBOutlet weak var  btn_previous: UIButton!
    @IBOutlet weak var  btn_playOrPause: UIButton!
    @IBOutlet weak var  btn_next: UIButton!
    @IBOutlet weak var  btn_repeat: UIButton!
    @IBOutlet weak var  indicator_mainPlayer: UIActivityIndicatorView!
    @IBOutlet weak var  cv_nextItems: UICollectionView!
    
    /******************************************************************/
    // MARK: - Custom Variables/Constants
    /******************************************************************/
    static var  repeatOne  = false
    static var  suffle     = false
    static var  player     : STKAudioPlayer?
    static var  songIndex  = 0
    static var nowPlayingItem :GBNowPlayingItem?
    static let shared   = AudioPlayerVC()
    
    private var    animationCounter       = 0
    private var    mpVolumeSlider         = UISlider()
    private var    isInterrupt            = false
    private var    timer                  = Timer()
    private var    isInterruptByVideo     = false
    private var nextItemCurrentX :CGFloat = -110
    private var nextItemPanGestureRecognizer :UIPanGestureRecognizer!
    
    let commandCenter       = MPRemoteCommandCenter.shared()
    let nowPlayingCenter    = MPNowPlayingInfoCenter.default()
    var nowPlayingInfo: [String : AnyObject]?
    var  array_songList     = [Song]()

    /******************************************************************/
    // MARK: - Overrride Functions
    /******************************************************************/
    override func viewDidLoad()
    {
        super.viewDidLoad()
   
        // Set Title image on nav bar
        let titleImageView = UIImageView(image:#imageLiteral(resourceName: "title-logo"))
        self.navigationItem.titleView = titleImageView
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Initialize STKAudioplayer
        if AudioPlayerVC.player == nil {
            AudioPlayerVC.player = STKAudioPlayer()
        }
        AudioPlayerVC.player?.delegate = self
  
        enableBackgroundMode()
        setUpMusicplayer()
        setUpSliderThumbImage()
        setupVolumeSlider()
        setPlayerBUttonAndTintColor()
        
        // Next/previous action by swipe left/right
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(getSwipeAction(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: #selector(getSwipeAction(_:)))
        swipeRight.direction = .right
        
        iv_posterImage.addGestureRecognizer(swipeLeft)
        iv_posterImage.addGestureRecognizer(swipeRight)
        
        nextItemSwipeGestures()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLayoutSubviews() {
        cons_cv_nextItemBottom.constant = nextItemCurrentX
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface),
                                               name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /******************************************************************/
    // MARK: - @IBAction
    /******************************************************************/
    
    @IBAction func sliderAction(_ sender: Any){
        AudioPlayerVC.player?.seek(toTime: Double(slider.value))
    }
    @IBAction func sliderVolumeAction(_ sender: Any) {
        mpVolumeSlider.value = (sender as AnyObject).value
    }
    /**
     - Shuffle play list
     */
    @IBAction func shuffle(_ sender: Any){
        
        if AudioPlayerVC.suffle {
            AudioPlayerVC.suffle = false
            btn_shuffle.setImage(UIImage(named: "ic_shuffle"), for: UIControlState.normal)
        } else {
            AudioPlayerVC.suffle = true
            let image = UIImage(named: "ic_shuffle")?.withRenderingMode(.alwaysTemplate)
            btn_shuffle.setImage(image, for: UIControlState.normal)
        }
    }
    /**
     - Play previous song
     */
    @IBAction func previousSong(_ sender: Any){
        playPrevious()
    }
    /**
     - Play or pause
     */
    @IBAction func playOrPause(_ sender: Any){
        playOrPause()
    }
    /**
     - Play next song
     */
    @IBAction func nextSong(_ sender: Any){
        playNext()
    }
    /**
     - Repeat song
     */
    @IBAction func repeatSong(_ sender: Any) {
        
        if AudioPlayerVC.repeatOne {
            AudioPlayerVC.repeatOne = false
            btn_repeat.setImage(UIImage(named: "ic_replay"), for: UIControlState.normal)
        } else {
            AudioPlayerVC.repeatOne = true
            let image = UIImage(named: "ic_replay")?.withRenderingMode(.alwaysTemplate)
            btn_repeat.setImage(image, for: UIControlState.normal)
        }
    }
    /**
     - Add song to favorite list
     */
    @IBAction func addToFavoriteList(_ sender: Any) {
        
        if Favorite.shared.isFavoriteAudioSong(url: array_songList[AudioPlayerVC.songIndex].songURL) {
            Favorite.shared.removeAudio(fromFavoriteList: array_songList[AudioPlayerVC.songIndex])
        } else {
            Favorite.shared.addAudio(toFavorite: array_songList[AudioPlayerVC.songIndex])
        }
        updateFavoriteButton()
    }
    /**
     - Play net from list
     */
    @IBAction func playNextFromNextItemList(_ sender: UIButton) {
        
        AudioPlayerVC.songIndex = sender.tag
        setUpMusicplayer()
        cv_nextItems.reloadData()
    }
    
    /******************************************************************/
    // MARK: - Custom Methods
    /******************************************************************/
   
    /**
     - Left/Right swipe gesture
     */
    func getSwipeAction( _ recognizer : UISwipeGestureRecognizer){
        
        if recognizer.direction == .left {
            
            if(AudioPlayerVC.songIndex + 1 >= array_songList.count) {
                Animation.shared.animateNoNextTrackBounce(iv_posterImage.layer)
                return
            }
            playNext()
            Animation.shared.animateContentChange(kCATransitionFromRight, layer: iv_posterImage.layer)
            
        } else {
            
            if(AudioPlayerVC.songIndex - 1 < 0) {
                Animation.shared.animateNoPreviousTrackBounce(iv_posterImage.layer)
                return
            }
            playPrevious()
            Animation.shared.animateContentChange(kCATransitionFromLeft, layer: self.iv_posterImage.layer)
        }
    }
    /**
     - Play song in background mode
     */
    func enableBackgroundMode(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    /**
     - Setup button and tint color
     */
    func setPlayerBUttonAndTintColor(){
        
        let next = #imageLiteral(resourceName: "ic_next").withRenderingMode(.alwaysTemplate)
        let prev = #imageLiteral(resourceName: "ic_prev").withRenderingMode(.alwaysTemplate)
        
        btn_previous.setImage(prev, for: .normal)
        btn_previous.tintColor = UIColor.white
        
        btn_next.setImage(next, for: .normal)
        btn_next.tintColor = UIColor.white
    }
    /**
     - Setup mini player
     */
    func setupMiniPlayer(){
        
        let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(miniPlayerPlayPause))
        
        let previous = UIBarButtonItem(image: UIImage(named: "previous"), style: .plain, target: self, action: #selector(playPrevious))
        
        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(playNext))
       
        self.popupItem.leftBarButtonItems = [previous]
        self.popupItem.rightBarButtonItems = [ pause, next]
        
        // Update miniplayer controller
        if(AudioPlayerVC.songIndex - 1 < 0) {
            self.popupItem.leftBarButtonItems?.first?.isEnabled = false
        } else {
            self.popupItem.leftBarButtonItems?.first?.isEnabled = true
        }
        
        if(AudioPlayerVC.songIndex + 1 >= array_songList.count) {
            self.popupItem.rightBarButtonItems?.last?.isEnabled = false
        } else {
            self.popupItem.rightBarButtonItems?.last?.isEnabled = true
        }
    }
    /**
     - Play/pause from mini player
     */
    func miniPlayerPlayPause(){
        playOrPause()
    }
    /**
     - Start playing animation
     */
    func startAnimation() {
        if(animationCounter == 3){
            animationCounter = 0
        } else {
            animationCounter += 1
        }
        iv_animation.image = UIImage(named: "NowPlayingBars-\(animationCounter).png")
    }
    /**
     - Update internet status
     */
    func updateInternetStatus() {
        
        if !Reach.isInternet {
            let alert =   GBAlert.shared.alertForGoToSettingPage(title: "Warring", message: "You must connect to Wi-Fi or mobile data to access GaanBox", otherButtonTitle: "OK")
            self.present(alert, animated: true, completion: nil)
        }
    }
    /**
     - Initialize music player
     */
    func setUpMusicplayer() {
        updateInternetStatus()
        setupMiniPlayer()
        
        if AudioPlayerVC.player?.state == STKAudioPlayerState.buffering {
            // State buffering
            btn_playOrPause.isHidden = true
            indicator_mainPlayer.isHidden = false
            indicator_mainPlayer.startAnimating()
            popupItem.rightBarButtonItems?.first?.isEnabled = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
        } else {
            // playing
            btn_playOrPause.isHidden = false
            indicator_mainPlayer.isHidden = true
            popupItem.rightBarButtonItems?.first?.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
       
        // play song drom url
        AudioPlayerVC.player?.play(array_songList[AudioPlayerVC.songIndex].songURL)
        // Add item to now playing
        AudioPlayerVC.nowPlayingItem = GBNowPlayingItem(songURL: array_songList[AudioPlayerVC.songIndex].songURL,
                                                        songName: array_songList[AudioPlayerVC.songIndex].songName,
                                                        albumName: "",
                                                        artistName: array_songList[AudioPlayerVC.songIndex].artistName,
                                                        coverImageURL: array_songList[AudioPlayerVC.songIndex].coverImageURL)
        
        setupTimer()
        updateInterface()
        updateController()
 
        // notification for update playing item
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCurrentPlayingItem"), object: nil)

        // change background image
        let image = UIImage(named: "image_background")!
        let mediaArtwork = MPMediaItemArtwork(boundsSize: image.size) { (size: CGSize) -> UIImage in
            return image
        }
        // add info to now playing list
        let nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyArtist: AudioPlayerVC.nowPlayingItem?.artistName ?? "Artist Unknown",
            MPMediaItemPropertyTitle: AudioPlayerVC.nowPlayingItem?.songName ?? "Title Unknown",
            MPMediaItemPropertyArtwork: mediaArtwork,
            MPMediaItemPropertyPlaybackDuration: "\(String(describing: AudioPlayerVC.player?.duration))" ,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: "\(String(describing: AudioPlayerVC.player?.progress))"
        ]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    /**
     - start the timer for playing song
     */
    func setupTimer() {
        if timer.isValid {
            timer.invalidate()
        }
        timer = Timer.init(timeInterval: 0.1, target: self, selector: #selector(updateSliderProgress), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    /**
     - Upadte player interface
     - update poster image
     - update song name, singer name, next/previous button
     */
    func updateInterface()
    {
        self.popupItem.image = UIImage(named: "image_placeholder_Square")
        APIHandler.shared.parseImage(array_songList[AudioPlayerVC.songIndex].coverImageURL) { (image) in
            self.popupItem.image = image
        }
   
        iv_posterImage.af_setImage(withURL: URL(string: array_songList[AudioPlayerVC.songIndex].coverImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))

        let songName = array_songList[AudioPlayerVC.songIndex].songName
        let singerName = array_songList[AudioPlayerVC.songIndex].artistName
        
        lb_songName.text = songName == "" ? "Unknown" : songName
        lb_singerName.text = singerName == "" ? "Unknown" : singerName
        
        popupItem.title = songName == "" ? "Unknown" : songName
        popupItem.subtitle = singerName == "" ? "Unknown" : singerName
        
        updateFavoriteButton()
    }
    /***
     * Update favorite button
     */
    func updateFavoriteButton(){
        
        let image = UIImage(named: "icon_favorites")?.withRenderingMode(.alwaysTemplate)

        if Favorite.shared.isFavoriteAudioSong(url: array_songList[AudioPlayerVC.songIndex].songURL) {
            
            btn_addToFavorite.setImage(image, for: UIControlState.normal)
            btn_addToFavorite.tintColor = UIColor.defaultTintColor
            
        } else {
            btn_addToFavorite.setImage(image, for: UIControlState.normal)
            btn_addToFavorite.tintColor = UIColor.white
        }
    }
    /**
     - Update player controller
     */
    func updateController()
    {
        // Previous button update
        if(AudioPlayerVC.songIndex - 1 < 0){
            btn_previous.isEnabled = false
            self.commandCenter.previousTrackCommand.isEnabled = false
        } else {
            btn_previous.isEnabled = true
            self.commandCenter.previousTrackCommand.isEnabled = true
        }
        // Next button update
        if(AudioPlayerVC.songIndex + 1 >= array_songList.count) {
            btn_next.isEnabled = false
            self.commandCenter.nextTrackCommand.isEnabled = false
        } else {
            btn_next.isEnabled = true
            self.commandCenter.nextTrackCommand.isEnabled = true
        }
        // Repeat button update
        if AudioPlayerVC.repeatOne {
            let image = UIImage(named: "ic_replay")?.withRenderingMode(.alwaysTemplate)
            btn_repeat.setImage(image, for: UIControlState.normal)
        } else {
            btn_repeat.setImage(UIImage(named: "ic_replay"), for: UIControlState.normal)
        }
        // Suffle button update
        if AudioPlayerVC.suffle {
            let image = UIImage(named: "ic_shuffle")?.withRenderingMode(.alwaysTemplate)
            btn_shuffle.setImage(image, for: UIControlState.normal)
        } else {
            btn_shuffle.setImage(UIImage(named: "ic_shuffle"), for: UIControlState.normal)
        }
    }
    /**
     - Updating slider progress
     */
    func updateSliderProgress()
    {
        if AudioPlayerVC.player?.duration != 0
        {
            if Float(slider.value) < Float(AudioPlayerVC.player!.progress) {
                startAnimation()
            }
            
            slider.minimumValue = 0;
            slider.maximumValue = Float(AudioPlayerVC.player!.duration)
            slider.value = Float(AudioPlayerVC.player!.progress)
            lb_remaingTime.text = "\(Helper.shared.formatTime(fromSeconds: Int(AudioPlayerVC.player!.duration)))"
            lb_currentPlayTime.text = "\(Helper.shared.formatTime(fromSeconds : Int(AudioPlayerVC.player!.progress)))"
     
            // Convert player progress between 0 - 1 and set to miniplayer
            let value = (slider.value - 0) / Float(AudioPlayerVC.player!.duration - 0)
            popupItem.progress = value
        }
        else {
            slider.value = 0;
            slider.minimumValue = 0;
            slider.maximumValue = 0;
        }
    }
    /**
     - Play/pause song
     */
    func playOrPause()
    {
        if AudioPlayerVC.player?.state == STKAudioPlayerState.playing {
            AudioPlayerVC.player?.pause()
            
            print(btn_playOrPause)
            
            let icon = UIImage(named: "ic_play")?.withRenderingMode(.alwaysTemplate)
            btn_playOrPause.tintColor = UIColor.white
            btn_playOrPause.setImage(icon, for: UIControlState.normal)
            popupItem.rightBarButtonItems?.first?.tintColor = UIColor.white
            
        } else if AudioPlayerVC.player?.state == STKAudioPlayerState.paused {
            
            AudioPlayerVC.player?.resume()
            let icon = UIImage(named: "ic_pause")?.withRenderingMode(.alwaysTemplate)
            btn_playOrPause.tintColor = UIColor.defaultTintColor
            btn_playOrPause.setImage(icon, for: UIControlState.normal)
            popupItem.rightBarButtonItems?.first?.tintColor = UIColor.defaultTintColor
        }
    }
    /**
     - play next song
     */
    func playNext() {
        if array_songList.count != 0 {
            if(AudioPlayerVC.songIndex + 1 < array_songList.count) {
                AudioPlayerVC.songIndex += 1
                lb_remaingTime.text = "00:00"
                lb_currentPlayTime.text = "00:00"
                cv_nextItems.reloadData()
                setUpMusicplayer()
            }
        }
    }

    /**
     - play previous song
     */
    func playPrevious() {
        if array_songList.count != 0 {
            if(AudioPlayerVC.songIndex - 1 >= 0 && AudioPlayerVC.songIndex < array_songList.count) {
                AudioPlayerVC.songIndex -= 1
                lb_remaingTime.text = "00:00"
                lb_currentPlayTime.text = "00:00"
                cv_nextItems.reloadData()
                setUpMusicplayer()
            }
        }
    }
    /**
     - set small thumb to slider
     */
    func setUpSliderThumbImage() {
        
        let thumbImage : UIImage = UIImage(named: "slider-ball")!
        let size = CGSize(width: 20.0, height: 20.0 )
        
        slider.setThumbImage(Helper.shared.imageWithImage(image: thumbImage, scaledToSize: size), for: UIControlState.normal )
        slider_volume.setThumbImage(Helper.shared.imageWithImage(image: thumbImage, scaledToSize: size), for: UIControlState.normal )
    }
    /**
     - Setup volume slider
     */
    func setupVolumeSlider() {
        
        view_volume.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: view_volume.bounds)
        for view in volumeView.subviews {
            let uiview: UIView = view as UIView
            if (uiview.description as NSString).range(of: "MPVolumeSlider").location != NSNotFound {
                mpVolumeSlider = (uiview as! UISlider)
            }
        }
        let currentVolume = AVAudioSession.sharedInstance().outputVolume
        slider_volume.value = currentVolume
    }
    /**
     - Playing interruption by system like call
     */
    func playInterrupt(notification: NSNotification) {
        
        if AudioPlayerVC.player?.state == STKAudioPlayerState.playing || isInterrupt {
            
            if notification.name == NSNotification.Name.AVAudioSessionInterruption
                && notification.userInfo != nil {
                
                var info = notification.userInfo!
                var intValue: UInt = 0
                
                (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
                
                if let type = AVAudioSessionInterruptionType(rawValue: intValue) {
                    
                    switch type {
                    case .began:
                        isInterrupt = true
                        AudioPlayerVC.player?.pause()
                    case .ended:
                        isInterrupt = false
                        AudioPlayerVC.player?.resume()
                    }
                }
            }
        }
    }
    
    func notificationForPlayInterruption(){
        // play interruption notification
        NotificationCenter.default.addObserver(self, selector: #selector(playInterrupt(notification:)),
                                               name: NSNotification.Name.AVAudioSessionInterruption,
                                               object: nil)
    }
    /**
     - player stae changed like buffering, playing, finished
     */
    func MusicPlayerStateChanged()
    {
        if AudioPlayerVC.player?.state == STKAudioPlayerState.buffering {
            
            btn_playOrPause.isHidden = true
            indicator_mainPlayer.isHidden = false
            indicator_mainPlayer.startAnimating()
            popupItem.rightBarButtonItems?.first?.isEnabled = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
        } else if AudioPlayerVC.player?.state == STKAudioPlayerState.playing {
            
            indicator_mainPlayer.stopAnimating()
            indicator_mainPlayer.isHidden = true
            btn_playOrPause.isHidden = false
            
            let pauseIC = UIImage(named: "ic_pause")?.withRenderingMode(.alwaysTemplate)
            btn_playOrPause.tintColor = UIColor.defaultTintColor
            btn_playOrPause.setImage(pauseIC, for: UIControlState.normal)
            popupItem.rightBarButtonItems?.first?.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    /**
     - finished to play song
     */
    func didFinishPlaying() {
        
        if AudioPlayerVC.player?.stopReason == STKAudioPlayerStopReason.eof {
            if btn_next.isEnabled || AudioPlayerVC.repeatOne || AudioPlayerVC.suffle {
                if !AudioPlayerVC.repeatOne {
                    AudioPlayerVC.songIndex += 1
                }
                
                if AudioPlayerVC.suffle && !AudioPlayerVC.repeatOne {
                    let random = Int(arc4random_uniform(UInt32(array_songList.count)))
                    AudioPlayerVC.songIndex = random
                }
                cv_nextItems.reloadData()
                setUpMusicplayer()
            } else {
                AudioPlayerVC.songIndex = 0
                cv_nextItems.reloadData()
                setUpMusicplayer()
            }
        }
    }

    /**
     - Controll volume
     */
    func volumeChanged(notification: Notification) {
        
        let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"]
        slider_volume.value = volume as! Float
    }
    
    /******************************************************************/
    // MARK: - Next item collection view
    /******************************************************************/
    
    func nextItemSwipeGestures(){

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showNextItem(recognizer:)))
        swipeUp.direction = .up
        cv_nextItems.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(hideNextItem(recognizer:)))
        swipeDown.direction = .down
        cv_nextItems.addGestureRecognizer(swipeDown)
    }
    
    func showNextItem(recognizer :UISwipeGestureRecognizer) {
    
        nextItemCurrentX = -15
        cons_cv_nextItemBottom.constant = nextItemCurrentX
        animation()
    }
    
    func hideNextItem(recognizer :UISwipeGestureRecognizer) {
        
        nextItemCurrentX = -110
        cons_cv_nextItemBottom.constant = nextItemCurrentX
        animation()
    }

    func animation () {
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /******************************************************************/
    // MARK: - STKAudioPlayer Delegate Methods
    /******************************************************************/
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject){
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject){
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
       MusicPlayerStateChanged()
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        
        didFinishPlaying()
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode)
    {
        print("💀💀💀 unexpected error 💀💀💀")
    }
    
}

extension AudioPlayerVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /**
     - Collection View Data Source Delegate Method
     */
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_songList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nextItemscollectionViewCell", for: indexPath) as! NextItemsCollectionViewCell

            cell.lb_title.text = array_songList[indexPath.row].songName
            cell.iv_coverImage.af_setImage(withURL: URL(string: array_songList[indexPath.row].coverImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
        
            cell.btn_playFromNextItems.tag = indexPath.row
        
        if AudioPlayerVC.nowPlayingItem?.songURL == array_songList[indexPath.row].songURL {
        
            cell.btn_playFromNextItems.isHidden = true
            cell.lb_title.textColor = UIColor.defaultTintColor
            animation()
        
        } else {
            
            cell.btn_playFromNextItems.isHidden = false
            cell.lb_title.textColor = UIColor.white
            animation()
        }
        
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  
        AudioPlayerVC.songIndex = indexPath.row
        setUpMusicplayer()
        cv_nextItems.reloadData()
    }

    /**
     - Collection View Layout Delegate Method
     */
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.height - 40 , height: collectionView.frame.height - 40)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
