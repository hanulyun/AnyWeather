//
//  ListWeatherViewController.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Promises

extension ListWeatherViewController: ListNamespace { }
class ListWeatherViewController: UIViewController, ReusePromiseable {
    
    typealias PromiseData = (changedList: Bool, selectedIndex: Int)
    
    static func instantiate() -> ListWeatherViewController {
        return self.instantiate(storyboardName: "ListWeather") as! ListWeatherViewController
    }
    
    //    static func presentListVC(on viewController: UIViewController,
    //                              models: [Model.Weather]) -> Promise<(models: [Model.Weather], index: Int)> {
    //        let vc = self.instantiate(storyboardName: "ListWeather") as! ListWeatherViewController
    //        vc.models = models
    //        vc.modalPresentationStyle = .currentContext
    //        viewController.present(vc, animated: true, completion: nil)
    //        return vc.pendingPromise
    //    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topMaskView: UIView!
    
    @IBOutlet weak var topMaskViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMaskViewHeightConstraint: NSLayoutConstraint!
    
    var models: [Model.Weather] = [Model.Weather]()
    
    private var unit: TempUnit = .celsius {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    private func initializeUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dropDelegate = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
        topMaskView.backgroundColor = UIColor.pay.getWeatherColor(model: models.first)
        view.bringSubviewToFront(topMaskView)
        topMaskViewHeightConstraint.constant = self.getStatusHeight()
    }
}

// MARK: Update UI
extension ListWeatherViewController {
    func changeDegree(to unit: TempUnit) { // tailCell buttonAction에서 접근
        for (index, model) in models.enumerated() {
            let temp: Double = model.current?.temp ?? 0
            models[index].current?.temp = temp.calcTempUnit(to: unit)
        }
        self.unit = unit
    }
}

// MARK: - TableView Datasource & Delegate
extension ListWeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? models.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListWeatherTableViewCell.reusableIdentifier,
                                              for: indexPath) as? ListWeatherTableViewCell
                else { fatalError("Failed to cast ListWeatherTableViewCell") }
            let model: Model.Weather = models[indexPath.row]
            cell.configure(model: model)
            return cell
        } else {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: ListWeatherTailTableViewCell.reusableIdentifier,
                                              for: indexPath) as? ListWeatherTailTableViewCell
                else { fatalError("Failed to cast ListWeatherTailTableViewCell") }
            cell.configure(from: self)
            return cell
        }
    }
}

extension ListWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, models.count > 0 {
            let _ = self.fulfill((false, indexPath.row))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0, models.count > 0 {
            if indexPath.row == 0, let isGps: Bool = models.first?.isGps, isGps {
                return false
            }
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model: Model.Weather = models[indexPath.row]
            let id: Int = model.id ?? 0
            
            Action.deleteLocalWeather(id: id).then { [weak self] _ in
                guard let self = self else { return }
                self.models.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                let _ = self.fulfill((true, 0))
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY: CGFloat = scrollView.contentOffset.y
        let statusHeight: CGFloat = self.getStatusHeight()
        if offsetY < -statusHeight {
            topMaskViewTopConstraint.constant = (offsetY * -1) - statusHeight
        } else {
            topMaskViewTopConstraint.constant = 0
        }
    }
}

extension ListWeatherViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if let indexPath = destinationIndexPath, indexPath.row < models.count {
            let model: Model.Weather = models[indexPath.row]
            if let isGps: Bool = model.isGps, isGps {
                return UITableViewDropProposal(operation: .forbidden)
            }
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
        let model: Model.Weather = models[indexPath.row]
        if let isGps: Bool = model.isGps, isGps {
            return []
        }
        
        if indexPath.section == 1 {
            return []
        }
        
        let item: Model.Weather = models[indexPath.row]
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
                
                let removeId: Int = sourceIndex.row
                let insertId: Int = destiIndexPath.row
                
                self.models.remove(at: removeId)
                self.models.insert(item.dragItem.localObject as! Model.Weather, at: insertId)
                
                tableView.deleteRows(at: [sourceIndex], with: .fade)
                tableView.insertRows(at: [destiIndexPath], with: .fade)
                
                Action.updateModels(self.models).then { [weak self] _ in
                    let _ = self?.fulfill((true, 0))
                }
                
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toRowAt: destiIndexPath)
        }
    }
}
