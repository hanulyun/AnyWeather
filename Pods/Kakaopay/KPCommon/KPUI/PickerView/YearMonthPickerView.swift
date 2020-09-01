//
//  YearMonthPickerView.swift
//  KPUI
//
//  Created by Lyman.j on 2018. 8. 16..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class YearMonthPickerView: UIPickerView {
    //MARK: - Public
    public var onDateSelectedEvent: ((_ year: Int, _ month: Int)-> Void)?
    public func setMinMaxDate(minDate: Date, maxDate: Date) {
        self.minDate = minDate
        self.maxDate = maxDate
        
        var years: [Int] = []
        var months: [String] = []
        if let minComp = minComponent, let maxComp = maxComponent {
            let minYear = minComp.year!
            let maxYear = maxComp.year!
            
            for y in minYear ... maxYear {
                years.append(y)
            }
            
            for month in 0 ... 11 {
                months.append(DateFormatter().monthSymbols[month])
            }
            
        }
        self.years = years
        self.months = months
        setRowForCurrentDate(date: Date(), animation: false)
    }
    
    public var initialDate: Date? {
        didSet {
            guard let initDate = initialDate else {
                return
            }
            setRowForCurrentDate(date: initDate, animation: true)
        }
    }
    
    //MARK: - Private
    enum DatePickerComponent: Int {
        case year = 0
        case month = 1
    }
    
    private var minDate: Date? {
        didSet {
            minComponent = Calendar(identifier: .gregorian).dateComponents([.year,.month], from: minDate!)
        }
    }
    
    private var maxDate: Date? {
        didSet {
            maxComponent = Calendar(identifier: .gregorian).dateComponents([.year,.month], from: maxDate!)
        }
    }
    private var minComponent: DateComponents?
    private var maxComponent: DateComponents?
    private var years: [Int]!
    private var months: [String]!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initiate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initiate()
    }
    
    func initiate() {
        var years: [Int] = []
        var months: [String] = []
        
        if years.count == 0 {
            var year = Calendar(identifier: .gregorian).component(.year, from: Date())
            for _ in 1 ... 10 {
                years.append(year)
                year += 1
            }
        }
        
        var month = 0
        for _ in 0 ... 11 {
            months.append(DateFormatter().monthSymbols[month])
            month += 1
        }
        
        
        self.years = years
        self.months = months
        
        self.delegate = self
        self.dataSource = self
//        setRowForCurrentDate(date: Date(), animation: false)
    }
    
    private func setRowForCurrentDate(date: Date, animation: Bool) {
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: date)
        let currentMonth = Calendar(identifier: .gregorian).component(.month, from: date)
        if years.contains(currentYear) {
            self.selectRow(years.firstIndex(of: currentYear)! , inComponent: DatePickerComponent.year.rawValue, animated: animation)
        }
        self.selectRow(currentMonth - 1, inComponent: DatePickerComponent.month.rawValue, animated: animation)
    }
    
}


extension YearMonthPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case DatePickerComponent.year.rawValue:
            return years.count
        case DatePickerComponent.month.rawValue:
            return months.count
        default:
            return 0
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case DatePickerComponent.year.rawValue:
            return String(years[row])
        case DatePickerComponent.month.rawValue:
            return months[row]
        default:
            return nil
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedYear = self.selectedRow(inComponent: DatePickerComponent.year.rawValue) //0
        
        if selectedYear == self.years.count-1 {
            let maxMonth = maxComponent?.month ?? self.months.count
            if self.selectedRow(inComponent: DatePickerComponent.month.rawValue) > maxMonth-1 {
                self.selectRow(maxMonth-1, inComponent: DatePickerComponent.month.rawValue, animated: true)
            }
            
        }
        
    
        
        let year = years[self.selectedRow(inComponent: DatePickerComponent.year.rawValue)]
        let month = self.selectedRow(inComponent: DatePickerComponent.month.rawValue) + 1
        
        if let callback = onDateSelectedEvent {
            callback(year, month)
        }
    }
    
}
