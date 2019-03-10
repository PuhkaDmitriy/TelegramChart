//
//  IndicatorRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class IndicatorRenderer: BaseRenderer {
    var indicator:BaseIndicator
    var selected:Bool = false;
    
    var chart:ProChart
    {
        get{
            return chartBase as! ProChart
        }
    }
    
    init(indicatorModule:BaseIndicator, chart: ProChart) {
        indicator = indicatorModule
        super.init(chartBase: chart)
        
        if indicatorModule.separatedWindow
        {
            windowsNumber = chart.windowContainer!.windows.count as Int;
        }
        
    }
    
    /// <summary>
    /// Номер окна к которому привязан индикатор
    /// (реальное перемещении происходит после выполнения функции CorrectIndicatorWindows)
    /// </summary>
    var windowsNumber:Int = 0;
    
    //    public abstract IIndicator Indicator { get; }
    
    var isBackGround:Bool
    {
        get
        {
            return indicator.isBackground
        }
    }
    
    /// <summary>
    /// Индикатор собрался пересчитаться, не стоит учитывать его при автоскейле
    /// </summary>
    var invalidState = false;
    
    override var useInAutoScale: Bool
    {
        get{
           return true
        }
        set{}
    }
    
    static func paintStyledWidthLineNew(
        context:CGContext,
        arraypoint:IArrayMath?,
        sideArray:IArrayMath?,
        indicatorIsSelected:Bool,
        window:ChartWindow,
        isSeparateWindow:Bool,
        cashItemSeries:TerceraChartCashItemSeries ,
        drawBegin:Int,
        emptyValue:Double,
        width:CGFloat,
        chcolor:CGColor,
        chstyle:DashStyle,
        useRound:Bool,
        mergeLineParts:Bool,
        timeShift:Int,
        paddingLeftBars:Int,
        converter:TerceraChartSeriesDataConverter? = nil)
    {
        if (arraypoint == nil || arraypoint!.count == 0)
        {
            return;
        }
        
        var curvePoints = [CGPoint]();
        
        let from = window.i1;
        let to = window.i1 - Int(window.im);
        
        var curX = window.clientRectangle.maxX - CGFloat(window.xScale);
        let middle = CGFloat(window.xScale / 2);
        
        for i in stride(from: from, to:(to-1), by:-1)
        {
            //            let index = cashItemSeries.getIndex(i - timeShift);
            //            if index == -1
            //            {
            //                continue
            //            }
            
            let index = i - timeShift - paddingLeftBars
            var value = arraypoint![index];
            
            
            if sideArray != nil
            {
                let side = sideArray![index]
                var nextSide = side
                if sideArray!.count > (index + 1)
                {
                    nextSide = sideArray![i+1]
                }
                if side != nextSide && curvePoints.count > 1
                {
                    drawLinePart(ctx: context, indicatorIsSelected: indicatorIsSelected, chstyle: chstyle, curvePoints: curvePoints, chcolor: chcolor, width: width, useRound: useRound)
                    curvePoints.removeAll();
                }
            }
            
            
            if (index < arraypoint!.count && (index >= drawBegin && index != -1) && (value > 0 || isSeparateWindow) && value != emptyValue && !value.isNaN)
            {
                // Support relative/Log scales
                if (converter != nil)
                {
                    value = converter!.calculate(value);
                }
                let cv = window.pointConverter!.getScreenY(value);
                
                if (cv.isNaN)
                {
                    continue;
                }
                
                let point1 = CGPoint(x: curX + middle, y: cv)
                
                
                // Точки с одинаковыми X не добавляем - на фиг рисовать по нескольку раз в одном месте
                if (curvePoints.count == 0)
                {
                    curvePoints.append(point1);
                }
                else
                {
                    let prevPoint = curvePoints[curvePoints.count - 1];
                    let dx = abs(prevPoint.x - point1.x);
                    let dy = abs(prevPoint.y - point1.y);
                    if (dx > 0 || dy > 0) // так делать нехорошо, приводит к искажениям (http://tp.pfsoft.net/entity/51806)
                    {
                        curvePoints.append(point1);
                    }
                }
            }
            else if (!mergeLineParts && curvePoints.count > 1)
            {
                drawLinePart(ctx: context, indicatorIsSelected: indicatorIsSelected, chstyle: chstyle, curvePoints: curvePoints, chcolor: chcolor, width: width, useRound: useRound)
                curvePoints.removeAll();
            }
            
            curX -= CGFloat(window.xScale);
        }
        
        if (curvePoints.count > 1)
        {
            drawLinePart(ctx: context, indicatorIsSelected: indicatorIsSelected, chstyle: chstyle, curvePoints: curvePoints, chcolor: chcolor, width: width, useRound: useRound)
        }
    }
    
    
    
    static func paintStyledInterLine(
        ctx:CGContext,
        upperArrayPoints:IArrayMath?,
        lowerArrayPoints:IArrayMath?,
        indicatorIsSelected:Bool,
        window:ChartWindow,
        isSeparateWindow:Bool,
        cashItemSeries:TerceraChartCashItemSeries ,
        drawBegin:Int,
        emptyValue:Double,
        upperPen:Pen,
        lowerPen:Pen,
        fillColor1:CGColor,
        fillColor2:CGColor,
        useRound:Bool,
        mergeLineParts:Bool,
        timeShift:Int,
        paddingLeftBars:Int,
        converter:TerceraChartSeriesDataConverter? = nil,
        type:EInterLineType)
    {
        if (upperArrayPoints == nil || upperArrayPoints!.count == 0 || lowerArrayPoints == nil || lowerArrayPoints?.count == 0)
        {
            return;
        }
        
        var upperCurvePoints = [CGPoint]();
        var lowerCurvePoints = [CGPoint]();
        
        let from = window.i1;
        let to = window.i1 - Int(window.im);
        
        var curX = window.clientRectangle.maxX - CGFloat(window.xScale);
        let middle = CGFloat(window.xScale / 2);
        
        var background = fillColor1
        
        for i in stride(from: from, to:(to-1), by:-1)
        {
            let index = i - timeShift - paddingLeftBars
            var upperValue = upperArrayPoints![index]
            var lowerValue = lowerArrayPoints![index];
            
            if (index < upperArrayPoints!.count && (index >= drawBegin && index != -1) && upperValue != emptyValue)
            {
                // Support relative/Log scales
                if (converter != nil)
                {
                    upperValue = converter!.calculate(upperValue);
                    lowerValue = converter!.calculate(lowerValue)
                }
                let cvUpper = window.pointConverter!.getScreenY(upperValue);
                let cvLower = window.pointConverter!.getScreenY(lowerValue);
                
                // +++
                if (cvUpper.isNaN || cvLower.isNaN)
                {
                    continue;
                }
                
                let point1Upper = CGPoint(x: curX + middle, y: cvUpper)
                let point1Lower = CGPoint(x: curX + middle, y: cvLower)
                
                if (upperCurvePoints.count > 0)
                {
                    
                    let lastUpperPoint = upperCurvePoints.last ?? CGPoint()
                    let lastLowerPoint = lowerCurvePoints.last ?? CGPoint()
                    let x1 = lastUpperPoint.x
                    let x2 = point1Upper.x
                    let y1 = lastUpperPoint.y
                    let y2 = point1Upper.y
                    
                    let x3 = lastLowerPoint.x
                    let x4 = point1Lower.x
                    let y3 = lastLowerPoint.y
                    let y4 = point1Lower.y
                    
                    // Определяем перекрестие линий
                    let x = (x2*y1 - x1*y2 - (x2 - x1) / (x4 - x3) * (x4*y3 - x3*y4)) / (y1 - y2 - (x2 - x1) * (y3 - y4) / (x4 - x3))
                    
                    let y = (x4*y3 - x3*y4 - (y3 - y4)*x) / (x4 - x3)
                    let ae:CGFloat = 1 // allowable error
                    let allow = ((y <= (y1 + ae) && y >= (y2 - ae)) || (y >= (y1 - ae) && y <= (y2 + ae))) && (y <= (y3 + ae) && y >= (y4 - ae)) || (y >= (y3 - ae) && y <= (y4 + ae)) && ((x <= (x1 + ae) && x >= (x2 - ae)) || (x >= (x1 - ae) && x <= (x2 + ae))) && (x <= (x3 + ae) && x >= (x4 - ae)) || (x >= (x3 - ae) && x <= (x4 + ae))
                    
                    if (allow)
                    {
                        let endCrossPoint = CGPoint(x: x, y: y)
                        
                        upperCurvePoints.append(endCrossPoint)
                        lowerCurvePoints.append(endCrossPoint)
                        
                        background = getBackground(type: type, points1: upperCurvePoints, points2: lowerCurvePoints, color1: fillColor1, color2: fillColor2)
                        drawInnerBackground(ctx:ctx,fillColor:background, line1:upperCurvePoints, line2:lowerCurvePoints)
                        
                        drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: upperPen.dashStyle, curvePoints: upperCurvePoints, chcolor: upperPen.color, width: upperPen.lineWidth, useRound: useRound)
                        drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: lowerPen.dashStyle, curvePoints: lowerCurvePoints, chcolor: lowerPen.color, width: lowerPen.lineWidth, useRound: useRound)
                        
                        upperCurvePoints.removeAll();
                        lowerCurvePoints.removeAll()
                        upperCurvePoints.append(endCrossPoint)
                        lowerCurvePoints.append(endCrossPoint)
                        
                    }
                }
                
                
                upperCurvePoints.append(point1Upper);
                lowerCurvePoints.append(point1Lower);
            }
            else if (!mergeLineParts && upperCurvePoints.count > 1)
            {
                background = (upperCurvePoints.last!.y > lowerCurvePoints.last!.y) ? fillColor1 : fillColor2
                drawInnerBackground(ctx:ctx,fillColor:background, line1:upperCurvePoints, line2:lowerCurvePoints)
                drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: upperPen.dashStyle, curvePoints: upperCurvePoints, chcolor: upperPen.color, width: upperPen.lineWidth, useRound: useRound)
                
                drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: lowerPen.dashStyle, curvePoints: lowerCurvePoints, chcolor: lowerPen.color, width: lowerPen.lineWidth, useRound: useRound)
                
                upperCurvePoints.removeAll();
                lowerCurvePoints.removeAll()
                
            }
            
            curX -= CGFloat(window.xScale);
        }
        
        if (upperCurvePoints.count > 1)
        {
            background = getBackground(type: type, points1: upperCurvePoints, points2: lowerCurvePoints, color1: fillColor1, color2: fillColor2)
            
            drawInnerBackground(ctx:ctx,fillColor:background, line1:upperCurvePoints, line2:lowerCurvePoints)
            drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: upperPen.dashStyle, curvePoints: upperCurvePoints, chcolor: upperPen.color, width: upperPen.lineWidth, useRound: useRound)
            
            drawLinePart(ctx: ctx, indicatorIsSelected: indicatorIsSelected, chstyle: lowerPen.dashStyle, curvePoints: lowerCurvePoints, chcolor: lowerPen.color, width: lowerPen.lineWidth, useRound: useRound)
            
            
        }
        
    }
    
    static func getBackground(type:EInterLineType, points1:[CGPoint], points2:[CGPoint], color1:CGColor, color2:CGColor) -> CGColor
    {
        if type == .simple
        {
            return color1
        }
        for i in 0..<points2.count
        {
            if points1[i].y > points2[i].y
            {
                return color1
            }
            else if points1[i].y < points2[i].y
            {
                return color2
            }
        }
        return color1
    }
    
    static func drawInnerBackground(ctx:CGContext,fillColor:CGColor, line1:[CGPoint], line2:[CGPoint])
    {
        if (line1.count > 0)
        {
            var resultArr = [CGPoint]()
            
            resultArr += line1
            resultArr += line2.reversed()
            
            
            resultArr.append(line1[0])
            
            let path = CGMutablePath()
            path.addLines(between: resultArr)
            ctx.addPath(path)
            ctx.setFillColor(fillColor)
            ctx.fillPath()
        }
    }
    
    static func drawLinePart(ctx:CGContext,indicatorIsSelected:Bool,chstyle:DashStyle, curvePoints:[CGPoint], chcolor:CGColor, width:CGFloat, useRound:Bool )
    {
        var width = width
        if indicatorIsSelected
        {
            width += 2
        }
        
        let color = indicatorIsSelected ? Colors.instance.chart_IndicatorLineHover.cgColor : chcolor
        
        let pen = Pen(color: color, lineWidth: width, dashStyle: chstyle)
        if useRound
        {
            ctx.setLineJoin(CGLineJoin.round)
        }
        ctx.setShouldAntialias(true)
        ctx.drawLines(pen: pen, points: curvePoints)
        ctx.setShouldAntialias(false)
        
    }
    
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?){
        if !visible
        {
            return
        }
            
        ctx.saveGState()
        
        ctx.clip(to: window!.clientRectangle)

        guard let cashItemSeries = chart.mainPriceRenderer?.series else {return}
        let converter = windowsNumber == 0 ? chart.cashItemSeriesSettings?.activeConverter : nil
        
        let paddingLeftBars = Int(chart.mainPriceRenderer?.series?.paddingBarsCount ?? 0)
        
        for line in indicator.indicarorLines
        {
            if line.visible
            {
                let sideSource = line.sideSourceIndex == nil ? nil : indicator.dataSource?.dataSets[line.sideSourceIndex!]

                IndicatorRenderer.paintStyledWidthLineNew(context: ctx, arraypoint: indicator.dataSource?.dataSets[line.dataSourceIndex],sideArray:sideSource, indicatorIsSelected: selected, window: window!, isSeparateWindow: windowsNumber != 0, cashItemSeries: cashItemSeries, drawBegin: 0, emptyValue: Double.nan, width: line.pen.lineWidth, chcolor: line.pen.color, chstyle: line.pen.dashStyle, useRound: true, mergeLineParts: false, timeShift: line.timeShift, paddingLeftBars: paddingLeftBars, converter: converter)
                

            }
        }
        
        for interLine in indicator.indicatorInterLines
        {
            if interLine.visible
            {
                
                IndicatorRenderer.paintStyledInterLine(ctx: ctx, upperArrayPoints: indicator.dataSource?.dataSets[interLine.dataSourceUpperIndex], lowerArrayPoints: indicator.dataSource?.dataSets[interLine.dataSourceLowerIndex], indicatorIsSelected: selected,  window: window!, isSeparateWindow: windowsNumber != 0, cashItemSeries: cashItemSeries, drawBegin: 0, emptyValue: Double.nan, upperPen: interLine.upperPen, lowerPen: interLine.lowerPen,fillColor1:interLine.background1,fillColor2:interLine.background2, useRound: true, mergeLineParts: false, timeShift: interLine.timeShift, paddingLeftBars: paddingLeftBars, converter:converter,type:interLine.type)

            }
        }
        
        ctx.restoreGState()
    }
    
    func checkMinMax (min:inout Double, max: inout Double,from:Int, to:Int, timeShift:Int,paddingLeftBars:Int, indicator:BaseIndicator, sourceID:Int, activeConverter:TerceraChartSeriesDataConverter?)
    {
        
        let vector = (indicator.dataSource?.dataSets[sourceID])!
        for i in stride(from: from, to:(to-1), by:-1)
        {
            let index = i - timeShift - paddingLeftBars
            
            if index < vector.count
            {
                var value = vector[index]
                
                if activeConverter != nil
                {
                    value = activeConverter!.calculate(value)
                }
                if value < min
                {
                    min = value
                }
                if value > max
                {
                    max = value
                }
            }
        }
        
    }
    
    override func findMinMax(_ min: inout Double, max: inout Double, window: ChartWindow) -> Bool {
        if indicator.dataSource == nil || !visible
        {
            return false
        }
        guard let parentSeries = series else {return false}
        
        
        let from = window.i1
        let to = window.i1 - Int(window.im)
        let paddingLeftBars = Int(chart.mainCashItemSeries?.paddingBarsCount ?? 0)
        
        let activeConverter = windowsNumber == 0 ? parentSeries.settings.activeConverter : nil;
        
        for line in indicator.indicarorLines
        {
            if line.visible == true
            {
                checkMinMax(min: &min, max: &max, from: from, to: to, timeShift: line.timeShift, paddingLeftBars: paddingLeftBars, indicator: indicator, sourceID: line.dataSourceIndex, activeConverter:activeConverter)
            }
        }
        
        for interLine in indicator.indicatorInterLines
        {
            if interLine.visible == true
            {
                checkMinMax(min: &min, max: &max, from: from, to: to, timeShift: interLine.timeShift, paddingLeftBars: paddingLeftBars, indicator: indicator, sourceID: interLine.dataSourceUpperIndex, activeConverter:activeConverter)
                checkMinMax(min: &min, max: &max, from: from, to: to, timeShift: interLine.timeShift, paddingLeftBars: paddingLeftBars, indicator: indicator, sourceID: interLine.dataSourceLowerIndex, activeConverter:activeConverter)
            }
        }
        return true
        
    }
    
}



class TerceraChartIndicatorRenererSettings
{
    var useInAutoscale = true
}
