//
//  SearchViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import MapKit

protocol SearchViewControllerDelegate: class {
    func isSelectMapItem(city: String, lat: Double, lon: Double)
}

class SearchViewController: BaseViewController {
    
    private var searchController: UISearchController = UISearchController(searchResultsController: nil)
    private let tableView: UITableView = UITableView()
    
    weak var delegate: SearchViewControllerDelegate?
    
    private var mapItems: [MKMapItem] = [MKMapItem]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var pointAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        prepareViewUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func prepareViewUI() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Title
        let titleLabel: UILabel = UILabel()
        let formatStr: NSMutableAttributedString = NSMutableAttributedString()
        formatStr.custom("도시, 우편번호 또는 공항 위치 입력", color: .color(.main), font: .font(.subTiny))
        titleLabel.attributedText = formatStr
        navigationItem.titleView = titleLabel
        
        // blured backgroud
        let blurEffect: UIBlurEffect = UIBlurEffect(style: .dark)
        let blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        blurEffectView.equalToEdges(to: self.view)
        
        prepareTableView()
        prepareSearchBar()
    }
    
    private func prepareTableView() {
        view.addSubview(tableView)
        tableView.equalToGuides(guide: guide)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .clear
    }
    
    private func prepareSearchBar() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false // 현재 뷰 사용으로 흐리게 false
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = self.searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        
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

            attOriginText.addAttribute(.foregroundColor, value: UIColor.color(.translucentMain),
                                       range: originRange)
            if self.mapItems.count > 0 {
                rangeAtt.forEach {
                    attOriginText.addAttribute(.foregroundColor, value: UIColor.color(.main), range: $0)
                }
            }
            
            return attOriginText
        }
        return nil
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let resultCount: Int = mapItems.count
        return resultCount == 0 ? 1 : resultCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell()
        var text: String? = ""
        if mapItems.count > 0 {
            let item = mapItems[indexPath.row].placemark
            text = appendLocalTitles(item)
        } else if let searchText: String = searchController.searchBar.text,
            !searchText.isEmpty, mapItems.count == 0 {
            text = "발견된 결과가 없습니다."
        }
        
        cell.textLabel?.attributedText = getAttText(text!)
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = text != ""
        return cell
    }
    
    private func appendLocalTitles(_ mark: MKPlacemark) -> String {
        var appendTitle: String = ""
        let titles: [String?] = [mark.locality, mark.administrativeArea, mark.isoCountryCode, mark.country]
        
        for title in titles {
            if let t: String = title {
                if appendTitle.isEmpty {
                    appendTitle.append(t)
                } else {
                    appendTitle.append(", \(t)")
                }
            }
        }
        
        return appendTitle
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mapItems.count > 0 {
            let item: MKMapItem = mapItems[indexPath.row]
            let lat: Double? = item.placemark.location?.coordinate.latitude
            let lon: Double? = item.placemark.location?.coordinate.longitude
            let mark: MKPlacemark = item.placemark
            let titles: [String?] = [mark.locality, mark.administrativeArea, mark.isoCountryCode, mark.country]
            var city: String? = item.placemark.locality
            
            for title in titles {
                if let unwrapTitle: String = title {
                    city = unwrapTitle
                    break
                }
            }
            
            if let lat = lat, let lon = lon, let city = city {
                self.delegate?.isSelectMapItem(city: city, lat: lat, lon: lon)
                self.searchController.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { self.mapItems = []; return }
    
        let request: MKLocalSearch.Request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText

        let search: MKLocalSearch = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else { self.mapItems = []; return }

            let center: CLLocationCoordinate2D = response.boundingRegion.center
            self.pointAnnotation.title = searchController.searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: center.latitude,
                                                                     longitude: center.longitude)

            self.mapItems = response.mapItems
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}
