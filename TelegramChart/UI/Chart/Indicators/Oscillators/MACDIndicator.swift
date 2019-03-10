//
//  MACDIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation

class MACDIndicator: BaseIndicator {
   
    override class var nameKey:String
    {
        return "indicators.name.MACD"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.MACD"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.oscilators
    }
}
