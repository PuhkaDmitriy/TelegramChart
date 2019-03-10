//
//  SimpleHeaderRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 31/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class SimpleHeaderRenderer: BaseRenderer {
    
    var counter:Int = 0
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
   
        guard let symbolID = chartBase?.symbolID else {return}
        guard let symbol = Session.sharedSession.dataCache.symbolsDictionary[symbolID] else {return}
        
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
        
        UIGraphicsPushContext(ctx)

        let currentPrice = symbol.quote.curentDependOfBarType(chartBase!.accountID)
        if chartBase?.type == .marketLeader
        {
            let name = symbol.symbol
            var value = name
            
            var fullChange = ""
            
            if currentPrice > 0 && !currentPrice.isNaN
            {
                let currentPriceStr = symbol.formatPrice(currentPrice)

                if changeInPercent != nil
                {
                    let formattedChange = String.stringFormat(changeInPercent, minPrecision: 2, maxPrecision: 2, alwaysPositiveValue: false)! + "%"
                    
                    fullChange = "(\(arrow)\(formattedChange))"
                }
                let boldText = name + " " + currentPriceStr
                value = boldText + fullChange
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let color = Colors.instance.simpleChartMLHeaderColor
            let mutableAttributedString = NSMutableAttributedString(string: value, attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle, NSAttributedStringKey.font: Font.avenirHeavy13 as Any, NSAttributedStringKey.foregroundColor: color])
            
            if fullChange.count > 0
            {
                mutableAttributedString.addAttribute(NSAttributedStringKey.font, value: Font.avenirBook11 as Any, range: NSMakeRange(value.count - fullChange.count , fullChange.count))
            }
            
            let textHeight = mutableAttributedString.size().height
            let offset = ((chartBase as! SimpleChart).tableRenderer!.topChartOffset - textHeight) / 2
            let textRect = CGRect(x: self.rectangle.minX, y: self.rectangle.minY + offset, width: self.rectangle.width, height: textHeight)
            mutableAttributedString.draw(in: textRect)
            
        }
        else
        {
            if currentPrice > 0 && !currentPrice.isNaN
            {
                let currentPriceStr = symbol.formatPrice(currentPrice)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineBreakMode = .byTruncatingTail
                paragraphStyle.allowsDefaultTighteningForTruncation = false
                
                var attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.avenirBook32;
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chartCurrentTextColor;
                attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
                let attributedString = NSAttributedString(string: currentPriceStr, attributes: attributes)
                
                let curretnTextRect = CGRect(x: rectangle.minX, y: rectangle.minY, width: rectangle.width, height: attributedString.size().height)
                
                attributedString.draw(in: curretnTextRect)
                
                if changeInPrice != nil
                {
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
                    let formattedChangeInPercent = String.stringFormat(changeInPercent, minPrecision: 2, maxPrecision: 2, alwaysPositiveValue: false)! + "%"
                    let precision = Int(symbol.precisionForMinTickSize)
                    let formattedChangeInPrice = String.stringFormat(changeInPercent, minPrecision: precision, maxPrecision: precision, alwaysPositiveValue: false)
                    let changeStr = "\(formattedChangeInPrice!)(\(arrow)\(formattedChangeInPercent))"
                    let mutableAttributedString = NSMutableAttributedString(string: changeStr, attributes: [NSAttributedStringKey.paragraphStyle:paragraphStyle, NSAttributedStringKey.font: Font.avenirBook14 as Any, NSAttributedStringKey.foregroundColor: color])
                    let changeTextRect = CGRect(x: rectangle.minX, y: curretnTextRect.maxY, width: rectangle.width, height: mutableAttributedString.size().height)
                    mutableAttributedString.draw(in: changeTextRect)
                }
            }
        }
        UIGraphicsPopContext()
    }
}
