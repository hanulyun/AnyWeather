//
//  SearchWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import MapKit
import Promises

extension SearchWeatherViewController: SearchNamespace { }
class SearchWeatherViewController: UIViewController {
    
    static func instantiate(modelCount: Int) -> SearchWeatherViewController {
        let vc = self.instantiate(storyboardName: "SearchWeather") as! SearchWeatherViewController
        vc.count = modelCount
        return vc
    }
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    private var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    private var mapItems: [MKMapItem] = [MKMapItem]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var pendingPromise: Promise<Model.WeatherItem> = Promise<Model.WeatherItem>.pending()
    private var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
    }
    
    // 오늘 할 일.. search 기능 handler promise로 변경. select 했을 때 promie로 리스트화면에 데이터 전달
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func initializeUI() {
        prepareViewUI()
        prepareSearchBarUI()
    }
    
    private func prepareViewUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Title
        let titleLabel: UILabel = UILabel()
        let formatStr: NSMutableAttributedString = NSMutableAttributedString()
        formatStr.custom("도시, 우편번호 또는 공항 위치 입력", color: .white, font: .systemFont(ofSize: 12.adjusted))
        titleLabel.attributedText = formatStr
        navigationItem.titleView = titleLabel
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func prepareSearchBarUI() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false // 현재 뷰 사용으로 흐리게 false
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = self.searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        navigationItem.searchController = self.searchController
        
        // searchBar Textfield 부분 custom
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.textColor = .white
        
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .lightGray
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .darkGray
        
        searchBar.setValue("취소", forKey:"cancelButtonText")
        let cancelAtt: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelAtt, for: .normal)
    }
}

// MARK: - TableView DataSource & Delegate
extension SearchWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        var text: String?
        if mapItems.count > 0 {
            let item = mapItems[indexPath.row].placemark
            text = item.title
        } else if let searchText: String = searchController.searchBar.text,
            !searchText.isEmpty, mapItems.count == 0 {
            text = "발견된 결과가 없습니다."
        }
        
        cell.textLabel?.attributedText = getAttText(text ?? "")
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = text != ""
        return cell
    }
}

extension SearchWeatherViewController {
    private func getAttText(_ text: String) -> NSMutableAttributedString? {
        if let findText: String = searchController.searchBar.text {
            
            let attOriginText: NSMutableAttributedString = NSMutableAttributedString(string: text)
            let originCount: Int = text.count
            let originRange: NSRange = NSRange(location: 0, length: originCount)
            var range: NSRange = NSRange(location: 0, length: originCount)
            var rangeAtt: [NSRange] = [NSRange]()

            while (range.location != NSNotFound) {
                range = (attOriginText.string as NSString).range(of: findText, options: .caseInsensitive,
                                                                 range: range)
                rangeAtt.append(range)

                if (range.location != NSNotFound) {
                    let location: Int = range.location + range.length
                    range = NSRange(location: location, length: originCount - location)
                }
            }

            attOriginText.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.5),
                                       range: originRange)
            if self.mapItems.count > 0 {
                rangeAtt.forEach {
                    attOriginText.addAttribute(.foregroundColor, value: UIColor.white, range: $0)
                }
            }
            
            return attOriginText
        }
        return nil
    }
}

extension SearchWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mapItems.count > 0 {
            let item: MKMapItem = mapItems[indexPath.row]
            let lat: Double? = item.placemark.location?.coordinate.latitude
            let lon: Double? = item.placemark.location?.coordinate.longitude
            let city: String? = item.placemark.name
            
            if let lat = lat, let lon = lon {
                let mapItem: Model.WeatherItem = Model.WeatherItem(id: count, city: city,
                                                                   lat: lat, lon: lon)
                self.pendingPromise.fulfill(mapItem)
                
                self.searchController.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - SearchBar Delegate
extension SearchWeatherViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { self.mapItems = []; return }
        
        let request: MKLocalSearch.Request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        
        let search: MKLocalSearch = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else { self.mapItems = []; return }
            
            self.mapItems = response.mapItems
        }
    }
}

extension SearchWeatherViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}
