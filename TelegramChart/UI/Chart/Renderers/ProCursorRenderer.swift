//
//  ProCursorRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 16/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi


class ProCursorRenderer: BaseRenderer {
    let lineWidth:CGFloat = 1
    let circleRadius:CGFloat = 4
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        let chart = chartBase as! ProChart
        if let cursorPosition = chartBase?.lastCursorPosition, chartBase?.emptyContentView.isHidden == true && chart.isCrossHairAvailable
        {
            guard let windowContainer = windowsContainer else {return}
            
            var xPosition = cursorPosition.x
            var index = -1
            ctx.setStrokeColor(Colors.instance.simpleChartLineColor.cgColor)
            if let data = windowContainer.mainWindow?.pointConverter?.getDataX(cursorPosition.x)
            {
                if let inIndex = windowContainer.mainWindow?.pointConverter?.getBarIndex(data)
                {
                    index = Int(inIndex)
                    xPosition = windowContainer.mainWindow?.pointConverter?.getScreenXFromIndex(Int(index)) ?? cursorPosition.x
                    xPosition +=  CGFloat(chart.mainWindow!.xScale / 2)
                    if xPosition > windowContainer.mainWindow!.clientRectangle.maxX || xPosition < windowContainer.mainWindow!.clientRectangle.minX
                    {
                        return
                    }
                }
            }
            for window in windowContainer.windows
            {
                ctx.setLineWidth(lineWidth)
                ctx.setShouldAntialias(false)
                ctx.drawLine(x1: xPosition, y1:window.clientRectangle.minY , x2: xPosition, y2: window.clientRectangle.maxY)
                if let closePrice = chart.mainPriceRenderer?.series?.cashItem?[index,EPriceType.close]
                {
                    if let coordinateY = windowContainer.mainWindow?.pointConverter?.getScreenY(closePrice)
                    {
                        let circleRect = CGRect(x: xPosition - circleRadius, y: coordinateY - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
                        let circlePath = CGPath(ellipseIn: circleRect, transform: nil)
                        ctx.setFillColor(Colors.instance.chartBackgroundColor.cgColor)
                        
                        ctx.setShouldAntialias(true)
                        ctx.addPath(circlePath)
                        ctx.fillPath()
                        ctx.setLineWidth(1)
                        ctx.addPath(circlePath)
                        ctx.strokePath()
                    }
                }
            }
            ctx.setLineWidth(lineWidth)
            ctx.drawLine(x1: xPosition, y1:windowContainer.timeScaleRenderer.rectangle.minY , x2: xPosition, y2: windowContainer.timeScaleRenderer.rectangle.minY + 3 )
            var timeFormated = "-"
            if let time = chart.mainPriceRenderer?.series?.cashItem?[index,CashItemLevel.timeIndex], time > 0
            {
                let tempAux = Date(msecondsTimeStamp: Int64(time))
                if chart.timeFrameInfo!.period == Periods.TIC {
                    timeFormated = tempAux.shortDateTimeWithMilliseconds()
                }
                else if chart.timeFrameInfo!.period % Periods.SECOND == 0 {
                    timeFormated = tempAux.timestampWithSecondsString()
                }
                else if chart.timeFrameInfo!.period >= Periods.DAY && chart.timeFrameInfo!.period <= Periods.WEEK{
                    timeFormated = tempAux.shortDateString()
                }
                else if chart.timeFrameInfo!.period == Periods.MONTH {
                    timeFormated = tempAux.stringMonthFullYear()
                }
                else if chart.timeFrameInfo!.period == Periods.YEAR {
                    timeFormated = tempAux.year()
                }
                else
                {
                    timeFormated = tempAux.timestampString()
                }
            }
            
            drawTimePlate(context: ctx, x: xPosition, timeFormated: timeFormated, timeScaleRect: chart.windowContainer!.timeScaleRenderer.rectangle, chart: chart)
        }
    }
    
    func drawTimePlate(context:CGContext,  x:CGFloat, timeFormated:String, timeScaleRect:CGRect, chart:ProChart)
    {
       
        var textAttribute = [NSAttributedStringKey : NSObject]();
        textAttribute[NSAttributedStringKey.font] = Font.avenirRoman11
        textAttribute[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_cursorTextColor
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.allowsDefaultTighteningForTruncation = false
        textAttribute[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        
        let attrString = NSAttributedString(string: timeFormated, attributes: textAttribute);
        
        let textWidth = attrString.size().width + 5
        var lastTimeRect = CGRect(x: x - textWidth / 2, y: timeScaleRect.minY + 2, width: textWidth, height: attrString.size().height).integral
        if lastTimeRect.minX < timeScaleRect.minX
        {
            lastTimeRect = CGRect(x: timeScaleRect.minX, y: lastTimeRect.minY, width: lastTimeRect.width, height: lastTimeRect.height)
        }
        else if lastTimeRect.maxX > timeScaleRect.maxX
        {
            lastTimeRect = CGRect(x: timeScaleRect.maxY - lastTimeRect.width, y: lastTimeRect.maxY , width: lastTimeRect.width, height: lastTimeRect.height)
        }
        
        let backgroundRect = CGRect(x: lastTimeRect.minX, y: lastTimeRect.minY, width: lastTimeRect.width, height: lastTimeRect.height - 2)
        
        
        
        context.setShouldAntialias(true)
        context.drawRoundedRect(color: Colors.instance.simpleChartLineColor.cgColor, rectangle: backgroundRect, radius: 2)
        
        //            attrString.draw(in: lastTimeRect)
        attrString.draw(in: lastTimeRect)
        
    }
}
