//
//  WeekWeatherView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class WeekWeatherView: CustomView {
    private let tableView: UITableView = UITableView()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.brown)

        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureAutolayouts() {
        configureTableView()
        
        addSubview(tableView)
        tableView.equalToEdges(to: self)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(WeekSummaryTVC.self, forCellReuseIdentifier: WeekSummaryTVC.reuseIdentifer)
    }
}

extension WeekWeatherView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: WeekSummaryTVC.reuseIdentifer, for: indexPath)
            as? WeekSummaryTVC else { fatalError("Failed to cast WeekSummaryTVC") }
        cell.setData()
        return cell
    }
}

extension WeekWeatherView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
