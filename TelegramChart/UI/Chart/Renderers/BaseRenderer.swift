//
//  BaseRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 24/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class BaseRenderer : NSObject{
    weak var chartBase:ChartBase?
    var series : TerceraChartCashItemSeries?;
    var rectangle:CGRect = .zero
    var useInAutoScale : Bool
    {
        get{return true}
    }
    var visible : Bool = true;
    
    init(chartBase:ChartBase) {
        self.chartBase = chartBase
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        
    }
    
    func processTap(recognizer:UITapGestureRecognizer, coordinate:CGPoint) -> Bool
    {
        //For override
        return false
    }
    
    func findMinMax(_ min : inout Double, max : inout Double, window : ChartWindow) -> Bool
    {
        min = Double.greatestFiniteMagnitude;
        max = -Double.greatestFiniteMagnitude;
        
        return false;
    }
}
