//
//  TerceraChartCashItemSeriesDataBlock.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartCashItemSeriesDataBlock: Any {
    var leftTime : Int64;
    var leftIndex : Int = -1;
    var isHole : Bool = false;
    
    private init()
    {
        self.leftIndex = -1;
        self.leftTime = -1;
    
    }
    
    init(index : Int, time : Int64)
    {
        self.leftIndex = index;
        self.leftTime = time;
    }
}

class TerceraChartCashItemSeriesPaddingDataBlock : TerceraChartCashItemSeriesDataBlock
{
    init()
    {
        super.init(index: 0, time: 0);
    }
}

