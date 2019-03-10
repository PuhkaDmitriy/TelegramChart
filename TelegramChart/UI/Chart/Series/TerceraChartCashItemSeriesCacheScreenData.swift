//
//  TerceraChartCashItemSeriesCacheScreenData.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

enum  TerceraChartCashItemSeriesCacheScreenDataDateChangeType
{
    case none
    case day
    case week
    case month
    case year
}

class TerceraChartCashItemSeriesCacheScreenData: TimeHolder {
    var open : Double = 0;
    var high : Double = 0;
    var low : Double = 0;
    var close : Double = 0;
    var volume : Double = 0;
    var hole : Bool = false;
    var isDayHigh : Bool = false;
    var isDayLow : Bool = false;
    var isMainSession = true;
    var separator = false;
    var dateChangeType : TerceraChartCashItemSeriesCacheScreenDataDateChangeType = .none;
    
    var baseIntervalIndex : Int = 0;
    
    var profileData : ProfileData = ProfileData();
    
    class ProfileData: NSObject
    {}
}
