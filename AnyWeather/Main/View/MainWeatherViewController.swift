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
            setupPageControl(models: models)
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
    
    let locationClient: LocationClient = LocationClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        
//        requestMainWeatherAPI()
        // GPS 권한 요청 후, GPS 사용 가능할 때 위치 받으면 API 호출
        Action.requestLocationPermission().then { _ in
            Main.location.currentLocation()
        }.then { [weak self] (location, city) in
            self?.requestGpsWeatherAPI(lat: location.latitude, lon: location.longitude, city: city)
        }
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
    
    private func requestGpsWeatherAPI(lat: Double, lon: Double, city: String?) {
        API.weather(lat: lat.description, lon: lon.description).then { [weak self] model in
            guard let self = self else { return }
            var model: Model.Weather = model
            model.id = 0
            model.city = city
            model.isGps = true
            self.models.insert(model, at: 0)
        }
    }
    
    private func requestSavedWeatherAPI(id: Int, lat: Double, lon: Double, city: String?) {
        API.weather(lat: lat.description, lon: lon.description).then { [weak self] model in
            guard let self = self else { return }
            var model: Model.Weather = model
            model.id = id
            model.city = city
            model.isGps = false
            self.models.append(model)
            
            let sortModels = self.models.sorted { (m0, m1) -> Bool in
                (m0.id ?? 0) < (m1.id ?? 0)
            }
            self.models = sortModels
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
    
    private func setupPageControl(models: [Model.Weather]) {
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
