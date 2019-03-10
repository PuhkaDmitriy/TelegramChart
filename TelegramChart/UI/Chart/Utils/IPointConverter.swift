//
//  IPointConverter.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

protocol IPointConverter
{
    //Получит значение времени по координате x
    func getDataX(_ x : CGFloat) -> Double;
    
    //Получить значение цены по координате y
    func getDataY(_ y : CGFloat) -> Double;
    
    //Получить значение координаты x по времени
    func getScreenX(_ timeX : Double) -> CGFloat;
    
    //Получить значение координаты y по цене
    func getScreenY(_ priceY : Double) -> CGFloat;
    
    //Получить индекс бара по времени
    func getBarIndex(_ timeX : Double) -> Double;
    
    //Получить значение времени по индексу бара
    func getScreenXFromIndex(_ barIndex : Int) -> CGFloat;
}

class CashItemSeriesPointConverter : NSObject, IPointConverter
{
    fileprivate weak var ww : ChartWindow?;
    fileprivate var series : TerceraChartCashItemSeries?;
    
    init(window : ChartWindow, series : TerceraChartCashItemSeries?)
    {
        ww = window;
        self.series = series;
        
        super.init();
    }
    
    func getDataX(_ x: CGFloat) -> Double
    {
        guard let series = self.series else {return 0}
        guard let ww = self.ww else {return 0}
        let r = ww.clientRectangle;
        let barIndex : Double = Double(ww.i1) - Double(r.origin.x + r.size.width - x) / ww.xScale + 1;
        
        return series.findTimeExactly(barIndex);
    }
    
    func getDataY(_ y: CGFloat) -> Double
    {
        guard let ww = self.ww else {return 0}
        if(ww.yScale == 0)
        {
            return 0;
        }
        
        return Double(ww.clientRectangle.maxY - y) / ww.yScale + ww.fMinFloatY;
    }
    
    func getScreenX(_ timeX: Double) -> CGFloat
    {
        guard let ww = self.ww else {return 0}
        guard let series = self.series else {return 0}
        
        //Calculate bar index
        let barIndex = series.findIntervalExactly(timeX);
        
        //Bar index to screen coordinates
        let r : CGRect = ww.clientRectangle;
        let rightBorder:CGFloat = r.origin.x + r.size.width;
        
        return rightBorder - CGFloat((Double(ww.i1 ) - barIndex + 1) * ww.xScale);
    }
    
    func getScreenY(_ priceY: Double) -> CGFloat
    {
        guard let ww = self.ww else {return 0}
        if(ww.yScale == 0)
        {
            return 0;
        }
        return ww.clientRectangle.maxY - CGFloat((priceY - ww.fMinFloatY) * ww.yScale)
    }
    
    func getBarIndex(_ timeX: Double) -> Double
    {
        guard let series = self.series else {return 0}
        return series.findIntervalExactly(timeX);
    }
    
    func getScreenXFromIndex(_ barIndex: Int) -> CGFloat
    {
        guard let ww = self.ww else {return 0}
        let r : CGRect = ww.clientRectangle;
        let rightBorder : CGFloat = r.origin.x + r.size.width;
        
        return rightBorder - CGFloat(Double(ww.i1  - barIndex + 1) * ww.xScale);
    }
}
