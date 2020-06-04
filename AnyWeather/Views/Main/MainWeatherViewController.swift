//
//  ViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class MainWeatherViewController: BaseViewController {
    
    let topview = UIView()
    let hview = UIView()
    private let tableView: UITableView = UITableView()

    var theight: NSLayoutConstraint!
    
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
        
//        tableView.register(<#T##aClass: AnyClass?##AnyClass?#>, forHeaderFooterViewReuseIdentifier: <#T##String#>)
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
    }
    
    override func configureAutolayouts() {
        view.addSubview(topview)
        view.addSubview(tableView)
        
        topview.equalToTop(toAnchor: self.guide.topAnchor)
        topview.equalToLeading(toAnchor: self.guide.leadingAnchor)
        topview.equalToTrailing(toAnchor: self.guide.trailingAnchor)
        if theight == nil {
            theight = topview.heightAnchor.constraint(equalToConstant: 200)
            theight.isActive = true
        }
        
//        tableView.equalToGuides(guide: self.guide)
        tableView.equalToTop(toAnchor: topview.bottomAnchor)
        tableView.equalToLeading(toAnchor: self.guide.leadingAnchor)
        tableView.equalToTrailing(toAnchor: self.guide.trailingAnchor)
        tableView.equalToBottom(toAnchor: self.guide.bottomAnchor)
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
            return 20
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            hview.backgroundColor = .brown
            return hview
        } else {
            return TimeWeatherView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        } else {
            return 180
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let zeroY = scrollView.contentOffset.y
        if zeroY < 130 {
            theight.constant = 200 - zeroY
        }
        hview.backgroundColor = UIColor.brown.withAlphaComponent(1 - (zeroY / 300))
    }
}
