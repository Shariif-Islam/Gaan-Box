//
//  Helper.swift
//  GaanBoxN
//
//  Created by Machintos on 3/12/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class Helper: NSObject {
    
    static var shared = Helper()

    /**
     - Audio player duration
     */
    func formatTime(fromSeconds totalSeconds:Int) -> String
    {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        
        if totalSeconds < 60{
            if seconds < 10{
                return "00:0\(seconds)"
            }
            return "00:\(seconds)"
        } else {
            if minutes < 10 {
                if minutes < 10 && seconds < 10 {
                    return "0\(minutes):0\(seconds)"
                }
                else {
                    return "0\(minutes):\(seconds)"
                }
            } else {
                if seconds < 10 {
                    return "\(minutes):0\(seconds)"
                }
                else {
                    return "\(minutes):\(seconds)"
                }
            }
        }
    }
    
    /**
     - Resize image
     */
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x:0, y:0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    /**
     - Create now playing frame
     */
    func createFrames() -> [UIImage] {
        // Setup "Now Playing" Animation Bars
        var animationFrames = [UIImage]()
        for i in 0...3 {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        
        for i in stride(from: 2, to: 0, by: -1) {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        return animationFrames
    }
}





