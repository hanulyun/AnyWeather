//
//  ListViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

protocol ListViewContollerDelegate {
    func selectedIndex(index: Int)
}

class ListViewController: BaseViewController {
    
    private let tableView: UITableView = UITableView()
    
    private let viewModel: MainWeatherViewModel?
    
    var delegate: ListViewContollerDelegate?
    
    private var isC: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private var models: [WeatherModel] = [WeatherModel]()
    
    init(viewModel: MainWeatherViewModel?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        if let models = self.viewModel?.tempoModel {
            self.models = models
        }
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindData() {
        viewModel?.currentModels = { models in
            Log.debug("😀models = \(models)")
        }
    }
    
    override func configureAutolayouts() {
        view.addSubview(tableView)
        
        tableView.equalToEdges(to: self.view)
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.dragDelegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
//        tableView.dragInteractionEnabled = true
        tableView.isEditing = true
        
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.reuseId)
        tableView.register(ListTailTableViewCell.self, forCellReuseIdentifier: ListTailTableViewCell.reuseId)
    }
    
    private func changeDegree() {
        for index in models.indices {
            let temp: Double = models[index].current?.temp ?? 0
            if isC { // F로 변환
                models[index].current?.temp = temp * 1.8 + 32
            } else { // C로 변환
                models[index].current?.temp = (temp - 32) / 1.8
            }
        }
        isC = !isC
    }
}

extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.models.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseId, for: indexPath)
                    as? ListTableViewCell else { fatalError("Failed to cast ListTableViewCell") }
            let model: WeatherModel = self.models[indexPath.row]
            cell.setData(model: model, isFirst: indexPath.row == 0)
            return cell
        } else {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListTailTableViewCell.reuseId, for: indexPath)
                    as? ListTailTableViewCell else { fatalError("Failed to cast ListTailTableViewCell") }
            cell.buttonTapEvent = { [weak self] tag in
                if tag == .deg {
                    self?.changeDegree()
                } else {
                    Log.debug("tap!!!")
                }
            }
            return cell
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, self.models.count > 0 {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.selectedIndex(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Log.debug("😀index = \(sourceIndexPath.row), \(destinationIndexPath.row)")
        let move = models[sourceIndexPath.row]
        models.remove(at: sourceIndexPath.row)
        models.insert(move, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
//    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
//                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//
//    }
}
