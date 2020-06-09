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
 - Slpash에서 위치허용 물어본 후 진입 하는걸로..
 - 첫 권한 허용 시 location 요청 여부
 - 권한 비허용 시 어떻게 되는지 확인할 것.
 - 하단 버튼 누르면 사파리로 이동
 - 온도 단위 변환했을 때 메인에서도 반영되게
 */

class BaseViewController: UIViewController {
    
    var guide: UILayoutGuide {
        return view.safeAreaLayoutGuide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        configureAutolayouts()
        bindData()
    }

    func configureAutolayouts() { }
    func bindData() { }
    
    func getStatusHeight() -> CGFloat {
        if #available(iOS 13.0, *) {
            let window: UIWindow? = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        return UIApplication.shared.statusBarFrame.height
    }
}
