//
//  IndicatorObject.swift
//  Protrader 3
//
//  Created by Yuriy on 23/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class IndicatorObject: ExpandableObject {
    var isActive = false
    let indicator:BaseIndicator
    var closure:(()->Void)?
    var closeClosure:(()->Void)?
    var editClosure:(()->Void)?
    
    init(indicator:BaseIndicator, closure:(()->Void)? = nil, editClosure:(()->Void)? = nil, closeClosure:(()->Void)? = nil) {
        self.indicator = indicator
        self.closure = closure
        self.editClosure = editClosure
        self.closeClosure = closeClosure
    }
}
