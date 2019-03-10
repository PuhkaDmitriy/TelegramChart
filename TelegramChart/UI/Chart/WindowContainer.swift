//
//  WindowContainer.swift
//  Protrader 3
//
//  Created by Yuriy on 03/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class WindowContainer: Any {
    var rectangle: CGRect = .zero;
    var timeScaleRenderer:TimeScaleRenderer
    var cursorRenderer:ProCursorRenderer
    weak var chart:ProChart?
    var windows = [ChartWindow]();
    var mainWindow: ChartWindow?
    
    init(chart:ProChart) {
        self.chart = chart
        self.mainWindow = chart.mainWindow
        timeScaleRenderer = TimeScaleRenderer(chartBase: chart)
        cursorRenderer = ProCursorRenderer(chartBase: chart)
    }
    
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        timeScaleRenderer.draw(layer, in: ctx, window: mainWindow, windowsContainer: self)
        
        for w in self.windows{
            w.draw(layer, in: ctx)
        }
    }
    
    func calculateMinMax() {
        for w in self.windows {
            w.calculateMinMax()
        }
    }
    
    func needRedrawPriceScale() -> Bool
    {
        var needRedraw = false
        for w in self.windows
        {
            if w.needRedrawPriceScale()
            {
                needRedraw = true
            }
        }
        return needRedraw
    }
    
    func layoutWindows()
    {
        let rect = rectangle
                
        // time scale
        let timeHeight = timeScaleRenderer.getPreferredHeight();
        timeScaleRenderer.rectangle.origin.x = rect.minX;
        timeScaleRenderer.rectangle.origin.y = rect.maxY - timeHeight;
        timeScaleRenderer.rectangle.size.width = rect.width;
        timeScaleRenderer.rectangle.size.height = timeHeight
        
        
        let totalHeight = rect.height - timeScaleRenderer.rectangle.size.height;
        
        self.resizeWindows(rect.minX, rect.minY, totalHeight , rect.width)
    }
    
    func resizeWindows(_ windowX: CGFloat, _ windowY: CGFloat, _ height: CGFloat, _ width: CGFloat) {
        mainWindow?.rectangle = CGRect(x: windowX, y: windowY, width: width, height: height)
        mainWindow?.onLayout()
    }
}
