//
//  ListViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

// 구현할 것
// change 했을 때 값 변경하는 부분 viewModel에 저장 -> delegate로 메인에서 반영
// 추가 또는 삭제 시 viewModel 저장 -> delegate로 메인에서 반영

protocol ListViewContollerDelegate: class {
    func selectedIndex(index: Int)
    func changeWeatherList(isChanged: Bool)
}

class ListViewController: BaseViewController {
    
    private let topView: UIView = UIView()
    private let tableView: UITableView = UITableView()
    
    private let viewModel: MainWeatherViewModel?
    
    weak var delegate: ListViewContollerDelegate?
    
    var topOffset: NSLayoutConstraint!
    
    private var unit: TempUnit = .c {
        didSet {
            DispatchQueue.main.async {
                self.viewModel?.unit = self.unit
                self.tableView.reloadData()
            }
        }
    }
    
    private var models: [WeatherModel] = [WeatherModel]()
    
    init(viewModel: MainWeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.models = viewModel.tempoModel
        self.unit = viewModel.unit
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
        [tableView, topView].forEach { view.addSubview($0) }
        
        tableView.equalToEdges(to: self.view)

        if topOffset == nil {
            topOffset = topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
            topOffset.isActive = true
        }
        topView.equalToLeading(toAnchor: self.view.leadingAnchor)
        topView.equalToTrailing(toAnchor: self.view.trailingAnchor)
        topView.equalToHeight(self.getStatusHeight())
        
        topView.backgroundColor = .getWeatherColor(models.first?.current?.weather?.first?.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dropDelegate = self
        tableView.dragDelegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.dragInteractionEnabled = true
        
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.reuseId)
        tableView.register(ListTailTableViewCell.self, forCellReuseIdentifier: ListTailTableViewCell.reuseId)
    }
    
    private func changeDegree(to unit: TempUnit) {
        for index in models.indices {
            let temp: Double = models[index].current?.temp ?? 0
            models[index].current?.temp = temp.calcTempUnit(to: unit)
        }
        
        self.unit = unit
    }
    
    private func goToSearchViewCon() {
        let vc: SearchViewController = SearchViewController()
        vc.delegate = self
        let navi: UINavigationController = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
}

extension ListViewController: SearchViewControllerDelegate {
    func isSelectMapItem(city: String, lat: Double, lon: Double) {
        Log.debug("selected = \(city), \(lat), \(lon)")
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
            let isFirst: Bool = (indexPath.row == 0)
            cell.setData(model: model, isFirst: isFirst)
            return cell
        } else {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListTailTableViewCell.reuseId, for: indexPath)
                    as? ListTailTableViewCell else { fatalError("Failed to cast ListTailTableViewCell") }
            cell.buttonTapEvent = { [weak self] tag in
                if tag == .deg {
                    let changeUnit: TempUnit = (self?.unit == .c) ? .f : .c
                    self?.changeDegree(to: changeUnit)
                } else {
                    self?.goToSearchViewCon()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let statusHeight: CGFloat = self.getStatusHeight()
        if offsetY < -statusHeight {
            self.topOffset.constant = (offsetY * -1) - statusHeight
        } else {
            self.topOffset.constant = 0
        }
    }
}

extension ListViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if destinationIndexPath?.row == 0 {
            return UITableViewDropProposal(operation: .forbidden)
        }
        
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return UITableViewDropProposal(operation: .forbidden)
    }
    
    // drop 했을 때
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        var destiIndexPath: IndexPath
        
        if let indexPath: IndexPath = coordinator.destinationIndexPath {
            destiIndexPath = indexPath
        } else {
            let row: Int = tableView.numberOfRows(inSection: 0)
            destiIndexPath = IndexPath(row: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            self.reorderRows(tableView: tableView, coordinator: coordinator, destiIndexPath: destiIndexPath)
        }
    }
    
    // drag 시작 시
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.row == 0 {
            return []
        }
        
        let item: WeatherModel = models[indexPath.row]
        let itemProvider: NSItemProvider = NSItemProvider()
        let dragItem: UIDragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    // drop 했을 때. 여기서 작업할 것
    private func reorderRows(tableView: UITableView,
                             coordinator: UITableViewDropCoordinator, destiIndexPath: IndexPath) {
        if let item: UITableViewDropItem = coordinator.items.first,
            let sourceIndex: IndexPath = item.sourceIndexPath {
            tableView.performBatchUpdates({
                
                self.models.remove(at: sourceIndex.row)
                self.models.insert(item.dragItem.localObject as! WeatherModel, at: destiIndexPath.row)
                
                tableView.deleteRows(at: [sourceIndex], with: .automatic)
                tableView.insertRows(at: [destiIndexPath], with: .automatic)
                
                self.delegate?.changeWeatherList(isChanged: true)
                
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toRowAt: destiIndexPath)
        }
    }
}
