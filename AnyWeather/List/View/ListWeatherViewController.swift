//
//  ListWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ListWeatherViewController: UIViewController, ListNamespace {
    
    static func instantiate() -> ListWeatherViewController {
        return self.instantiate(storyboardName: "ListWeather") as! ListWeatherViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topMaskView: UIView!
    
    @IBOutlet weak var topMaskViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMaskViewHeightConstraint: NSLayoutConstraint!
    
    var models: [Model.Weather] = [Model.Weather]()
    
    private var unit: TempUnit = .celsius {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    private func initializeUI() {
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.dropDelegate = self
//        tableView.dragDelegate = self
        
        topMaskView.backgroundColor = UIColor.pay.getWeatherColor(model: models.first)
        view.bringSubviewToFront(topMaskView)
        topMaskViewHeightConstraint.constant = self.getStatusHeight()
    }
}

// MARK: Update UI
extension ListWeatherViewController {
    func changeDegree(to unit: TempUnit) { // tailCell buttonAction에서 접근
        for (index, model) in models.enumerated() {
            let temp: Double = model.current?.temp ?? 0
            models[index].current?.temp = temp.calcTempUnit(to: unit)
        }
        self.unit = unit
    }
}

// MARK: - TableView Datasource & Delegate
extension ListWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? models.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListWeatherTableViewCell.reusableIdentifier,
                                              for: indexPath) as? ListWeatherTableViewCell
                else { fatalError("Failed to cast ListWeatherTableViewCell") }
            let model: Model.Weather = models[indexPath.row]
            cell.configure(model: model)
            return cell
        } else {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListWeatherTailTableViewCell.reusableIdentifier,
                                              for: indexPath) as? ListWeatherTailTableViewCell
                else { fatalError("Failed to cast ListWeatherTailTableViewCell") }
            cell.configure(from: self)
            return cell
        }
    }
}

extension ListWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, models.count > 0 {
            Log.debug("index = \(indexPath.row)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let statusHeight: CGFloat = self.getStatusHeight()
        if offsetY < -statusHeight {
            topMaskViewTopConstraint.constant = (offsetY * -1) - statusHeight
        } else {
            topMaskViewTopConstraint.constant = 0
        }
    }
}
