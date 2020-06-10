//
//  String+Extensions.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data: Data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertToImage() -> UIImage? {
        var image: UIImage? = nil
        if let url: URL = URL(string: Urls.icon + self + ".png"),
            let data: Data = try? Data(contentsOf: url) {
            image = UIImage(data: data)
        }
        
        return image
    }
}
