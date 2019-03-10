//
//  TerceraChartBaseScaleRendererSettings.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartBaseScaleRendererSettings: IThemeChanged {
    var scaleGridPen:Pen = Pen(color: Colors.instance.chart_ScaleGridColor.cgColor, lineWidth: 1, dashStyle: .solid)
    
    
    //Axis
    var scaleAxisPen = Pen();
    var scaleAxisColor = UIColor.gray.cgColor
    {
        didSet
        {
            scaleAxisPen.color = scaleAxisColor
        }
    }
    
    
    //Text
    var scaleTextColor = UIColor.gray;
    
    var scaleFont : UIFont = Font.avenirRoman11
    
    var scaleGridVisability : Bool = true;
   
    
    
    func themeChanged(_ resetLayout: Bool){
        scaleAxisColor = Colors.instance.chart_ScaleAxisColor.cgColor
        scaleTextColor = Colors.instance.chart_ScaleTextColor
    }
}

