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
        
    private var models: [Model.Weather] = [Model.Weather]() {
        didSet {
            setPageControl(models: models)
            changeBackgroundViewColor(model: models.first)
            
            setupHStackView()
        }
    }
    
    private var currentIndex: Int = 0 {
        didSet {
            controlView.selectIndex(currentIndex)
//            self.changeBackColor(model: self.models[self.currentIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        
        requestMainWeatherAPI()
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
    
    private func requestMainWeatherAPI() {
        API.weather(lat: "37.57", lon: "126.98").then { [weak self] model in
            self?.models.append(model)
        }
    }
    
    private func setupHStackView() {
        hStackView.removeAllSubviews()
        for model in models {
            let fullView: MainWeatherFullView = MainWeatherFullView.instantiate()
            fullView.initializeUI(model: model)
            hStackView.addArrangedSubview(fullView)
        }
    }
    
    private func setScrollOffsetWithPageIndex(index: Int) {
        let xOffset: CGFloat = CommonSizes.screenWidth * CGFloat(index)
        hScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
    }
    
    private func changeBackgroundViewColor(model: Model.Weather?) {
        UIView.animate(withDuration: 0.5) {
            self.emptyLabel.isHidden = !(self.models.count == 0)
            self.backgroundView.backgroundColor = UIColor.pay.getWeatherColor(model: model)
        }
    }
    
    private func setPageControl(models: [Model.Weather]) {
        var controls: [PagerControlItem] = []
        
        for model in models {
            var control: PagerControlItem = .dot
            if let isGps: Bool = model.isGps, isGps {
                control = .gps
            }
            controls.append(control)
        }
        controlView.setControls(controls: controls)
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
