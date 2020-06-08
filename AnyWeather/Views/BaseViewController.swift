//
//  BaseViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

/*
 추가 해결과제
 - Slpash에서 위치허용 물어본 후 진입 하는걸로
 - Hourly에서 일출, 일몰 표기
 - 일몰 이후일 경우 background 어둡게
 - 하단 버튼 누르면 사파리로 이동
 - 위치정보 허용 안했을 경우 pageControl
 - 온도 단위 변환했을 때 메인에서도 반영되게
 */

class BaseViewController: UIViewController {
    
    var guide: UILayoutGuide {
        return view.safeAreaLayoutGuide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureAutolayouts()
        bindData()
    }

    func configureAutolayouts() { }
    func bindData() { }
}
