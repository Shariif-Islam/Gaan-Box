//
//  CollectionViewVC.swift
//  GaanBoxN
//
//  Created by AdBox on 4/4/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class CollectionViewVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    var navTitle = ""
    var array_seeAllList = Array<AnyObject>()
    private var selectedIndex = 0
    
    // MARK: Oerride func
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set navigation title
        self.title = navTitle
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Open detail view
        if segue.identifier == "segue_detailedFromCollectionView" {
            
            let controller = segue.destination as! DetailedView
            controller.selectedIndex = selectedIndex
            controller.array_detailed.removeAll()
            controller.array_album.removeAll()
            controller.array_singer.removeAll()

            if Home.whichView == "Album" {
                controller.array_album = array_seeAllList as! [Album]
            } else if Home.whichView == "Singer" {
                controller.array_singer = array_seeAllList as! [Singer]
            }
        }
    }
    // MARK: Collection View Data Source Delegate Method
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_seeAllList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        if Home.whichView == "Album" {

           let albums = self.array_seeAllList as!  [Album]
            
            cell.lb_title.text = albums[indexPath.row].albumName
            cell.iv_image.af_setImage(withURL: URL(string: albums[indexPath.row].albumCoverImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
            
        } else if Home.whichView == "Singer" {
            
            let singers = self.array_seeAllList as!  [Singer]
            
            cell.lb_title.text = singers[indexPath.row].singerName
            cell.iv_image.af_setImage(withURL: URL(string: singers[indexPath.row].singerImageURL)!, placeholderImage: UIImage(named: "image_placeholder_Square")!,imageTransition: .crossDissolve(1.0))
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "segue_detailedFromCollectionView", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Collection View Layout Delegate Method
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:UIScreen.main.bounds.width / 3 - 2 , height: UIScreen.main.bounds.width / 3 - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
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
