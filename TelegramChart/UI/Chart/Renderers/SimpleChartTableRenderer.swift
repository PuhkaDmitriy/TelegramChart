//
//  SimpleChartTableRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 25/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

struct ButtonContainer
{
    let period:SimpleChartPeriods
    let rect:CGRect
}

class SimpleChartTableRenderer: BaseRenderer {
    
    let gridPreferSize:CGFloat = 40
    let bottomChartOffset:CGFloat = 40
    var topChartOffset:CGFloat = 40
    var lineColor:CGColor = Colors.instance.simpleChartLineColor.cgColor
    var gradientStartColor = Colors.instance.simpleChartGradientStartColor.cgColor
    var gradientEndColor = Colors.instance.simpleChartGradientEndColor.cgColor

    
    let gridColor:CGColor = Colors.instance.chartGridColor.cgColor
    var chartRect:CGRect
    {
        get{
            let chartHeight = self.rectangle.height - bottomChartOffset - topChartOffset
            return CGRect(x: rectangle.minX, y: rectangle.minY + topChartOffset, width: rectangle.width, height: chartHeight)
        }
    }
    let buttonWidth:CGFloat = 40
    var buttonContainers:[ButtonContainer] = []
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
  
//        ctx.setFillColor(Colors.instance.chartBackgroundColor.cgColor)
//        ctx.fill(self.rectangle)
        UIGraphicsPushContext(ctx)
        
        drawButtons(ctx: ctx)
        if chartBase?.emptyContentView.isHidden == true
        {
//          drawGrid(ctx: ctx)
            drawChart(ctx: ctx)
        }
        UIGraphicsPopContext()
    }
    
    func drawButtons(ctx:CGContext)
    {
        var count = 0
        let buttonMaxSize =  self.rectangle.width / CGFloat(SimpleChartPeriods.allValues.count)
        let buttonSize = min(self.buttonWidth, buttonMaxSize)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.allowsDefaultTighteningForTruncation = false
        
        var attributes = [NSAttributedStringKey : NSObject]();
        attributes[NSAttributedStringKey.font] = Font.avenirBook13;
        attributes[NSAttributedStringKey.foregroundColor] = Colors.instance.simpleChartButtonTextColor;
        attributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        
        var activeAttributes = [NSAttributedStringKey : NSObject]();
        activeAttributes[NSAttributedStringKey.font] = Font.avenirHeavy13;
        activeAttributes[NSAttributedStringKey.foregroundColor] = Colors.instance.simpleChartActiveButtonTextColor;
        activeAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        activeAttributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue as NSObject
        let allValues = SimpleChartPeriods.allValues
        let currentPeriod = (chartBase as! SimpleChart).currentPeriod
        var buttonContainerTemp = [ButtonContainer]()
        for i in 0 ..< allValues.count
        {
            let center = buttonMaxSize * CGFloat(i) + (buttonMaxSize / 2)
            let startX = center - buttonSize / 2
            let buttonRect = CGRect(x: startX, y: self.rectangle.maxY - bottomChartOffset, width: buttonSize, height: bottomChartOffset)
      
            let value = allValues[i]
            let attributedStr:NSAttributedString?
            if value == currentPeriod
            {
                attributedStr = NSAttributedString(string: value.description, attributes: activeAttributes)
            }
            else
            {
                attributedStr = NSAttributedString(string: value.description, attributes: attributes)
            }
            let startY = (buttonRect.height - attributedStr!.size().width) / 2
            let strRect = CGRect(x: buttonRect.minX, y: buttonRect.minY + startY, width: buttonRect.width, height: attributedStr!.size().height)
            attributedStr?.draw(in: strRect)
            buttonContainerTemp.append(ButtonContainer(period: value, rect: buttonRect))
            count += 1
        }
        buttonContainers = buttonContainerTemp
    }
    
    func drawChart(ctx:CGContext)
    {
        var points = (chartBase as! SimpleChart).series!.points
        ctx.setShouldAntialias(true)
        ctx.setStrokeColor(lineColor)
        ctx.setLineWidth(2)
        
        ctx.addLines(between: points)
   
        ctx.setLineJoin(CGLineJoin.round)
        ctx.strokePath()
        

        let colors = [gradientStartColor, gradientEndColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        
        let path = CGMutablePath()
        let startPoint = CGPoint(x:points[0].x, y:rectangle.maxY)
        path.move(to: startPoint)
        for point in points
        {
            path.addLine(to: CGPoint(x:point.x, y: point.y))
        }
        path.addLine(to: CGPoint(x: points.last!.x, y: rectangle.maxY))
        path.addLine(to: startPoint)
        
        ctx.saveGState()
        ctx.addPath(path)
        ctx.clip()
        let boundingBox = path.boundingBox
        let end = CGPoint(x: boundingBox.minX, y: boundingBox.minY)
        let start = CGPoint(x: boundingBox.minX, y: boundingBox.maxY)
        ctx.drawLinearGradient(gradient!, start: start, end:  end, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        ctx.restoreGState()
        
    }
    
    func drawGrid(ctx:CGContext)
    {
        let xLineCount = Int(chartRect.width / gridPreferSize)
        let gridXSize = chartRect.width / CGFloat(xLineCount)
        
        let yLineCount = Int(chartRect.height / gridPreferSize)
        let gridYSize = chartRect.height / CGFloat(yLineCount)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(gridColor)
        
        ctx.setShouldAntialias(false)
        if yLineCount > 1
        {
            for yPosition in 1 ..< yLineCount
            {
                let y = CGFloat(yPosition) * gridYSize + chartRect.minY
                ctx.drawLine(x1: chartRect.minX, y1: y, x2: chartRect.maxX, y2: y)
            }
        }
        
        if xLineCount > 1
        {
            for xPosition in 1 ..< xLineCount
            {
                let x = CGFloat(xPosition) * gridXSize
                ctx.drawLine(x1: x, y1: chartRect.minY, x2: x, y2: chartRect.maxY)
            }
        }
    }
    
    override func processTap(recognizer:UITapGestureRecognizer, coordinate:CGPoint) -> Bool
    {
        for container in buttonContainers
        {
            if container.rect.contains(coordinate)
            {
                (chartBase as? SimpleChart)?.currentPeriod = container.period
                (chartBase as? SimpleChart)?.requestHistory()
                return true
            }
        }
        return false
    }
}
