//
//  UIImageView+Caching.swift
//  ChittrChattr
//
//  Created by Mycah on 4/14/18.
//  Copyright © 2018 Mycah. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImageUsingCacheWithUrlString(urlString : String){
        
        self.image = nil
        
        //Check cache for image
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
            return
        }
        
        //Retrieve Image from the URL
        let url = URL(string: urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if data != nil {
                if let downloadedImage = UIImage(data: data!){
                
                    DispatchQueue.main.async(execute: {
                        print("Profile image has been retrieved")
                        
                        //Cache the images
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    })
                }
            }else{
                return
            }
        })
        task.resume()
    }
    
}
