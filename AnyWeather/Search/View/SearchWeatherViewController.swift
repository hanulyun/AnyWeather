//
//  SearchWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension SearchWeatherViewController: SearchNamespace { }
class SearchWeatherViewController: UIViewController {
    
    static func instantiate() -> SearchWeatherViewController {
        return self.instantiate(storyboardName: "SearchWeather") as! SearchWeatherViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
