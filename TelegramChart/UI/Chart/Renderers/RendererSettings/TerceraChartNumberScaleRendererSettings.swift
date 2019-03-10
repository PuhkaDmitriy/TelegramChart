//
//  TerceraChartNumberScaleRendererSettings.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartNumberScaleRendererSettings: TerceraChartBaseScaleRendererSettings {
    var gridPriceHLPen:Pen = Pen()
    var gridPriceHLColor  = Colors.instance.chart_ScaleGridColor.cgColor
    {
        didSet
        {
            gridPriceHLPen.color = gridPriceHLColor
        }
    }
    
    override init()
    {
        super.init();
        self.gridPriceHLPen.dashStyle = .dot
        self.themeChanged(true);
    }
    
    
    override func themeChanged(_ resetLayout: Bool)
    {
        if(resetLayout)
        {
            self.scaleAxisColor = Colors.instance.chart_ScaleAxisColor.cgColor;        
            self.scaleTextColor = Colors.instance.chart_ScaleTextColor;
            self.gridPriceHLColor  = Colors.instance.chart_ScaleGridColor.cgColor;
        }
    }

}
