//
//  BaseViewController.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

/*
 기존 앱에서 페이앱 스타일로
 [해결과제]
 # MVVM -> MVC
 # Codebase UI -> Interface Builder (Storyboard, Xib)
 # 폴더 구조 및 NameSpace
 
 [추가 해결과제]
 # todayDetail 부분 파싱해보기
 */

/*
개발 방법론.. 2주, 페이앱 기반
Namespace, Promise

kakaopayFramework common

헨리, 칼리, 프레디, 로건
프로젝트 구조, 프레임워크 구조
꼭 봐야하는 코드들..
*/

class BaseViewController: UIViewController, ViewProtocol {
    
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

}
