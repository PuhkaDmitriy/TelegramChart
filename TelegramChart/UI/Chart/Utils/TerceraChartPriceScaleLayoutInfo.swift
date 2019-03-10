//
//  TerceraChartPriceScaleLayoutInfo.swift
//  Protrader 3
//
//  Created by Yuriy on 08/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartPriceScaleLayoutInfo: NSObject
{
    var preferredWidthScales : CGFloat = 0;
    var preferredWidthScalesLeft : CGFloat = 0;
    
    //Эти условия подразумеваю добавление правой шкалы
    var hasOverlays = false;
    var hasDoubledIndicator = false;
}

