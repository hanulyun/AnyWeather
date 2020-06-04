//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lat: 51.51, lon: -0.13)
        APIManager.shared
            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
                Log.debug("model = \(model)")

        }
    }
}

