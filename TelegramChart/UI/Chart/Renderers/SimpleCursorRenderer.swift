//
//  CursorRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 01/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class SimpleCursorRenderer: BaseRenderer {
    
    let circleRadius:CGFloat = 4
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        if let cursorPosition = chartBase?.lastCursorPosition, chartBase?.type == .simpleChart &&  chartBase?.emptyContentView.isHidden == true
        {
            
            let simpleChart = chartBase as! SimpleChart
            guard let symbolID = simpleChart.symbolID else {return}
            guard let symbol = Session.sharedSession.dataCache.symbolsDictionary[symbolID] else {return}
            guard let chartRect = simpleChart.tableRenderer?.chartRect else {return}
            guard let price = simpleChart.series?.getPriceByXCoordinate(xCoordinate: cursorPosition.x) else {return}
            guard let y = simpleChart.series?.getYForPrice(price: price) else {return}
            ctx.setStrokeColor(Colors.instance.simpleChartLineColor.cgColor)
            ctx.setLineWidth(2)
            ctx.drawLine(x1: cursorPosition.x, y1:chartRect.minY , x2: cursorPosition.x, y2: chartRect.maxY)
            
            let circleRect = CGRect(x: cursorPosition.x - circleRadius, y: y - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
            let circlePath = CGPath(ellipseIn: circleRect, transform: nil)
            ctx.setFillColor(Colors.instance.chartBackgroundColor.cgColor)
            
            ctx.setShouldAntialias(true)
            ctx.addPath(circlePath)
            ctx.fillPath()
            ctx.setLineWidth(1)
            ctx.addPath(circlePath)
            ctx.strokePath()
            
            ctx.setShouldAntialias(false)
            
            let paddingSticker:CGFloat = 3
            let arrowPosition = CGPoint(x: cursorPosition.x, y: chartRect.minY - 6)
            let rectSize = CGSize(width: 120, height: 45)
            let sticker = CGContext.stickerPath(minX: chartRect.minX + paddingSticker, maxX: chartRect.maxX - paddingSticker, rectSize: rectSize, arrowPosition: arrowPosition)
            
            ctx.setShouldAntialias(true)
            ctx.saveGState()
            let highLightColor = Colors.instance.simpleChartStickerBorderColor.withAlphaComponent(0.4).cgColor
            ctx.setLineWidth(2)
            ctx.setStrokeColor(Colors.instance.simpleChartStickerBorderColor.cgColor)
            ctx.addPath(sticker.path)
            ctx.strokePath()
            ctx.addPath(sticker.path)
            
            ctx.setFillColor(Colors.instance.chartBackgroundColor.cgColor)
            ctx.setShadow(offset: CGSize(width:3,height:3), blur: 0.5, color: highLightColor)
            ctx.setBlendMode(.overlay)
            ctx.fillPath()
         
            ctx.restoreGState()
       
            
            UIGraphicsPushContext(ctx)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            paragraphStyle.allowsDefaultTighteningForTruncation = false
                    
            
            var attributes = [NSAttributedStringKey : NSObject]();
            attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
            attributes[NSAttributedStringKey.font] = Font.avenirBook18;
            attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.simpleChartCursorTextColor;
            
            let stickerRect = sticker.rect
            let priceStr = symbol.formatPrice(price)
            let priceAttributedString = NSAttributedString(string: priceStr, attributes: attributes)
            let priceRect = CGRect(x: stickerRect.minX, y: stickerRect.minY, width: stickerRect.width, height: priceAttributedString.size().height)
            ctx.setShouldAntialias(true)
            priceAttributedString.draw(in: priceRect)
            
           
            let time = simpleChart.series?.getTimeByCoordinate(xCoordinate: cursorPosition.x)
            if time != nil
            {
                attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
                attributes[NSAttributedStringKey.font] = Font.avenirBook11;
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.simpleChartCursorTextColor;
                let timeStr = Date(msecondsTimeStamp: time!).fullDateTimeDateString()
                let timeAttributedString = NSAttributedString(string: timeStr, attributes: attributes)
                let timeRect = CGRect(x: stickerRect.minX, y: priceRect.maxY, width: stickerRect.width, height: timeAttributedString.size().height)
                timeAttributedString.draw(in: timeRect)
            }
            UIGraphicsPopContext()
            
        }
    }
}
