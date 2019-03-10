//
//  CCIIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation

class CCIIndicator: BaseIndicator {
   
    override class var nameKey:String
    {
        return "indicators.name.CCI"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.CCI"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.oscilators
    }

}
