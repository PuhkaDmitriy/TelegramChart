//
//  IndicatorStorageRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class IndicatorStorageRenderer: BaseRenderer {

    var indicators = [IndicatorRenderer]()
    var mainWindow = false
    weak var window:ChartWindow?
    
    override var useInAutoScale: Bool
    {
        get
        {
            return window?.indicatorRendererSettings.useInAutoscale ?? false
        }
        set
        {
            window?.indicatorRendererSettings.useInAutoscale = newValue
        }
    }
    
    init(chartBase:ChartBase, mainWindow:Bool = false) {
        super.init(chartBase: chartBase)
        self.mainWindow = mainWindow
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?){
        if window !== self.window
        {
            self.window = window
        }
       
        for indRenderer in indicators
        {
            indRenderer.draw(layer, in: ctx, window: window, windowsContainer: windowsContainer)
        }
    }
    
    override func findMinMax(_ min: inout Double, max: inout Double, window: ChartWindow) -> Bool {
        var result = true
        min = Double.greatestFiniteMagnitude
        max = -Double.greatestFiniteMagnitude
        
        for renderer in indicators
        {
            var indMin:Double = Double.greatestFiniteMagnitude
            var indMax:Double = -Double.greatestFiniteMagnitude
            if (!renderer.invalidState && renderer.findMinMax(&indMin, max: &indMax, window: window))
            {
                result = true;
                if indMin < min
                {
                    min = indMin
                }
                if indMax > max
                {
                    max = indMax
                }
            }
        }
        return result
    }
}
