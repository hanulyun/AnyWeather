//
//  ActionSheetController.swift
//  KPUI
//
//  Created by henry on 2018. 1. 22..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class ActionSheetController: AlertController {
    override internal class var alertStyle: UIAlertController.Style {
        return .actionSheet
    }
}
