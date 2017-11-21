//
//  SlideView.swift
//  GaanBoxN
//
//  Created by Machintos on 3/22/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import ImageSlideshow

class SlideView: UITableViewCell {

    static let shared = SlideView()
    static var isParsed = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
   
        backgroundColor = UIColor.clear
        setup()

        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(){
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnSildeImage))
        view_slide.addGestureRecognizer(recognizer)
        
        addSubview(view_slide)
        
        view_slide.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view_slide.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view_slide.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view_slide.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    // SlideView that represent the slideshow
    let view_slide : ImageSlideshow = {
        
        let view = ImageSlideshow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.appBlack
        view.slideshowInterval = 5.0
        view.pageControlPosition = PageControlPosition.hidden
        view.contentScaleMode = UIViewContentMode.scaleAspectFill
     
        return view
    }()
    
    func tapOnSildeImage(){
        
        let slideList = APIHandler.shared.slideSongList()
        
        if !Reach.isInternet && slideList.isEmpty {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AlertForNoInternet"), object: nil)
            return
        }
 
        if !slideList.isEmpty{
            
            // Get current slide image url
            let url = view_slide.currentSlideshowItem?.imageView.image?.accessibilityIdentifier
            
            // Get current tap slide song index
            for (index, item) in slideList.enumerated() {
                
                if item.slideSongImage == url {
                    AudioPlayerVC.songIndex = index
                }
            }
            Home.whichView = "slide"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "perform_segue_for_player_view"), object: nil)
        }
    }
    
    func networkStatusChanged(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo
        
        let status = userInfo?["Status"] as! String
        switch status {
        case "Offline":
            break
        default:
            if !SlideView.isParsed {
                setupSlideImage()
            }
        }
    }

    func setupSlideImage(){
    
        APIHandler.shared.getSliderImage { (imageResult) in

            self.view_slide.setImageInputs(imageResult)
            SlideView.isParsed = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

