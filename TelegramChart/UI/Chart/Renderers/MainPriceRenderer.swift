//
//  MainPriceRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class MainPriceRenderer: BaseRenderer {
    
    var showWicks: Bool{
        return (proChart.timeFrameInfo?.aggregationMode as? TFAggregationModeRenko)?.showWicks ?? true
    }
    
    var barsForestPen = Pen(color: UIColor.red.cgColor)
    
    var barUpColorPen = Pen(color: UIColor.green.cgColor);
    var barDownColorPen = Pen(color: UIColor.red.cgColor);
    
    var barsHighLowColorPen = Pen(color: UIColor.gray.cgColor);
    var barsLineColorPen = Pen(color: UIColor.gray.cgColor);
    
    var wickUpBorderColorPen = Pen(color: UIColor.green.cgColor);
    var wickDownBorderColorPen = Pen(color: UIColor.red.cgColor);
    
    var bidLineColorPen = Pen(color: UIColor.green.cgColor);
    var askLineColorPen = Pen(color: UIColor.red.cgColor);
    
    var barsUpBorderColorPen = Pen(color: UIColor.green.cgColor);
    var barsDownBorderColorPen = Pen(color: UIColor.red.cgColor);
    var solidPriceColor:CGColor = UIColor.blue.cgColor
    {
        didSet
        {
            solidPriceColorGradient0 = solidPriceColor.copy(alpha: 0.5)! as CGColor
            solidPriceColorGradient1 = solidPriceColor.copy(alpha: 0)! as CGColor
        }
    }
    
    var solidPriceColorGradient0:CGColor!
    var solidPriceColorGradient1:CGColor!
    
    var proChart:ProChart
    {
        get
        {
            return chartBase as! ProChart
        }
    }
    
    //    var solidPriceColor:CGColor
    
    override init(chartBase: ChartBase) {
        super.init(chartBase: chartBase)
        themeChanged(true)
    }
    
    func themeChanged(_ resetLayout: Bool)
    {
        if(resetLayout)
        {
            wickUpBorderColorPen.color = Colors.instance.chart_WickUpBorderColor.cgColor;
            wickDownBorderColorPen.color = Colors.instance.chart_WickDownBorderColor.cgColor;
            
            barsHighLowColorPen.color = Colors.instance.chart_BarsHighLowColor.cgColor;
            barsLineColorPen = Pen(color: Colors.instance.chart_BarsSolidColor.cgColor, lineWidth: 2, dashStyle: .solid)
            solidPriceColor = Colors.instance.chart_BarsSolidColor.cgColor
            
            
            barUpColorPen.color = Colors.instance.chart_BarsUpColor.cgColor;
            barDownColorPen.color = Colors.instance.chart_BarsDownColor.cgColor;
            
            bidLineColorPen.color = Colors.instance.chart_BarsUpColor.cgColor;
            askLineColorPen.color = Colors.instance.chart_BarsDownColor.cgColor;
            
            barsUpBorderColorPen.color = Colors.instance.chart_BarsUpBorderColor.cgColor;
            barsDownBorderColorPen.color = Colors.instance.chart_BarsDownBorderColor.cgColor;
            barsForestPen.color = Colors.instance.chart_BarsSolidColor.cgColor
            
        }
    }
    
    /// <summary>
    /// Рендерер учавствует в расчёте автомасшатбирования
    /// </summary>
    override func findMinMax( _ min : inout Double, max : inout Double, window : ChartWindow) -> Bool
    {
        min = Double.greatestFiniteMagnitude
        max = -Double.greatestFiniteMagnitude;
        
        let cashItemSeries = self.series
        if (cashItemSeries == nil)
        {
            return false;
        }
        
        // Use cached data
        min = cashItemSeries!.chartScreenData.minLow
        max = cashItemSeries!.chartScreenData.maxHigh
        
        return true;
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?)
    {
        if(!self.visible || self.series == nil)
        {
            return;
        }
        
      
        //После рисования - режим Foreground
//        param!.tag[TerceraChartRendererDrawingAdvancedParamsEnum.currentDrawingType] = TerceraChartToolRendererDrawingType.foreground;
        
        ctx.saveGState();
        ctx.setShouldAntialias(false)
        let clientRectangle = window!.clientRectangle;
        ctx.clip(to: clientRectangle);
        
        guard let cashItemSeries = self.series else {return}
        let scX = CGFloat(window!.xScale);
        let curX = clientRectangle.maxX - scX;
        var leftBorder : CGFloat = 0;
        var barW:CGFloat = 1;
        MainPriceRenderer.processBarWidth(window: window!, barW: &barW, leftBorder: &leftBorder);
        
        switch Settings.shared.chartStyle()
        {
        case .candle:
            //Draw zero line
            self.drawZeroLineForrelative(ctx: ctx, window: window!, clientRect: clientRectangle, cashItemSeries: cashItemSeries);
            //
            self.drawCandleChart(ctx: ctx, window: window!, scX: scX, currentX: curX, leftBorder: leftBorder, barW: barW, cashItemSeries: cashItemSeries);
            break;
        case .bar:
            self.drawBarChart(ctx: ctx, window: window!, scX: scX, currentX: curX, leftBorder: leftBorder, barW: barW, cashItemSeries: cashItemSeries);
            break;
            
        case .line, .dot, .dotLine, .solid:
            // Draw zero line
            drawZeroLineForrelative(ctx: ctx, window: window!, clientRect: clientRectangle, cashItemSeries: cashItemSeries)
            drawLineChart(ctx: ctx, window: window!, scX: scX, curX: curX, leftBorder: leftBorder, barW: barW, cashItemSeries: cashItemSeries);
        case .forest:
            drawZeroLineForrelative(ctx: ctx, window: window!, clientRect: clientRectangle, cashItemSeries: cashItemSeries)
            drawForestChart(ctx: ctx, window: window!, scX: scX, curX: curX, leftBorder: leftBorder, barW: barW, cashItemSeries: cashItemSeries);
        default:
            break;
        }
        
        ctx.restoreGState();
    }
    
    private func drawZeroLineForrelative(ctx : CGContext, window : ChartWindow, clientRect : CGRect, cashItemSeries : TerceraChartCashItemSeries)
    {
    }
    
    func drawForestChart(ctx : CGContext, window : ChartWindow, scX : CGFloat, curX : CGFloat, leftBorder : CGFloat, barW : CGFloat, cashItemSeries : TerceraChartCashItemSeries)
    {
        ctx.setShouldAntialias(true)
        var curX = curX
        let screenData = cashItemSeries.chartScreenData.storage;
        var lastClose:Double = 0
        var lclose = screenData.count - 1
        while ((lclose > 0) && (lastClose == 0))
        {
            let item = screenData[lclose];
            lastClose = item.close
            lclose -= 1
        }
        // рисуем ее на чарте
        let curIntY = window.pointConverter!.getScreenY(lastClose)
        if (!(curIntY < CGFloat(-1000) || curIntY > CGFloat(10000)))
        {
            let pen = Pen(color: barsForestPen.color)
            ctx.drawLine(pen: pen, x1: window.clientRectangle.minX, y1: curIntY, x2: window.clientRectangle.maxX, y2: curIntY)
        }
        
        //        RefreshForestBarBrush(curIntY, window);
        //
        // Проходимся по всем барам
        //
        let barsForestPenScaled = getPenWithScale(window: window, originalPen: barsForestPen);
        for i in stride(from: screenData.count - 1, to: -1, by: -1)
        {
            
            let item = screenData[i]
            let closePrice = item.close;
            
            if (closePrice == 0)
            {
                curX -= scX;
                continue;
            }
            
            let closeY = window.pointConverter!.getScreenY(closePrice)
            
            // Явно неправильные значения - спровоцирует эксепшн при прорисовке
            if (closePrice != 0 && (closeY < CGFloat(-1000) || closeY > CGFloat(10000)))
            {
                curX -= scX;
                continue;
            }
            
            var barMIddle = curX + leftBorder + barW / 2;
            if (barW == 1)
            {
                barMIddle = curX;
            }
            ctx.drawLine(pen: barsForestPenScaled, x1: barMIddle, y1: curIntY, x2: barMIddle, y2: closeY)
            
            curX -= scX;
        }
    }
    
    func drawCandleChart(ctx : CGContext, window : ChartWindow, scX : CGFloat, currentX : CGFloat, leftBorder : CGFloat, barW : CGFloat, cashItemSeries : TerceraChartCashItemSeries)
    {
        ctx.setShouldAntialias(false)
        var curX = round(currentX);
        let screenData = cashItemSeries.chartScreenData.storage;
        
        let clientRectange = window.clientRectangle;
        
        let barsHighLowColorPenScaled = getPenWithScale(window: window, originalPen: barsHighLowColorPen);
        var barsDownBorderColorPenScaled = getPenWithScale(window: window, originalPen: barsDownBorderColorPen);
        var barsUpBorderColorPenScaled = getPenWithScale(window: window, originalPen: barsUpBorderColorPen);
        let wickDownBorderColorPenScaled = getPenWithScale(window: window, originalPen: wickDownBorderColorPen);
        let wickUpBorderColorPenScaled = getPenWithScale(window: window, originalPen: wickUpBorderColorPen);
        
        for i in stride(from: screenData.count - 1, to: -1, by: -1)
        {
            let item = screenData[i];
            
            let closePrice = item.close;
            let openPrice = item.open;
            let highPrice = item.high;
            let lowPrice = item.low;
            
            
            //Попробую так
            if(item.hole)
            {
                curX -= scX;
                continue;
            }
            
            var closeY = window.pointConverter!.getScreenY(closePrice);
            var openY = window.pointConverter!.getScreenY(openPrice);
            var highY = window.pointConverter!.getScreenY(highPrice);
            var lowY = window.pointConverter!.getScreenY(lowPrice);
            
            
            if(!fitBarByClientRectangle(clientRect: clientRectange, closeY: &closeY, openY: &openY, highY: &highY, lowY: &lowY))
            {
                curX -= scX;
                continue;
            }
            
            //Раньше было определение виков по координатам рисования
            //Оказалось неправильно - при маленьком масштабе, все в вики преобразуется
            let fallenBar = openPrice > closePrice;
            let wickBar = closePrice - openPrice == 0;
            let addBarH = CGFloat(closeY - openY == 0 ? 1 : 0);
            
            var barRect = CGRect();
            var emptyRect = true;
            var barMiddle = curX + leftBorder + barW / 2;
            if(barW == 1)
            {
                barMiddle = curX;
            }
            
            var barColor : CGColor?;
            var barPen :Pen?
            
            //Wick
            if(wickBar)
            {
                ctx.drawLine(pen: barsHighLowColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: lowY);
                
                var leftBorderX = curX + leftBorder;
                //убираем лишний пиксель справа
                var richBorderX = curX + leftBorder + barW;
                //если длинна бара нечетная - декрементируем ее
                if((Int(richBorderX - leftBorderX) % 2) != 0)
                {
                    richBorderX -= 1;
                }
                //гарантируем, что минимум один пиксель будет отрисован
                if(leftBorderX == richBorderX)
                {
                    richBorderX += 1;
                }
                //если толщина бара равна 1px, прорисовываем ее ровно на месте вертикальной линии полностью запретить рисование нельзя из-за #43702
                if(barW == 1)
                {
                    leftBorderX = barMiddle;
                    richBorderX = barMiddle
                }
                
                ctx.drawLine(pen: barsHighLowColorPenScaled, x1: leftBorderX, y1: openY, x2: richBorderX, y2: openY);
            }
                //down red
            else if(fallenBar)
            {
                barColor = barDownColorPen.color;
                barPen = barsDownBorderColorPen
                
                if showWicks{
                    ctx.drawLine(pen: wickDownBorderColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: openY);
                    ctx.drawLine(pen: wickDownBorderColorPenScaled, x1: barMiddle, y1: lowY, x2: barMiddle, y2: closeY);
                }
                
                if(barW == 1)
                {
                    let width = barsDownBorderColorPenScaled.lineWidth;
                    barsDownBorderColorPenScaled.lineWidth = 1;
                    ctx.drawLine(pen: barsDownBorderColorPenScaled, x1: curX + leftBorder, y1: openY, x2: curX + leftBorder, y2: closeY);
                    barsDownBorderColorPenScaled.lineWidth = width;
                }
                else
                {
                    let h = closeY - openY + addBarH;
                    barRect = CGRect(x: curX + leftBorder, y: openY, width: barW, height: h);
                    emptyRect = false;
                }
            }
                //Green up
            else
            {
                barColor = barUpColorPen.color;
                barPen = barsUpBorderColorPen
                
                if showWicks{
                    ctx.drawLine(pen: wickUpBorderColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: closeY);
                    ctx.drawLine(pen: wickUpBorderColorPenScaled, x1: barMiddle, y1: lowY, x2: barMiddle, y2: openY);
                }
                
                if(barW == 1)
                {
                    let width = barsUpBorderColorPenScaled.lineWidth;
                    barsUpBorderColorPenScaled.lineWidth = 1;
                    ctx.drawLine(pen: barsUpBorderColorPenScaled, x1: curX + leftBorder, y1: openY, x2: curX + leftBorder, y2: closeY);
                    barsUpBorderColorPenScaled.lineWidth = width;
                }
                else
                {
                    let h = closeY - openY + addBarH;
                    barRect = CGRect(x: curX + leftBorder, y: openY, width: barW, height: h);
                    emptyRect = false;
                }
            }
            
            //Drawing
            if(!emptyRect)
            {
                if(barColor != nil)
                {
                    ctx.setFillColor(barColor!);
                    ctx.fill(barRect);
                    
                    if(!barRect.isEmpty)
                    {
                        var barBorderRect = barRect;
                        barBorderRect.size.width -= 1
                        ctx.setPen(barPen!)
                        ctx.setShouldAntialias(false)
                        ctx.stroke(barBorderRect)
                    }
                }
            }
            
            curX -= scX;
        }
    }
    
    func drawBarChart(ctx : CGContext, window : ChartWindow, scX : CGFloat, currentX : CGFloat, leftBorder : CGFloat, barW : CGFloat, cashItemSeries : TerceraChartCashItemSeries)
    {
        ctx.setShouldAntialias(false)
        var curX = round(currentX);
        let screenData = cashItemSeries.chartScreenData.storage;
        
        let clientRectange = window.clientRectangle;
        
        let barsHighLowColorPenScaled = getPenWithScale(window: window, originalPen: barsHighLowColorPen);
        let downBorderColorPenScaled = getPenWithScale(window: window, originalPen: barsDownBorderColorPen);
        let upBorderColorPenScaled = getPenWithScale(window: window, originalPen: barsUpBorderColorPen);
        
        
        for i in stride(from: screenData.count - 1, to: -1, by: -1)
        {
            let item = screenData[i];
            
            let closePrice = item.close;
            let openPrice = item.open;
            let highPrice = item.high;
            let lowPrice = item.low;
            
            //Попробую так
            if(item.hole)
            {
                curX -= scX;
                continue;
            }
            
            var closeY = window.pointConverter!.getScreenY(closePrice);
            var openY = window.pointConverter!.getScreenY(openPrice);
            var highY = window.pointConverter!.getScreenY(highPrice);
            var lowY = window.pointConverter!.getScreenY(lowPrice);
            
            if(!fitBarByClientRectangle(clientRect: clientRectange, closeY: &closeY, openY: &openY, highY: &highY, lowY: &lowY))
            {
                curX -= scX;
                continue;
            }
            
            //Раньше было определение виков по координатам рисования
            //Оказалось неправильно - при маленьком масштабе, все в вики преобразуется
            let fallenBar = openPrice > closePrice;
            let wickBar = closePrice - openPrice == 0;
            
            var barMiddle = ceil(curX + leftBorder + barW / 2) - 1;
            if(barW == 1)
            {
                barMiddle = curX;
            }
            
            //Wick
            if(wickBar)
            {
                ctx.drawLine(pen: barsHighLowColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: lowY);
                
                var leftBorderX = curX + leftBorder;
                //убираем лишний пиксель справа
                var richBorderX = curX + leftBorder + barW;
                //если длинна бара нечетная - декрементируем ее
                if((Int(richBorderX - leftBorderX) % 2) != 0)
                {
                    richBorderX -= 1;
                }
                //гарантируем, что минимум один пиксель будет отрисован
                if(leftBorderX == richBorderX)
                {
                    richBorderX += 1;
                }
                //если толщина бара равна 1px, прорисовываем ее ровно на месте вертикальной линии полностью запретить рисование нельзя из-за #43702
                if(barW == 1)
                {
                    leftBorderX = barMiddle;
                    richBorderX = barMiddle
                }
                
                ctx.drawLine(pen: barsHighLowColorPenScaled, x1: leftBorderX, y1: openY, x2: richBorderX, y2: openY);
            }
                //down red
            else if(fallenBar)
            {
                ctx.drawLine(pen: downBorderColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: lowY);
                ctx.drawLine(pen: downBorderColorPenScaled, x1: curX + leftBorder, y1: openY, x2: barMiddle, y2: openY);
                
                let wid = barW == 1 ? barMiddle : curX + leftBorder + barW;
                
                ctx.drawLine(pen: downBorderColorPenScaled, x1: barMiddle, y1: closeY, x2: wid, y2: closeY);
                
            }
                //Green up
            else
            {
                ctx.drawLine(pen: upBorderColorPenScaled, x1: barMiddle, y1: highY, x2: barMiddle, y2: lowY);
                ctx.drawLine(pen: upBorderColorPenScaled, x1: curX + leftBorder, y1: openY, x2: barMiddle, y2: openY);
                
                let wid = barW == 1 ? barMiddle : curX + leftBorder + barW;
                
                ctx.drawLine(pen: upBorderColorPenScaled, x1: barMiddle, y1: closeY, x2: wid, y2: closeY);
            }
            
            curX -= scX;
        }
    }
    
    func drawLineChart(ctx : CGContext, window : ChartWindow, scX : CGFloat, curX : CGFloat, leftBorder : CGFloat, barW : CGFloat, cashItemSeries : TerceraChartCashItemSeries)
    {
        let chartDrawingType = Settings.shared.chartStyle()
        let screenData = cashItemSeries.chartScreenData.storage;
        var curX = curX
        let period = cashItemSeries.cashItem?.period
        let historyType = cashItemSeries.cashItem?.historyType
        
        var points = [CGPoint]();
        var points2 = [CGPoint]();
        var rects = [CGRect]();
        var barDirection = [Bool]();
        
        var dotW:CGFloat;
        
        if (scX < 3)
        {
            dotW = 2;
        }
        else if (scX < 6)
        {
            dotW = 4;
        }
        else if (scX < 16)
        {
            dotW = 6;
        }
        else
        {
            dotW = 8;
        }
        
        //
        // Проходимся по всем барам
        //
        for i in stride(from: screenData.count - 1, to: -1, by: -1)
        {
            
            let item = screenData[i];
            if (item.hole)
            {
                drawPartLines(ctx: ctx, window: window, points: points, points2: points2, period: period!, rects: rects, barDirection: barDirection)
                points.removeAll()
                rects.removeAll();
            }
            
            let closePrice = item.close;
            let openPrice = item.open;
            
            //
            // для тиков только 1 линия не рисуется.
            // BUG #29345  (HDM) Only Bid or only Ask tick line does not drawing
            // 1. при отсутствии одной из вторую рисуем
            if (openPrice == 0 && closePrice == 0)
            {
                curX -= scX;
                continue;
            }
            let closeY = window.pointConverter?.getScreenY(closePrice)
            let openY = window.pointConverter?.getScreenY(openPrice)
            
            
            // Явно неправильные значения - спровоцирует эксепшн при прорисовке
            if ((closePrice != 0 && (closeY! < CGFloat(-1000) || closeY! > CGFloat(10000))) || (openPrice != 0 && (openY! < CGFloat(-1000) || openY! > CGFloat(10000))))
            {
                curX -= scX;
                continue;
            }
            
            var barMIddle = curX + leftBorder + barW / 2
            if (barW == 1)
            {
                barMIddle = curX;
            }
            
            //
            // для тиков только 1 линия не рисуется.
            // BUG #29345  (HDM) Only Bid or only Ask tick line does not drawing
            // 2. то той которой нет не отсеиваем
            
            
            if (closePrice != 0)
            {
                points.append(CGPoint(x:barMIddle, y:closeY!));
            }
            if (openPrice != 0 && period == Periods.TIC && historyType != PFQuoteBarType.trade)
            {
                points2.append(CGPoint(x:barMIddle, y:openY!));
            }
            
            //
            if (chartDrawingType == .dot || chartDrawingType == .dotLine)
            {
                if (closePrice != 0)
                {
                    rects.append(CGRect(x: barMIddle - dotW / 2, y: closeY! - dotW / 2, width: dotW, height: dotW))
                    barDirection.append(openPrice > closePrice);
                }
            }
            else if (chartDrawingType == .solid)
            {
                if (points2.count == 0)
                {
                    points2.append(CGPoint(x: barMIddle, y: closeY!))
                }
                else if (closeY! < points2[0].y)
                {
                    points2[0] = CGPoint(x:barMIddle, y:closeY!);
                }
            }
            curX -= scX;
        }
        
        drawPartLines(ctx: ctx, window: window, points: points, points2: points2, period: period!, rects: rects, barDirection: barDirection)
    }
    
    func drawPartLines(ctx : CGContext, window : ChartWindow, points:[CGPoint], points2:[CGPoint], period:Int, rects:[CGRect],  barDirection:[Bool])
    {
        //
        // Рисование линий
        //
        ctx.setShouldAntialias(true)
        let chartDrawingType = Settings.shared.chartStyle()
        if ((proChart.timeFrameInfo?.aggregationMode.chartDataType == .renko ||
            proChart.timeFrameInfo?.aggregationMode.chartDataType == .threeLinesBreek && chartDrawingType != .line) ||
            period != Periods.TIC)
        {
            if (points.count > 1)
            {
                switch (chartDrawingType)
                {
                case .line:
                    ctx.drawLines(pen: getPenWithScale(window: window, originalPen: barsLineColorPen), points: points)
                    break;
                    
                case .dot:
                    var i = 0;
                    for rect in rects
                    {
                        let cgColor = barDirection[i] ? barDownColorPen.color : barUpColorPen.color
                        ctx.setFillColor(cgColor)
                        ctx.fillEllipse(in: rect)
                        i += 1
                    }
                    break;
                case .dotLine:
                    let barsDownBorderColorPenScaled = getPenWithScale(window:window,originalPen:barDownColorPen);
                    let barsUpBorderColorPenScaled = getPenWithScale(window:window, originalPen:barUpColorPen);
                    var i = 0;
                    for rect in rects
                    {
                        if (i > 0)
                        {
                            ctx.drawLine(pen: barDirection[i - 1] ? barsDownBorderColorPenScaled : barsUpBorderColorPenScaled, point1: points[i - 1], point2: points[i])
                        }
                        let cgColor = barDirection[i] ? barDownColorPen.color : barUpColorPen.color
                        ctx.setFillColor(cgColor)
                        ctx.fillEllipse(in: rect)
                        i += 1
                    }
                    break;
                case .solid:
                    var points = points
                    if points.count == 0
                    {
                        return
                    }
                    let bottom = window.clientRectangle.maxY
                    ctx.drawLines(pen: getPenWithScale(window: window, originalPen: barsLineColorPen), points: points)
                    points.append(CGPoint(x: points[points.count - 1].x, y: bottom))
                    points.append(CGPoint(x: points[0].x, y: bottom))
                    let colors = [solidPriceColorGradient0, solidPriceColorGradient1]
                    
                    //3 - set up the color space
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    
                    //4 - set up the color stops
                    let colorLocations:[CGFloat] = [1.0, 0.0]
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
                    
                    let path = CGMutablePath()
                    let startPoint = CGPoint(x:points[0].x, y:bottom)
                    path.move(to: startPoint)
                    for point in points
                    {
                        path.addLine(to: CGPoint(x:point.x, y: point.y))
                    }
                    path.addLine(to: CGPoint(x: points.last!.x, y: bottom))
                    path.addLine(to: startPoint)
                    
                    
                    ctx.saveGState()
                    ctx.addPath(path)
                    ctx.clip()
                    let boundingBox = path.boundingBox
                    let end = CGPoint(x: boundingBox.minX, y: boundingBox.minY)
                    let start = CGPoint(x: boundingBox.minX, y: boundingBox.maxY)
                    ctx.drawLinearGradient(gradient!, start: start, end:  end, options: CGGradientDrawingOptions.drawsAfterEndLocation)
                    ctx.restoreGState()
                    
                    break;
                default:
                    break;
                }
            }
        }
            //
            // Рисование тиков
            //
        else
        {
            var askLinePen = askLineColorPen
            var bidLinePen = bidLineColorPen
            
            if period == Periods.TIC && proChart.symbol?.instrument.chartBarType == .trade {
                askLinePen = barsLineColorPen
                bidLinePen = barsLineColorPen
            }
            
            if (points.count > 1/* && pro.showAskOnTick*/)
            {
                ctx.drawLines(pen: askLinePen, points: points)
            }
            if (points2.count > 1)
            {
                ctx.drawLines(pen: bidLinePen, points: points2)
            }
        }
        ctx.setShouldAntialias(true)
    }
    
    
    public static func processBarWidth(window : ChartWindow, barW : inout CGFloat, leftBorder : inout CGFloat)
    {
        let barWidth = CGFloat(window.xScale)
        barW = 1;
        if barWidth < 2
        {
            leftBorder = 0
            barW  = CGFloat(barWidth)
        }
        else if barWidth == 2
        {
            leftBorder = 1;
            barW = 1;
        }
        else if barWidth == 3
        {
            leftBorder = 1;
            barW = 2;
        }
        else if barWidth == 4
        {
            leftBorder = 1;
            barW = 3;
        }
        else if barWidth == 5
        {
            leftBorder = 1;
            barW = 3;
        }
        else if  barWidth <= 8
        {
            leftBorder = 2
            let left:CGFloat = (Int(barWidth) % 2) == 0 ? 1 : 0
            barW = barWidth - (leftBorder * 2) + left
        }
        else if  barWidth <= 12
        {
            leftBorder = 3
            let left:CGFloat = (Int(barWidth) % 2) == 0 ? 1 : 0
            barW = barWidth - (leftBorder * 2)  + left
        }
        else if barWidth <= 25
        {
            leftBorder = 4
            let left:CGFloat = (Int(barWidth) % 2) == 0 ? 1 : 0
            barW = barWidth - (leftBorder * 2) + left
        }
        else
        {
            leftBorder = 6
            let left:CGFloat = (Int(barWidth) % 2) == 0 ? 1 : 0
            barW = barWidth - (leftBorder * 2) + left
        }
       
    }
    
    private func fitBarByClientRectangle(clientRect : CGRect, closeY : inout CGFloat, openY : inout CGFloat, highY : inout CGFloat, lowY : inout CGFloat) -> Bool
    {
        let top = clientRect.minY;
        let bottom = clientRect.maxY;
        
        //Рисуем если хоть 1 условие проходит, остальные значения обрубываем до границ экрана
        if(highY < top || lowY > bottom)
        {
            //Явно неправильные значения (бар полностью не виден) - не рисуем
            if(lowY < top || highY > bottom)
            {
                return false;
            }
            else
            {
                if(closeY < top && openY < top)
                {
                    //нельзя в таком случае
                }
                else
                {
                    //часть нуждается в корректировке
                    if(closeY < top)
                    {
                        closeY = top;
                    }
                    if(openY < top)
                    {
                        openY = top;
                    }
                }
                if(highY < top)
                {
                    highY = top;
                }
                if(closeY > bottom)
                {
                    closeY = bottom;
                }
                if(openY > bottom)
                {
                    openY = bottom;
                }
                if(lowY > bottom)
                {
                    lowY = bottom;
                }
            }
        }
        return true;
    }
    
    func getPenWithScale(window : ChartWindow, originalPen : Pen) -> Pen
    {
        let chartDrawingType = Settings.shared.chartStyle()
        let scale = Int(window.xScale);
        var width = originalPen.lineWidth;
        
        if(chartDrawingType == TerceraChartDrawingType.line || chartDrawingType == TerceraChartDrawingType.solid){
            return originalPen;
        }
        
        if(scale < 16)
        {
            return originalPen;
        }
        else if(scale <= 25)
        {
            if(chartDrawingType == TerceraChartDrawingType.candle)
            {
                width = 1;
            }
            else
            {
                width = 2;
            }
        }
        else if(scale >= 50 && scale <= 200)
        {
            width = 3;
        }
        
        return Pen(color: originalPen.color, lineWidth: width);
    }
}
