//
//  VolumeBarsRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class VolumeBarsRenderer: BaseRenderer {
    let showVolumeMarket = true
    let voluemHeightPercent = 30

    override var visible: Bool
    {
        get
        {
            return Settings.shared.showVolume
        }
        set
        {
            Settings.shared.showVolume = newValue
        }
    }
   
    var maxVol:CGFloat!
    
    var noVolumeBarsData:Bool
    {
        get
        {
            return maxVol <= 0
        }
    }
    
    var lastBarSum:Double = 0
    var volumeHeightPercent:CGFloat = 30;
    
    var filterActive = false;
    var filterValue = 0;
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        if !visible
        {
            return
        }
        
        guard let proChart = chartBase as? ProChart else {return}
      
        if proChart.timeFrameInfo?.period == 0 && proChart.timeFrameInfo?.historyType != PFQuoteBarType.trade
        {
            return
        }
        
        let cashItemSeries = proChart.mainCashItemSeries;
        let clientRect = window!.clientRectangle
        let screenData = cashItemSeries?.chartScreenData
        if screenData == nil
        {
            return
        }

        ctx.setShouldAntialias(false)
        
        let  scX = CGFloat(window!.xScale).rounded()
        let barWidth = CGFloat(window!.xScale).rounded()
        var curX = clientRect.maxX - scX
        var leftBorder:CGFloat = 0
        var barW:CGFloat = 1
        MainPriceRenderer.processBarWidth(window: window!, barW: &barW, leftBorder: &leftBorder)
        
        maxVol = -CGFloat.greatestFiniteMagnitude
        for screenElement in screenData!.storage
        {
            let absValue = abs(CGFloat(screenElement.volume))
            if absValue > maxVol
            {
                maxVol = absValue
            }
        }
        
        if self.noVolumeBarsData
        {
            return
        }
        ctx.saveGState()
        ctx.clip(to: clientRect)
        
        let lastVolumeK = (clientRect.height * volumeHeightPercent / 100) / maxVol
        
        let current = Colors.instance.chart_VolumeBarsColor.cgColor
        
        var nextVolume:Double = 0
        var currentVolume:Double = 0
        
        let volumeWidth = barWidth > 1 ? barWidth - 1 : 1
        
        for i in stride(from: screenData!.storage.count - 1, to: -1, by: -1)
        {
            let leftBorderX = curX + leftBorder
            currentVolume = screenData!.storage[i].volume
          
            if i > 0
            {
                nextVolume = screenData!.storage[i - 1].volume
            }
            else
            {
                nextVolume = cashItemSeries!.getVolumeFromVolumeInfo(window!.i1 - Int(window!.im) - 1)
            }
            let height =  abs(CGFloat(currentVolume)) * lastVolumeK
            
            
            let barRect = CGRect(x: leftBorderX - leftBorder, y: clientRect.maxY - height, width: volumeWidth, height: height)
            ctx.setFillColor(current)
            ctx.fill(barRect)
            
            curX -= scX;
        }
        // +++ плашки
        let barIndex = cashItemSeries!.cashItem!.nonEmptyCashArray.count - 1; // last bar
        if (barIndex >= 0 && self.showVolumeMarket)
        {
            let value = cashItemSeries!.getVolume(barIndex);
            nextVolume = barIndex != 0 ? cashItemSeries!.getVolume(barIndex - 1) : 0;

            var text = ""
            if proChart.getHistoryParams()?.timeFrameInfo?.historyType != PFQuoteBarType.trade
            {
                text = String.stringFormat(value, minPrecision: proChart.symbol?.lotStepPrecision, maxPrecision: proChart.symbol?.lotStepPrecision, suffix: nil, customString: nil, alwaysPositiveValue: false)!
            }
            else {
                text = String.stringFormatForRealValueQuantity(value, symbol: proChart.symbol!)
            }
            
            
            var yy = clientRect.maxY - CGFloat(abs(value)) * lastVolumeK;
            
            if (yy < 6)
            {
                yy = 6;
            }
            let current = Colors.instance.chart_VolumeBarsColor.cgColor
            
            window?.mainDrawPointers.append(DrawPointer(drawPointerTypeEnum: .indicator, curPriceValue: -1, backgroundBrush:current, formatcurPriceValue: text, yLocation:yy))
      
        }
        ctx.restoreGState()
    }
}
