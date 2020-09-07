//
//  ListWeatherTailTableViewCell.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Promises

extension ListWeatherTailTableViewCell: ListNamespace { }
class ListWeatherTailTableViewCell: UITableViewCell, ReusePromiseable {
    typealias PromiseData = Model.WeatherItem
    
    @IBOutlet weak var degLabel: UILabel!
    
    var isCflag: Bool = true
    private var fromVC: ListWeatherViewController?
    
    func configure(from viewController: ListWeatherViewController) {
        setupDegLabel(isCflag)
        fromVC = viewController
    }
    
    private func setupDegLabel(_ isC: Bool) {
        let formatStr: NSMutableAttributedString = NSMutableAttributedString()
        let transWhite: UIColor = UIColor.white.withAlphaComponent(0.5)
        let cColor: UIColor = isC ? .white : transWhite
        let fColor: UIColor = isC ? transWhite : .white
        let font: UIFont = .systemFont(ofSize: 20.adjusted)
        
        formatStr.custom("\(List.degSymbol)C", color: cColor, font: font)
        formatStr.custom(" / ", color: transWhite, font: font)
        formatStr.custom("\(List.degSymbol)F", color: fColor, font: font)
        
        degLabel.attributedText = formatStr
    }
    
    @IBAction func degButtonAction(_ sender: UIButton) {
        isCflag = !isCflag
        setupDegLabel(isCflag)
        
        guard let fromVC = self.fromVC else { return }
        fromVC.changeDegree(to: isCflag ? .celsius : .fahrenheit)
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        guard let fromVC = self.fromVC else { return }
        let vc: SearchWeatherViewController
            = SearchWeatherViewController.instantiate(modelCount: fromVC.models.count)
        let navVC: UINavigationController = UINavigationController(rootViewController: vc)
        fromVC.present(navVC, animated: true, completion: nil)
        
        vc.pendingPromise.then { item in
            Action.saveLocalWeather(item).then { [weak self] _ in
                self?.fulfill(item)
            }
        }
    }
}
