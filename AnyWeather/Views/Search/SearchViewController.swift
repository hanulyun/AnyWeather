//
//  SearchViewController.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

// https://medium.com/@pravinbendre772/search-for-places-and-display-results-using-mapkit-a987bd6504df
// https://devmjun.github.io/archive/SearchController

class SearchViewController: UIViewController {
    
    private var searchController: UISearchController = UISearchController()
    
    override func viewDidLoad() {
                        
        prepareViewUI()
        prepareSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    private func prepareViewUI () {
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
    }
    
    private func prepareSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false // 현재 뷰 사용으로 흐리게 false
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = self.searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "검색"
        self.navigationItem.searchController = self.searchController
        
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField

        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .lightGray
        
        searchBar.setValue("취소", forKey:"cancelButtonText")
        let cancelAtt: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelAtt, for: .normal)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
