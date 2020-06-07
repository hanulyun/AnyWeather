//
//  ImageUrlLoader.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

private let imageCache: NSCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    private var imageUrl: URL?
    
    func loadImageUrl(_ urlString: String?) {
        if let str: String = urlString,
            let url: URL = URL(string: Urls.icon + str + ".png") {
            image = nil
            self.imageUrl = url
            
            if let imageFromCache: UIImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
                self.image = imageFromCache
                return
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let unwrapData: Data = data, let imageToCache: UIImage = UIImage(data: unwrapData) {
                        if self.imageUrl == url {
                            self.image = imageToCache
                        }
                        imageCache.setObject(imageToCache, forKey: url as AnyObject)
                    }
                }
            }.resume()
        }
    }
}
