//
//  MainWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

extension MainWeatherViewController: MainNamespace { }
class MainWeatherViewController: UIViewController {
    
    static func instantiate() -> MainWeatherViewController {
        return self.instantiate(storyboardName: "MainWeather") as! MainWeatherViewController
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var hScrollView: UIScrollView!
    @IBOutlet weak var hStackView: UIStackView!
    
    @IBOutlet weak var pagerControlView: UIView!
    private lazy var controlView = CustomPagerControl.instantiate()
    
    private var currentIndex: Int = 0 {
        didSet {
            controlView.selectIndex(currentIndex)
//            self.changeBackColor(model: self.models[self.currentIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        controlView.setControls(controls: [.gps])
    }
    
    private func initializeUI() {
        pagerControlView.backgroundColor = .clear
        pagerControlView.addSubview(controlView)
        
        controlView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlView.centerXAnchor.constraint(equalTo: pagerControlView.centerXAnchor),
            controlView.centerYAnchor.constraint(equalTo: pagerControlView.centerYAnchor)
        ])
        
        hScrollView.delegate = self
    }
    
    private func changeBackColor(model: WeatherModel?) {
        UIView.animate(withDuration: 0.5) {
//            self.emptyLabel.isHidden = !(self.models.count == 0)
            self.backgroundView.backgroundColor = .getWeatherColor(model: model)
        }
    }
    
    @IBAction func actionListButton(_ sender: UIButton) {
        Log.debug("tap")
    }
}

extension MainWeatherViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber: CGFloat = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let index: Int = Int(pageNumber)
        self.currentIndex = index
    }
}
