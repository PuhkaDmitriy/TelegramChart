//
//  ChartWindow.swift
//  Protrader 3
//
//  Created by Yuriy on 03/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class ChartWindow: Any {
    static let SCALE_LIMIT : Double = 100000000;
    var isMainWindow : Bool = false;
    var autoScale : Bool = true;
    var needRecalcAutoScale : Bool = false;
    var stickToEnd : Bool = true;
    var autoscaleMinDelta : Int = 1;
    var autoscaleMaxDelta : Int = 1;
    var autoScalePaddPixel : Double = 20;
    var collapsed : Bool = false;
    
    var paddingLeft : CGFloat = 0;
    var paddingTop : CGFloat = 0;
    var paddingRight : CGFloat = 0;
    var paddingBottom : CGFloat = 0;
    var mainDrawPointers = [DrawPointer]()
    var toolsDrawPointers:[DrawPointer] = []

    
    var rectangle : CGRect = CGRect();
    
    var clientRectangle : CGRect
    {
        get
        {
            let x = self.rectangle.origin.x + self.paddingLeft
            let y = self.rectangle.origin.y + self.paddingTop
            let width = self.rectangle.size.width - self.paddingLeft - self.paddingRight
            let height = self.rectangle.size.height - self.paddingTop - self.paddingBottom
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    var indicatorRendererSettings = TerceraChartIndicatorRenererSettings()
    
    var lastPriceScaleMinFloatY : Double = -1;
    var lastPriceScaleMaxFloatY : Double = -1;
    
    var fMinFloatY : Double = 0;
    var fMaxFloatY : Double = 0;
    
    var fMinYTotal : Double = 0;
    var fMaxYTotal : Double = 0;
    
    //Индекс крайнего правого отображаемого бара
    var i1 : Int = 0

    var xScale : Double = 0;
    var yScale : Double = 0;
    
    var tradingToolRenderer : TradingToolsRenderer?
    var priceScaleRenderer : PriceScaleRenderer?
    var headerRenderer: ProHeaderRenderer?
    
    var im : Double
    {
        get
        {
            return Double(self.clientRectangle.size.width) / self.xScale;
        }
    }
    var cursorRenderers = [BaseRenderer]()
    var renderers = [BaseRenderer]()
    weak var windowContainer : WindowContainer?;
    
    var pointConverter : IPointConverter?;
    
    weak var chart:ProChart?
    
    init(chart:ProChart, priceScaleRenderer:PriceScaleRenderer) {
        self.xScale = 10
        self.priceScaleRenderer = priceScaleRenderer
        self.chart = chart
        
        paddingLeft = 0;
        paddingTop = 0;
        paddingRight = 40;
        paddingBottom = 0;
        
        fMinFloatY = 0;
        fMaxFloatY = 0;
    }
    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        beforeDrawing()
        for r in self.renderers
        {
            let renderer = r;
            
            if(!self.collapsed || renderer is PriceScaleRenderer)
            {
                renderer.draw(layer, in: ctx, window: self, windowsContainer: windowContainer)
            }
        }
        drawAllMainPointers(ctx)
    }
    
    func beforeDrawing()
    {
        self.calcScales();
        mainDrawPointers = [DrawPointer]()
        self.onLayout();
        
        //Подумать нужно ли это вообще
        //par!.tag[TerceraChartRendererDrawingAdvancedParamsEnum] = TerceraChartToolRendererDrawingType.Background
        
    }
    
    func drawAllToolsPointers(_ context : CGContext)
    {
        toolsDrawPointers.sort(by: { (x, y) -> Bool in
            if (x.drawPointerTypeEnum != y.drawPointerTypeEnum)
            {
                return y.drawPointerTypeEnum.rawValue < x.drawPointerTypeEnum.rawValue;
            }
            else
            {
                return x.priceValue < y.priceValue
            }
        })
        
        for pointer in toolsDrawPointers
        {
            context.drawPointer(window: self, yScaleValue: pointer.priceValue, br: pointer.backgroundBrush, text: pointer.formatPriceValue, yLocation: pointer.yLocation, textColor: pointer.textColor)
        }
        
    }
    
    func drawAllMainPointers(_ context : CGContext)
    {
        mainDrawPointers.sort(by: { (x, y) -> Bool in
            if (x.drawPointerTypeEnum != y.drawPointerTypeEnum)
            {
                return y.drawPointerTypeEnum.rawValue < x.drawPointerTypeEnum.rawValue;
            }
            else
            {
                return x.priceValue < y.priceValue
            }
        })
        
        for pointer in mainDrawPointers
        {
           context.drawPointer(window: self, yScaleValue: pointer.priceValue, br: pointer.backgroundBrush, text: pointer.formatPriceValue, yLocation: pointer.yLocation, textColor: pointer.textColor)
        }
        
    }
    
       
    var indicatorStorageRenderer : IndicatorStorageRenderer?
    
    var getAllRenderers : [BaseRenderer]
    {
        get
        {
            var allRenderers = [BaseRenderer]()
            allRenderers.append(self.priceScaleRenderer!)
            allRenderers.append(self.tradingToolRenderer!)
            allRenderers += self.renderers
            allRenderers += self.cursorRenderers
            return allRenderers;
        }
    }
       
    
    func onLayout()
    {
        
        if isMainWindow
        {
            paddingTop = (headerRenderer?.height ?? 0) + (chart?.aggregationTypeView?.frame.height ?? 0)
        }
        
        //layout PaddingRenderers
        paddingRight = chart!.preferedPriceScaleWidht
        
        let clientR = clientRectangle
        if priceScaleRenderer != nil
        {
            priceScaleRenderer?.rectangle = CGRect(x:clientR.maxX, y:clientR.origin.y, width:paddingRight, height:clientR.height)
        }
        if isMainWindow
        {
            self.headerRenderer?.rectangle = CGRect(x: 0, y: 0, width: self.chart!.frame.width, height: self.headerRenderer!.height)
        }
    }
    
    func autoFit()
    {
        self.needRecalcAutoScale = true;
    }
    
    func calcScales()
    {
        if(self.fMaxFloatY == self.fMinFloatY)
        {
            self.yScale = 0;
        }
        else
        {
            self.yScale = Double(self.clientRectangle.size.height) / (self.fMaxFloatY - self.fMinFloatY);
        }
    }
    
    func needRedrawPriceScale() -> Bool
    {
        if self.fMaxFloatY != lastPriceScaleMaxFloatY || self.fMinFloatY != lastPriceScaleMinFloatY
        {
            lastPriceScaleMaxFloatY = self.fMaxFloatY
            lastPriceScaleMinFloatY = self.fMinFloatY
            return true
        }
        return false
    }

    
    func calculateMinMax()
    {
       
        if(self.needRecalcAutoScale)
        {
            self.needRecalcAutoScale = false;
        }
        
        var newFminFloatY : Double = Double.greatestFiniteMagnitude;
        var newFmaxFloatY : Double = -Double.greatestFiniteMagnitude;
        
        var tMin : Double = 0;
        var tMax : Double = 0;
        for renderer in self.getAllRenderers
        {
            
            if(renderer.useInAutoScale && renderer.findMinMax(&tMin, max: &tMax, window: self))
            {
                if(tMin < newFminFloatY)
                {
                    newFminFloatY = tMin;
                }
                if(tMax > newFmaxFloatY)
                {
                    newFmaxFloatY = tMax;
                }
            }
        }
        
        if(newFminFloatY == Double.greatestFiniteMagnitude && newFmaxFloatY == -Double.greatestFiniteMagnitude)
        {
            //Никто не дал мин/макс - оставляем предыдущие значения
            //пример: скрытие всех линий индикатора на дополнительном окне
            return
        }
        else
        {
            //если так совпало что мин и макс одинаковы... чтоб не было на шкале вечного нуля
            if(newFminFloatY == newFmaxFloatY)
            {
                newFminFloatY -= Double(autoscaleMinDelta);
                newFmaxFloatY += Double(autoscaleMaxDelta);
            }
            
            self.addPaddingY(&newFminFloatY, max: &newFmaxFloatY)
            
            
            self.fMinFloatY = newFminFloatY;
            self.fMaxFloatY = newFmaxFloatY;
            return
        }
    }
    
    func addPaddingY(_ min : inout Double, max : inout Double)
    {
        if(min != max)
        {
            let padding = self.autoScalePaddPixel / (Double(self.clientRectangle.size.height) / abs(max - min));
            min -= padding;
            max += padding;
        }
    }
    
//    let zoomValues = [ 1, 2, 3, 4, 6, 8, 12, 16, 25,  50, 100, 200];
//
//    var activeZoomLevels : [Int]
//    {
//        get
//        {
//            return zoomValues;
//        }
//    }
//
//    var canZoomIn : Bool
//    {
//        get
//        {
//            return xScale < Double(activeZoomLevels[activeZoomLevels.count - 1]);
//        }
//    }
//
//    var canZoomOut : Bool
//    {
//        get
//        {
//            return xScale > Double(activeZoomLevels[0]);
//        }
//    }
//
//    func zoomIn()
//    {
//        var scaleIndex = activeZoomLevels.index(of: Int(xScale))!;
//        scaleIndex += 1;
//        if(scaleIndex < activeZoomLevels.count)
//        {
//            checkAndSetXscale(new: activeZoomLevels[scaleIndex]);
//        }
//    }
//
//    func zoomOut()
//    {
//        var scaleIndex = activeZoomLevels.index(of: Int(xScale))!;
//        scaleIndex -= 1;
//        if(scaleIndex < activeZoomLevels.count && scaleIndex >= 0)
//        {
//            checkAndSetXscale(new: activeZoomLevels[scaleIndex]);
//        }
//    }
    
    let minXScale = 2
    let maxXScale = 40
    
    func checkAndSetXscale(new : Int)
    {
        if new < minXScale
        {
            xScale = Double(minXScale)
        }
        else if new > maxXScale
        {
            xScale = Double(maxXScale)
        }
        else
        {
            xScale = Double(new)
        }
    }
}
