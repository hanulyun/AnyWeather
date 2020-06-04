//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    private let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // lat: 51.51, lon: -0.13)
//        APIManager.shared
//            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
//                Log.debug("model = \(model)")
//
//        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
    }
    
    override func configureAutolayouts() {
        view.addSubview(tableView)
        
        tableView.equalToGuides(guide: self.guide)
        
    }
}

extension MainWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.backgroundColor = .purple
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekSummaryTVC.reuseIdentifer, for: indexPath) as? WeekSummaryTVC else { fatalError("Fail") }
            cell.setData()
            return cell
        }
    }
}

extension MainWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } else {
            return UITableView.automaticDimension
        }
    }
}
