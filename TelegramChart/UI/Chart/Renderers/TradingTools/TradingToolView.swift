//
//  TradingView.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TradingToolView {
    var priority = 0
    var startRectX:CGFloat = 10
    var wasModified:Bool = false
    var errorMode:Bool = false
    let activeHeight:CGFloat = 27
    let notActiveHeight:CGFloat = 16
    
    let activeButtonWidth:CGFloat = 27
    let notActivebuttonWidth:CGFloat = 27
    
    let leftRightTextPadding:CGFloat = 4
    var dashStyle:DashStyle = .shaped
    
    var closeButtonRect:CGRect = .zero
    var trailingButtonRect:CGRect = .zero
    
    var fullRect:CGRect = .zero
    
    weak var renderer:TradingToolsRenderer?
    var price:Double?
    {
        get
        {
            return nil
        }
    }
    
    let radius:CGFloat = 3
    
    var orderType:PFOrderType
    {
        get{
            return .market
        }
    }
    
    var side:PFMarketOperationType
    {
        get{
            return .buy
        }
    }
    
    private(set) var id:Int64!
    weak var linkedTool:TradingToolView?
    var marketOperation:MarketOperation?
    var isActive:Bool = false
    {
        didSet
        {
            if !isActive
            {
                closeButtonRect = .zero
                trailingButtonRect = .zero
            }
        }
    }
        
    private(set) var leftImage:UIImage?

    private let buyClose:UIImage?
    private let sellClose:UIImage?
    
    var closeImage:UIImage?
    {
        if side == .buy
        {
            return buyClose
        }
        else
        {
            return sellClose
        }
    }
    
    var trailingImage:UIImage?
    {
        get{
            return nil
        }
    }
    var leftText:String?
    {
        get{
            return nil
        }
    }
    
    func descriptionText() -> String
    {
        return ""
    }
    
    init(renderer:TradingToolsRenderer) {
        self.renderer = renderer
        buyClose = UIImage(named: "closeBlue")
        sellClose = UIImage(named: "closeRed")
    }
    
    var allowCancel:Bool
    {
        get
        {
            return false
        }
    }
    
    var allowTtailingStop:Bool
    {
        get
        {
            return false
        }
    }
    
    func processClose(){}
    func processTrailing(){}
    
    func processTap(recognizer:UITapGestureRecognizer, coordinate:CGPoint) -> Bool
    {
        if let orderToolView = self as? OrderToolView
        {
            if let slOrder = orderToolView.slOrder
            {
                if slOrder.processTap(recognizer: recognizer, coordinate: coordinate)
                {
                    return true
                }
            }
            if let tpOrder = orderToolView.tpOrder
            {
                if tpOrder.processTap(recognizer: recognizer, coordinate: coordinate)
                {
                    return true
                }
            }
        }
        
        if fullRect.contains(coordinate)
        {
            if closeButtonRect.contains(coordinate)
            {
                processClose()
            }
            else if trailingButtonRect.contains(coordinate)
            {
                processTrailing()
            }
            if !(self is ClosingOrderToolView)
            {
                self.isActive = !isActive
                
                if self.isActive
                {
                    // deactivate other tools
                    if let renderer = renderer
                    {
                        for tool in renderer.tradingTools.values
                        {
                            if tool !== self
                            {
                                tool.isActive = false
                            }
                        }
                    }
                }
            }
            return true
        }
        return false
    }
    
    func drawPlate(price:Double, window:ChartWindow, background:UIColor)
    {
        var formattedPrice = ""
        if let symbol = renderer?.chartBase?.symbol
        {
            if self is PositionToolView
            {
                formattedPrice = String.init(format: "%.\(symbol.defaultTickGroup.precision)f", price)
            }
            else
            {
                formattedPrice = symbol.formatPrice(price)
            }
        }
        window.toolsDrawPointers.append(DrawPointer(drawPointerTypeEnum: .visualTrading, curPriceValue: price, backgroundBrush: background.cgColor, formatcurPriceValue: formattedPrice))
    }
    
    func draw(ctx:CGContext, window: ChartWindow?)
    {
        if let price = price, let window = window, let yPosition = window.pointConverter?.getScreenY(price)
        {
            let clientRect = window.clientRectangle
            ctx.saveGState();
            ctx.clip(to: clientRect)
            let font = isActive ? Font.chartTradingToolActiveText : Font.chartTradingToolNotActiveText
            let height = isActive ? activeHeight : notActiveHeight
            let buttonWidth = isActive ? activeButtonWidth : notActivebuttonWidth
            
            let backgroundColor = side == .buy ? Colors.instance.chart_TradingBuyBackgroundColor : Colors.instance.chart_TradingSellBackgroundColor
            let invertBackgroundColor = side == .buy ? Colors.instance.chart_TradingSellBackgroundColor : Colors.instance.chart_TradingBuyBackgroundColor
            let dividerColor = side == .buy ? Colors.instance.chart_TradingBuyDividerColor : Colors.instance.chart_TradingSellDividerColor
            let dividerPen = Pen(color: dividerColor.cgColor)
            var attributes = [NSAttributedStringKey : NSObject]();
            attributes[NSAttributedStringKey.font] = font;
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            paragraphStyle.allowsDefaultTighteningForTruncation = false
            attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
            if wasModified
            {
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_TradingIndefinitelyTextColor
            }
            else
            {
                attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_TradingMainTextColor;
            }
            let attributedMarketString = NSAttributedString(string: self.descriptionText(), attributes: attributes)
            
            var fullWidth = buttonWidth + attributedMarketString.size().width + leftRightTextPadding * 2
            if isActive
            {
                if allowCancel
                {
                    fullWidth += buttonWidth
                }
                if allowTtailingStop
                {
                    fullWidth += buttonWidth
                }
            }
            fullRect = CGRect(x: startRectX, y: yPosition - height / 2, width: fullWidth, height: height)
            
            let fullPath = CGPath(roundedRect: fullRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
            ctx.addPath(fullPath)
            ctx.setFillColor(backgroundColor.cgColor)
            ctx.fillPath()
            
            ctx.addPath(fullPath)
            ctx.setPen(dividerPen)
            ctx.strokePath()
            
            // ------------ Draw left side
            if let leftImage = leftImage
            {
                let rect = CGRect(x: fullRect.minX + (buttonWidth - leftImage.size.width) / 2, y: fullRect.minY + (height - leftImage.size.height) / 2, width: leftImage.size.width, height: leftImage.size.height)
                
                leftImage.draw(in: rect)
            }
            else if let leftText = leftText
            {
                var attributes = [NSAttributedStringKey : NSObject]();
                attributes[NSAttributedStringKey.font] = Font.chartTradingToolTitleText;
                
                if wasModified
                {
                    attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_TradingIndefinitelyTextColor
                }
                else
                {
                    let color = side == .buy ? Colors.instance.chart_TradingBuyTextColor : Colors.instance.chart_TradingSellTextColor
                    attributes[NSAttributedStringKey.foregroundColor] = color
                }
                let attributedLeftString = NSAttributedString(string: leftText, attributes: attributes)
                
                let rect = CGRect(x: fullRect.minX + (buttonWidth - attributedLeftString.size().width) / 2, y: fullRect.minY + (height - attributedLeftString.size().height) / 2, width: attributedLeftString.size().width, height: attributedLeftString.size().height)
                
                attributedLeftString.draw(in: rect)
            }
            let dividerX = fullRect.minX + buttonWidth
            
            ctx.drawLine(pen:dividerPen, x1: dividerX, y1: fullRect.minY, x2: dividerX, y2: fullRect.maxY)
            
            // ----------- Draw middle
            
            let textRect = CGRect(x: dividerX, y: fullRect.minY + (height - attributedMarketString.size().height) / 2, width: attributedMarketString.size().width + leftRightTextPadding * 2, height: attributedMarketString.size().height)
            
            attributedMarketString.draw(in: textRect)
            
            
            // ----------- Draw right side
            if isActive
            {
                if allowCancel
                {
                    closeButtonRect = CGRect(x: fullRect.maxX - buttonWidth, y: fullRect.minY, width: buttonWidth, height: fullRect.height)
                    if let closeImage = closeImage
                    {
                        let closeImageRect = CGRect(x: closeButtonRect.minX + (closeButtonRect.width - closeImage.size.width) / 2, y: closeButtonRect.minY + (closeButtonRect.height - closeImage.size.height) / 2, width: closeImage.size.width, height: closeImage.size.height)
                        closeImage.draw(in: closeImageRect)
                    }
                    
                    ctx.drawLine(pen:dividerPen, x1: closeButtonRect.minX, y1: fullRect.minY, x2: closeButtonRect.minX, y2: fullRect.maxY)
                }
                else
                {
                    closeButtonRect = .zero
                }
                if allowTtailingStop
                {
                    var startX = fullRect.maxX - buttonWidth
                    if allowCancel
                    {
                        startX = closeButtonRect.minX - buttonWidth
                    }
                    trailingButtonRect = CGRect(x: startX, y: fullRect.minY, width: buttonWidth, height: fullRect.height)
                    if let trailingImage = trailingImage
                    {
                        let trailingImageRect = CGRect(x: trailingButtonRect.minX + (trailingButtonRect.width - trailingImage.size.width) / 2, y: trailingButtonRect.minY + (trailingButtonRect.height - trailingImage.size.height) / 2, width: trailingImage.size.width, height: trailingImage.size.height)
                        trailingImage.draw(in: trailingImageRect)
                    }
                    ctx.drawLine(pen:dividerPen, x1: trailingButtonRect.minX, y1: fullRect.minY, x2: trailingButtonRect.minX, y2: fullRect.maxY)
                }
                else
                {
                    trailingButtonRect = .zero
                }
                
                let pen = Pen(color: backgroundColor.cgColor, lineWidth: 1, dashStyle: dashStyle)
                let maxX = window.priceScaleRenderer?.rectangle.minX ?? 0
                ctx.drawLine(pen:pen, x1: fullRect.maxX, y1: yPosition, x2: maxX, y2: yPosition)
                drawPlate(price: price, window: window, background: backgroundColor)
            }
            
            
            if let selfAsOrder = self as? OrderToolView, selfAsOrder.isActive
            {
                let pen = Pen(color: invertBackgroundColor.cgColor, lineWidth: 2, dashStyle: .dot)
                let lineOffset:CGFloat = 15
                let xCoordinate = fullRect.minX + lineOffset
                if let slOrder = selfAsOrder.slOrder, let slPrice = slOrder.price
                {
                    if let slYPosition = window.pointConverter?.getScreenY(slPrice)
                    {
                        var startY:CGFloat = yPosition
                        if slYPosition < yPosition
                        {
                            startY = fullRect.minY
                        }
                        else
                        {
                            startY = fullRect.maxY
                        }
                        ctx.drawLine(pen:pen, x1:xCoordinate , y1: startY, x2: xCoordinate, y2: slYPosition)
                    
                        slOrder.draw(ctx: ctx, window: window)
                    }
                }
                
                if let tpOrder = selfAsOrder.tpOrder, let tpPrice = tpOrder.price
                {
                    if let tpYPosition = window.pointConverter?.getScreenY(tpPrice)
                    {
                        var startY:CGFloat = yPosition
                        if tpYPosition < yPosition
                        {
                            startY = fullRect.minY
                        }
                        else
                        {
                            startY = fullRect.maxY
                        }
                        ctx.drawLine(pen:pen, x1:xCoordinate , y1: startY, x2: xCoordinate, y2: tpYPosition)
                      
                        tpOrder.draw(ctx: ctx, window: window)
                    }
                }
            }
            ctx.restoreGState()
            
        }
        else
        {
            fullRect = .zero
        }
    }
}
