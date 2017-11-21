
import UIKit
import ImageSlideshow

class APIHandler: NSObject {

    var array_ofSlideImage      = [ImageSource]()
    static let shared           = APIHandler()
    
    /***
     - request for slide song, from that slide song request for slide image
     - store slide images into an array and send to home from which it is requested
     */
    func getSliderImage(callback:@escaping (Array<ImageSource> ) -> ()) {
        
        APIManager.shared.parseAPIData(promotedSongsAPIURL, dataType: "imageSlider", callback: { (responseData) in
            
            self.array_ofSlideImage.removeAll()
            
            for value in responseData as! [Slide]
            {
                let imageURL = value.slideSongImage
    
                APIManager.shared.parseImage(imageURL, callback: { (image) in
                    
                    //set identifier each image with its url for access it later
                    image.accessibilityIdentifier = imageURL
                    let imageOf = ImageSource(image: image)
                    self.array_ofSlideImage.append(imageOf)
          
                    callback(self.array_ofSlideImage)
                })
            }
        })
    }

    /***
     - request for subscription status
     */
    func parseSubscriptionStatusRequest(_ apiURL : String, callback:@escaping (String) -> ())
    {
        APIManager.shared.parseSubscriptionStatusRequest(apiURL) { (message) in
            
            callback(message)
        }
    }
    /***
     - request for all audio songs data for view
     */
    open func parseAPIData(_ apiURL : String, dataType : String, callback:@escaping ([Any]) -> ())
    {
        APIManager.shared.parseAPIData(apiURL, dataType: dataType)
        { (responseData) in
            
            callback(responseData)
        }
    }
    
    /***
     - parsing image data
     */
    func parseImage(_ apiURL : String, callback:@escaping (UIImage) -> ())  {
        
        APIManager.shared.parseImage(apiURL, callback:
            { (image) in
                
                callback(image)
        })
    }
    /***
     - send slide song list
     */
    func slideSongList() -> [Slide] {
        
        return APIManager.shared.slideSongList()
    }
}
