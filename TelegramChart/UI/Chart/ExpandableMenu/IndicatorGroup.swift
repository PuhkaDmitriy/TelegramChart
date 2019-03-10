//
//  IndicatorGroup.swift
//  Protrader 3
//
//  Created by Yuriy on 23/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class IndicatorGroup: ExpandableObject {
    var indicatorType:EIndicatorType?
    var name:String
    {
        get
        {
            if indicatorType != nil
            {
                return indicatorType!.toString()
            }
            else
            {
                return NSLocalizedString("indicators.addedIndicators", comment: "")
            }
        }
    }
    
    init(indicatorType:EIndicatorType) {
        self.indicatorType = indicatorType
        super.init()
    }
    
    override init() {
        // для группы активных индикаторов
        super.init()
    }
}
