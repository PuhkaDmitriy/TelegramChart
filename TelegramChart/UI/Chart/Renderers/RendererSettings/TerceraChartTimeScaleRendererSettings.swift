//
//  TerceraChartTimeScaleRendererSettings.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartTimeScaleRendererSettings: TerceraChartNumberScaleRendererSettings {
    var daySeparatorPen : Pen = Pen(color: Colors.instance.chart_DaySeparateColor.cgColor, lineWidth: 1, dashStyle: .shaped)
    var weekSeparatorPen : Pen = Pen(color: Colors.instance.chart_WeekSeparateColor.cgColor, lineWidth: 1, dashStyle: .shaped)
    var monthSeparatorPen : Pen = Pen(color: Colors.instance.chart_MonthSeparateColor.cgColor, lineWidth: 1, dashStyle: .shaped)
    var yearSeparatorPen : Pen = Pen(color: Colors.instance.chart_YearSepareteColor.cgColor, lineWidth: 1, dashStyle: .shaped)
    
    var daySeparatorVisability : Bool = true;
    var weekSeparatorVisability : Bool = false;
    var monthSeparatorVisability : Bool = false;
    var yearSeparatorVisability : Bool = false;
    
    var textSeparatorColor : UIColor = Colors.instance.chart_TextSeparateColor
    
    var useCustomYMarkings = false;
    var useCustomXMarkings = false;
    
    var customYMarkingValue:Double = 1;
    var customXMarkingValue:Double = 10;
    
    var highlightMarkingsStep:Double = 100;
    var highlightMarkings = true;
    var autoScalePen = Pen();
}
