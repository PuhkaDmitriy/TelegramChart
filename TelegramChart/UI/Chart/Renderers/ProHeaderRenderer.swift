//
//  ProHeaderRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 15/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class ProHeaderRenderer: BaseRenderer {
    var height:CGFloat
    {
        if chartBase?.type == .proChartTablet
        {
            return 43
        }
        else
        {
            return 58
        }
    }
    
    var isOpened = false
    
    private let paddingArrow:CGFloat = 9
    private let tabletHeaderPaddingLeftRight:CGFloat = 8;
    private let tabletHeaderPaddingBottom:CGFloat = 3;
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        
        guard let symbolID = chartBase?.symbolID else {return}
        guard let symbol = Session.sharedSession.dataCache.symbolsDictionary[symbolID] else {return}
        let chart = chartBase as! ProChart
        ctx.setStrokeColor(Colors.instance.chart_ScaleAxisColor.cgColor)
        ctx.setShouldAntialias(false)
        var fillRect = rectangle
        if chart.type == .proChartTablet
        {
            fillRect = CGRect(x: rectangle.minX + tabletHeaderPaddingLeftRight, y: rectangle.minY, width: rectangle.width - tabletHeaderPaddingLeftRight * 2, height: rectangle.height - tabletHeaderPaddingBottom)
        }
        
        ctx.setFillColor(Colors.instance.chart_headerBackground.cgColor)
        ctx.fill(fillRect)
        
        let prevClose = symbol.quote.prevClose(chartBase!.accountID)
        let changeInPercent = symbol.quote.changeInPercent(prevClose)
        let changeInPrice = symbol.quote.change(prevClose)
        var arrow = ""
        let lastDirection = symbol.quote.lastDirection
        
        if lastDirection != nil
        {
            if lastDirection! < 0
            {
                arrow = "↑"
            }
            if lastDirection! > 0
            {
                arrow = "↓"
            }
        }
    
        
        let currentPrice = symbol.quote.curentDependOfBarType(chartBase!.accountID)
        ctx.setShouldAntialias(true)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.allowsDefaultTighteningForTruncation = false
        
        if let windowContainer = windowsContainer, let lastCursorPosition = chart.lastCursorPosition, chart.isCrossHairAvailable
        {
            var index = -1
            if let data = windowContainer.mainWindow?.pointConverter?.getDataX(lastCursorPosition.x)
            {
                if let inIndex = windowContainer.mainWindow?.pointConverter?.getBarIndex(data)
                {
                    index = Int(inIndex)
                }
            }
            
            ctx.setStrokeColor(Colors.instance.simpleChartLineColor.cgColor)
            var open:Double = Double.nan
            var high:Double = Double.nan
            var low:Double = Double.nan
            var close:Double = Double.nan
            
            if let nonEmptyCashArray = chart.mainPriceRenderer?.series?.cashItem?.nonEmptyCashArray
            {
                if(index >= 0 && index < nonEmptyCashArray.count) {
                    let bi = nonEmptyCashArray[index]
                    
                    open = bi.open
                    high = bi.high
                    low = bi.low
                    close = bi.close
                }
            }
            let formattedOpen = symbol.formatPrice(open)
            let formattedHigh = symbol.formatPrice(high)
            let formattedLow = symbol.formatPrice(low)
            let formattedClose = symbol.formatPrice(close)
            
            let resultString = NSLocalizedString("chart.infoWindow.Items.open", comment: "") + formattedOpen + "; " +
                NSLocalizedString("chart.infoWindow.Items.high", comment: "") + formattedHigh + "; " +
                NSLocalizedString("chart.infoWindow.Items.low", comment: "") + formattedLow + "; " +
                NSLocalizedString("chart.infoWindow.Items.close", comment: "") + formattedClose + "; "
            
            var attributes = [NSAttributedStringKey : NSObject]();
            attributes[NSAttributedStringKey.font] = Font.avenirBook14
            attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_headerCursorText
            attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
            let attributedString = NSAttributedString(string: resultString, attributes: attributes)
            let startY = rectangle.minY + (rectangle.height - attributedString.size().height) / 2
            let dataTextRect = CGRect(x: rectangle.minX, y: startY, width: rectangle.width, height: attributedString.size().height)
            ctx.setShouldAntialias(true)
            attributedString.draw(in: dataTextRect)
            //                "chart.infoWindow.Items.open" = "Open:";
            //                "chart.infoWindow.Items.high" = "High:";
            //                "chart.infoWindow.Items.low" = "Low:";
            //                "chart.infoWindow.Items.close" = "Close:";
        }
        else
        {
            var currentPriceStr = "---"
            if currentPrice > 0 && !currentPrice.isNaN
            {
                currentPriceStr = symbol.formatPrice(currentPrice)
            }
            var color:UIColor = Colors.instance.chartCurrentTextColor;
            if lastDirection != nil
            {
                if lastDirection! < 0
                {
                    color = Colors.instance.positivePriceColor
                }
                if lastDirection! > 0
                {
                    color = Colors.instance.negativePriceColor
                }
            }
            
            var changeStr = ""
            if changeInPrice != nil && changeInPercent != nil
            {
                let formattedChangeInPercent = String.stringFormat(changeInPercent, minPrecision: 2, maxPrecision: 2, alwaysPositiveValue: false)! + "%"
                let precision = Int(symbol.precisionForMinTickSize)
                let formattedChangeInPrice = String.stringFormat(changeInPercent, minPrecision: precision, maxPrecision: precision, alwaysPositiveValue: false)
                changeStr = "\(formattedChangeInPrice!)(\(arrow)\(formattedChangeInPercent))"
            }
            
            if chart.type == .proChartMobile
            {
                var attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.avenirBook22;
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_headerCurrentText;
                attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
                var attributedString = NSAttributedString(string: currentPriceStr, attributes: attributes)
                
                
                let curretnTextRect = CGRect(x: rectangle.minX, y: rectangle.minY, width: rectangle.width, height: attributedString.size().height)
                ctx.setShouldAntialias(true)
                attributedString.draw(in: curretnTextRect)
                
                attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.avenirBook14;
                attributes[NSAttributedStringKey.foregroundColor] = color;
                attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
                attributedString = NSAttributedString(string: changeStr, attributes: attributes)
                let changeTextRect = CGRect(x: rectangle.minX, y: curretnTextRect.maxY, width: rectangle.width, height: attributedString.size().height)
                attributedString.draw(in: changeTextRect)
                
            }
            else if chart.type == .proChartTablet
            {
                let paddingBetweenText:CGFloat = 10
                let currentParagraphStyle = NSMutableParagraphStyle()
                currentParagraphStyle.alignment = .right
                currentParagraphStyle.lineBreakMode = .byTruncatingTail
                currentParagraphStyle.allowsDefaultTighteningForTruncation = false
                
                var attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.avenirBook22;
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_headerCurrentText;
                attributes[NSAttributedStringKey.paragraphStyle] = currentParagraphStyle
                var attributedString = NSAttributedString(string: currentPriceStr, attributes: attributes)
                
                let startY = rectangle.minY + (rectangle.height - attributedString.size().height) / 2
                let curretnTextRect = CGRect(x: rectangle.minX, y: startY, width: rectangle.width / 2 - (paddingBetweenText / 2), height: attributedString.size().height)
                ctx.setShouldAntialias(true)
                attributedString.draw(in: curretnTextRect)
                
                
                let changeParagraphStyle = NSMutableParagraphStyle()
                changeParagraphStyle.alignment = .left
                changeParagraphStyle.lineBreakMode = .byTruncatingTail
                changeParagraphStyle.allowsDefaultTighteningForTruncation = false
                
                attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.avenirBook14;
                attributes[NSAttributedStringKey.foregroundColor] = color;
                attributes[NSAttributedStringKey.paragraphStyle] = changeParagraphStyle
                attributedString = NSAttributedString(string: changeStr, attributes: attributes)
                let changeStartY = rectangle.minY + (rectangle.height - attributedString.size().height) / 2
                let changeTextRect = CGRect(x: curretnTextRect.maxX + paddingBetweenText, y: changeStartY, width: curretnTextRect.width, height: attributedString.size().height)
                attributedString.draw(in: changeTextRect)
                
                if isOpened
                {
                    if let downArrow = UIImage(named:"boldArrowDown")
                    {
                        let xPosition = fillRect.maxX - paddingArrow - downArrow.size.width
                        let yPosition = fillRect.minY + fillRect.height / 2 - downArrow.size.height / 2
                        downArrow.draw(in: CGRect(x: xPosition, y: yPosition, width: downArrow.size.width, height: downArrow.size.height))
                    }
                }
                else
                {
                    if let rightArrow = UIImage(named:"boldArrowRight")
                    {
                        let xPosition = fillRect.maxX - paddingArrow - rightArrow.size.width
                        let yPosition = fillRect.minY + fillRect.height / 2 - rightArrow.size.height / 2
                        rightArrow.draw(in: CGRect(x: xPosition, y: yPosition, width: rightArrow.size.width, height: rightArrow.size.height))
                    }
                }
            }
        }
        
    }
    
    
    override func processTap(recognizer:UITapGestureRecognizer, coordinate:CGPoint) -> Bool
    {
        if self.chartBase?.type == .proChartTablet && self.rectangle.contains(coordinate)
        {
            isOpened = !isOpened
            (chartBase as! ProChart).delegate?.headerTap(isOpen: isOpened)
            return true
        }
        return false
    }
}
