//
//  TPToolView.swift
//  Protrader 3
//
//  Created by Yuriy on 19/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TPToolView: ClosingOrderToolView {
    override var orderType:PFOrderType{
        get{
            return .limit
        }
    }
    
    override var leftText:String?
        {
        get{
            return "TP"
        }
    }
}
