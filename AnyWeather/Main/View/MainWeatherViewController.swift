//
//  MainWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Promises

extension MainWeatherViewController: MainNamespace { }
class MainWeatherViewController: UIViewController {
    
    static func instantiate() -> MainWeatherViewController {
        return self.instantiate(storyboardName: "MainWeather") as! MainWeatherViewController
    }
    
    var pendingPromise: Promise<Int>?
    
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
            changeBackgroundViewColor(model: models[currentIndex])
        }
    }
    
    let locationClient: LocationClient = LocationClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        
        initializeAction()
        
        //        tempSaveLocal()
    }
    
    private func tempSaveLocal() {
        let model: Model.CoreWeatherItem = Model.CoreWeatherItem(id: 1, city: "서울", lat: 37.57, lon: 126.98)
        CoreDataManager.shared.saveLocalWeather(model).then { _ in
            Log.debug("saved success")
        }
        
        let model2 = Model.CoreWeatherItem(id: 2, city: "런던", lat: 51.51, lon: -0.13)
        CoreDataManager.shared.saveLocalWeather(model2).then { _ in
            Log.debug("saved success2")
        }
    }
    
    // 오늘 할 일: 코어데이터 프로미스로 메인 완성하기!
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
    
    private func initializeAction() {
        // GPS 권한 요청 후, GPS 사용 가능할 때 위치 받으면 API 호출
        Action.requestLocationPermission().then { _ in
            Main.location.currentLocation()
        }.then { [weak self] (location, city) in
            self?.requestGpsWeatherAPI(lat: location.latitude, lon: location.longitude, city: city)
        }
        
        // 내부 저장된 날씨 리스트 얻어와서 API 호출
        Action.getSavedLocalWeather().then { [weak self] savedWeathers in
            savedWeathers.forEach { [weak self] weather in
                self?.requestSavedWeatherAPI(with: weather)
            }
        }
    }
    
    @IBAction func actionListButton(_ sender: UIButton) {
        Log.debug("tap")
    }
}

// MARK: API Call
extension MainWeatherViewController {
    private func requestGpsWeatherAPI(lat: Double, lon: Double, city: String?) {
        API.weather(lat: lat, lon: lon).then { [weak self] model in
            guard let self = self else { return }
            var model: Model.Weather = model
            model.id = 0
            model.city = city
            model.isGps = true
            self.models.insert(model, at: 0)
        }
    }
    
    private func requestSavedWeatherAPI(with weather: Model.LocalWeather) {
        API.weather(lat: weather.lat, lon: weather.lon).then { [weak self] model in
            guard let self = self else { return }
            var model: Model.Weather = model
            model.id = Int(weather.id)
            model.city = weather.city
            model.isGps = false
            self.models.append(model)
            
            // API 호출 순서 상관없이 models 인스턴스 id 기준으로 정렬한다
            let sortModels = self.models.sorted { (m0, m1) -> Bool in
                (m0.id ?? 0) < (m1.id ?? 0)
            }
            self.models = sortModels
        }
    }
}

// MARK: Setup UI
extension MainWeatherViewController {
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
}

// MARK: - ScrollView Delegate
extension MainWeatherViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber: CGFloat = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let index: Int = Int(pageNumber)
        self.currentIndex = index
    }
}
