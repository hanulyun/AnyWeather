//
//  MainViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: BaseViewController {
    
    private let backgroundView: UIView = UIView().filledStyle(color: .darkGray)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "위치권한을 허용하거나\n선호 지역을 추가해보세요."
        label.textAlignment = .center
        label.textColor = .color(.translucentMain)
        return label
    }()
    
    lazy var hScrollView: UIScrollView = {
        let scrollView = UIScrollView().basicStyle()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let hStackView: UIStackView = UIStackView().basicStyle(.horizontal)
    
    private let footerView: FooterView = FooterView()
    
    private let viewModel: WeatherViewModel = WeatherViewModel()
    private var observer: NSObjectProtocol?
    private var onObserver: Bool = false // 첫 실행 시 observer 호출되는 부분 거르는 flag
    
    private var gpsIsPermit: ((Bool) -> Void)? // 권한 요청 후 권한 허용 상태에 따라 API 요청
    private var isCompletedGetGps: ((_ lat: CGFloat, _ lon: CGFloat) -> Void)?
    
    var models: [WeatherModel] = [WeatherModel]() {
        didSet {
            self.footerView.setPageControl(models: self.models)
            self.changeBackColor(model: self.models.first)
            
            self.setHStackView()
            self.setScrollOffsetWithPageIndex(index: self.currentIndex)
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            self.footerView.selectedPage(self.currentIndex)
            self.changeBackColor(model: self.models[self.currentIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonEvent()
        enterForeground()
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func bindData() {
        viewModel.getSearchWeather()
                
        viewModel.currentModels = { [weak self] models in
            self?.models = models
        }
        
        gpsIsPermitCheckAndGetWeather()
    }
    
    override func configureAutolayouts() {
        [backgroundView, hScrollView, footerView].forEach { view.addSubview($0) }
        backgroundView.addSubview(emptyLabel)
        hScrollView.addSubview(hStackView)
        
        backgroundView.equalToEdges(to: self.view)
        emptyLabel.equalToCenter(to: backgroundView)
        
        hScrollView.equalToGuides(guide: self.guide)
        
        hStackView.equalToTop(toAnchor: hScrollView.topAnchor)
        hStackView.equalToLeading(toAnchor: hScrollView.leadingAnchor)
        hStackView.equalToTrailing(toAnchor: hScrollView.trailingAnchor)
        hStackView.equalToBottom(toAnchor: footerView.topAnchor)
        
        footerView.equalToBottom(toAnchor: guide.bottomAnchor)
        footerView.equalToLeading(toAnchor: guide.leadingAnchor)
        footerView.equalToTrailing(toAnchor: guide.trailingAnchor)
        footerView.equalToHeight(50.adjusted)
    }
    
    private func enterForeground() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main, using: { [weak self] _ in
                guard let self = self else { return }
                
                if self.onObserver {
                    self.viewModel.requestWhenForeground()
                    self.gpsIsPermitCheckAndGetWeather()
                } else {
                    self.onObserver = true
                }
        })
    }
    
    private func buttonEvent() {
        footerView.listContainerButton.addTarget(self, action: #selector(listButtonTap), for: .touchUpInside)
    }
    
    @objc func listButtonTap() {
        let vc: ListViewController = ListViewController(viewModel: self.viewModel)
        vc.delegate = self
        vc.modalPresentationStyle = .currentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    private func changeBackColor(model: WeatherModel?) {
        UIView.animate(withDuration: 0.5) {
            self.emptyLabel.isHidden = !(self.models.count == 0)
            self.backgroundView.backgroundColor = .getWeatherColor(model: model)
        }
    }
    
    private func setHStackView() {
        self.hStackView.removeAllSubviews()
        for model in self.models {
            let fullView: MainFullView = MainFullView()
            fullView.setData(model: model)
            self.hStackView.addArrangedSubview(fullView)
        }
    }
    
    private func setScrollOffsetWithPageIndex(index: Int) {
        let xOffset: CGFloat = CommonSizes.screenWidth * CGFloat(index)
        hScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
    }
    
    // 현재 위치 날씨 요청
    // 현재 위치를 받아오면 API request 후 model array에 저장
    private func gpsIsPermitCheckAndGetWeather() {
        LocationManager.shared.locationAuthorCall(delegate: self)
        
        gpsIsPermit = { [weak self] isPermited in
            guard let self = self else { return }
            if isPermited {
                LocationManager.shared.startUpdateLocation()
                
                self.isCompletedGetGps = { [weak self] (lat, lon) in
                    guard let self = self else { return }
                    
                    if !self.viewModel.getGpsFlag {
                        self.viewModel.getGpsFlag = true
                        
                        self.viewModel.requestGpsLocation(lat: Double(lat), lon: Double(lon))
                    }
                }
            } else {
                self.viewModel.onGps = false
            }
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber: CGFloat = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let index: Int = Int(pageNumber)
        self.currentIndex = index
    }
}

extension MainViewController: ListViewContollerDelegate {
    func selectedIndex(index: Int) {
        self.currentIndex = index
        self.setScrollOffsetWithPageIndex(index: index)
    }
    
    func changeWeatherList(isChanged: Bool) {
        if isChanged {
            self.models = viewModel.weatherModels
        }
    }
}

// MARK: - Location Delegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.shared.requestLocation()
            self.gpsIsPermit?(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let longitude: CLLocationDegrees = location.coordinate.longitude
        let latitude: CLLocationDegrees = location.coordinate.latitude
        
        self.isCompletedGetGps?(CGFloat(latitude), CGFloat(longitude))
                
        let findLocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr")
        // 위치정보를 사용할 때
        geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { [weak self] (place, error) in
            if let address: [CLPlacemark] = place {
                self?.viewModel.gpsCity = address.last?.locality
                Log.debug("address = \(String(describing: address.last?.locality))")
            }
            if let error = error {
                Log.debug("errorGeoCoder = \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.debug("errorManager = \(error)")
    }
}
