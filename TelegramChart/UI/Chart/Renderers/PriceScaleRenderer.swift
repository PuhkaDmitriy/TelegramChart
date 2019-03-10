//
//  PriceScaleRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

enum TerceraChartPriceScaleRendererWindowType
{
    case main
    case overlay
    case indicator
    case indicatorOverlay
}

class PriceScaleRenderer: TerceraChartNumberScaleRenderer {

    weak var window : ChartWindow?;
   
    
    init(chartBase : ChartBase, winType : TerceraChartPriceScaleRendererWindowType = TerceraChartPriceScaleRendererWindowType.main)
    {
        windowType = winType
        super.init(chartBase: chartBase)
    }
   
    var windowType : TerceraChartPriceScaleRendererWindowType;

    var minimumValuesStep:Double = 0
    var minumumPixelStep:CGFloat = 0
    var digitsBasedOnIndicator:Int = -1
    var maxC:CGFloat = 0
    var minC:CGFloat = 0
    
   
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?)
    {
        if (!visible || rectangle == CGRect.zero)
        {
            return
        }
        ctx.setShouldAntialias(false)
        
        var priceAttribute = [NSAttributedStringKey : NSObject]();
        priceAttribute[NSAttributedStringKey.font] = settings.scaleFont;
        priceAttribute[NSAttributedStringKey.foregroundColor] = settings.scaleTextColor;
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.allowsDefaultTighteningForTruncation = false
        priceAttribute[NSAttributedStringKey.paragraphStyle] = paragraphStyle
     
        let fontHeightPixels = NSAttributedString(string: " ", attributes: priceAttribute).size().height
        ctx.setShouldAntialias(false)
        ctx.drawLine(pen: self.settings.scaleAxisPen, x1: self.rectangle.minX, y1: self.rectangle.minY, x2: self.rectangle.minX, y2: self.rectangle.maxY)
        
        let minV = window!.fMinFloatY
        let maxV = window!.fMaxFloatY
        
        if (minV == Double.greatestFiniteMagnitude || maxV == -Double.greatestFiniteMagnitude || minV == maxV || minV.isInfinite || maxV.isInfinite)
        {
            return;
        }
       
        let windowClientRect = window?.clientRectangle
        
        ctx.saveGState();
        
      
        ctx.addRect(CGRect(x:windowClientRect!.origin.x, y:windowClientRect!.origin.y,width: windowClientRect!.width + rectangle.width,height: windowClientRect!.height));
        
        ctx.clip()
        
        maxC = rectangle.maxY;
        minC = rectangle.minY;
        var step = calcStep(maxV: maxV, minV: minV, maxC: maxC, minC: minC, itemheight: fontHeightPixels + 18 )
        
        let symbol = chartBase?.symbol
        
        let activeInstrumentPipSize:Double = symbol != nil ? symbol!.defaultTickGroup.tickSize: 0;
        
        var seriesDataType = TerceraChartCashItemSeriesDataType.absolute;
        switch (windowType)
        {
        case TerceraChartPriceScaleRendererWindowType.main,
             TerceraChartPriceScaleRendererWindowType.overlay:
            if let series = (chartBase as! ProChart).mainPriceRenderer?.series
            {
                seriesDataType = series.settings.dataType
            }
    
            break;
            
        // For indicator - always use absolute
        case TerceraChartPriceScaleRendererWindowType.indicator:
            seriesDataType = TerceraChartCashItemSeriesDataType.absolute;
            break;
        default:
            break
        }
        
        step = correctStep(step: step, symbol: symbol, activeInstrumentPipSize: activeInstrumentPipSize, seriesDataType: seriesDataType);
        let start = calcStart(step: step, minV: minV);
        
        var iterCount = 0;
        //        let gridPath = CGMutablePath()
        
        for vi in stride(from: start, to: (maxV + step * 3), by: step)
        {
            // +++ correct value
            
            iterCount += 1;
            let ci = round(window!.pointConverter!.getScreenY(vi)) - rectangle.maxY;
            
            
            let ty = (maxC + ci);
            
            if ((ty > rectangle.minY) && (ty < rectangle.maxY))
            {
                if (window!.paddingTop < ty)
                {
                    ctx.setShouldAntialias(false)
                    ctx.setPen(settings.scaleGridPen)
                    ctx.drawLine(x1: window!.clientRectangle.minX, y1: ty, x2: rectangle.minX, y2: ty)
                    
                    // draw nail
                    ctx.setPen(settings.scaleAxisPen)
                    ctx.drawLine(x1: rectangle.minX, y1: ty, x2: rectangle.minX + 3, y2: ty)
                }
                
                let formatedValue = PriceScaleRenderer.formatPrice(vi: vi, seriesDataType: seriesDataType, scaleRenderer: self)
               
                let rect = CGRect(x: (rectangle.minX + 4), y: CGFloat(ty - fontHeightPixels / 2 - 1), width: rectangle.width, height: fontHeightPixels)
                let attributedString = NSAttributedString(string: formatedValue, attributes: priceAttribute)
                ctx.setShouldAntialias(true)
                if rect.minY > windowClientRect!.minY && rect.maxY < windowClientRect!.maxY
                {
                    attributedString.draw(in: rect)
                }
            }
            
            //
            // Защита от зацикливания
            //
            if (iterCount > 1000)
            {
                return;
            }
            
        }
        
        ctx.restoreGState()
    }
   
    
    static func formatPrice(vi:Double,  seriesDataType:TerceraChartCashItemSeriesDataType,  scaleRenderer:PriceScaleRenderer) -> String
    {
        let symbol = scaleRenderer.chartBase?.symbol;
        
        var formatedValue = "";
        if (scaleRenderer.windowType == TerceraChartPriceScaleRendererWindowType.indicator)
        {
            if (scaleRenderer.digitsBasedOnIndicator != -1)
            {
                formatedValue = String.init(format: "%\(scaleRenderer.digitsBasedOnIndicator)f", vi);
            }
            else if (symbol != nil)
            {
                formatedValue = symbol!.formatPrice(vi, useVariableTickSize: false);
            }
        }
        else if (seriesDataType == TerceraChartCashItemSeriesDataType.relative)
        {
            formatedValue = String.init(format: "%2f%", vi);
        }
        else if (seriesDataType == TerceraChartCashItemSeriesDataType.log)
        {
            var t = vi
            if let series = (scaleRenderer.chartBase as! ProChart).mainPriceRenderer?.series
            {
                t = series.settings.logDataConverter.revert(vi)
            }
           
            if (symbol != nil)
            {
                formatedValue = symbol!.formatPrice(t, useVariableTickSize: false);
            }
        }
        else
        {
            if (symbol != nil)
            {
                formatedValue = symbol!.formatPrice(vi, useVariableTickSize:  false);
            }
            else
            {
                formatedValue = "\(vi)";
            }

        }
        return formatedValue;
    }
    
    
    private func correctStep(step:Double, symbol:SymbolInfo?, activeInstrumentPipSize:Double, seriesDataType:TerceraChartCashItemSeriesDataType) -> Double
    {
        var innerStep:Double = step
        if (symbol != nil && seriesDataType == TerceraChartCashItemSeriesDataType.absolute)
        {
            //
            // 1. Шаг не меньше, чем MinDelta цены инструмента
            //
            if (innerStep < symbol!.defaultTickGroup.tickSize)
            {
                innerStep = symbol!.defaultTickGroup.tickSize;
            }
            else
            {
                innerStep = Utils.roundingToStep(innerStep, stepSize: symbol!.defaultTickGroup.tickSize)
            }
        }
        
        return innerStep;
    }
    
    
    
    
    /// <summary>
    /// Calculate preferred scale width
    /// Should know it before drawing to layout renderers
    /// </summary>
    func getPreferredWidth(_ series:TerceraChartCashItemSeries?, symbol:SymbolInfo?) -> CGFloat
    {
        let font = settings.scaleFont
        guard let symbol = symbol else {return Sizes.chartMinPriceScaleWidth}
        var maxW:CGFloat = 0;
        var seriesDataType = TerceraChartCashItemSeriesDataType.absolute
        switch (windowType)
        {
        case TerceraChartPriceScaleRendererWindowType.main,
             TerceraChartPriceScaleRendererWindowType.overlay:
            seriesDataType = series != nil ? series!.settings.dataType : TerceraChartCashItemSeriesDataType.absolute;
            break;
            
        // For indicator - always use absolute
        case TerceraChartPriceScaleRendererWindowType.indicator:
            seriesDataType = TerceraChartCashItemSeriesDataType.absolute;
            break;
        default:
            break;
        }
        
        var values = [window?.fMinFloatY, window?.fMaxFloatY];
        
        for i in 0...values.count - 1
        {
            
            var formatedValue = "";
            if (seriesDataType == TerceraChartCashItemSeriesDataType.relative)
            {
                formatedValue = String.init(format: "%2f%", values[i]!)
            }
            else if (seriesDataType == TerceraChartCashItemSeriesDataType.log)
            {
                let t = series!.settings.logDataConverter.revert(values[i]!);
                formatedValue = symbol.formatPrice(t, useVariableTickSize: false);
            }
            else
            {
                formatedValue = symbol.formatPrice(values[i]!, useVariableTickSize: false);
            }
            var attribute = [NSAttributedStringKey : NSObject]();
            attribute[NSAttributedStringKey.font] = font;
            
            let attrString = NSAttributedString.init(string: formatedValue, attributes: attribute);
            
            let curW = attrString.size().width + 8;
            
            if (maxW < curW)
            {
                maxW = curW;
            }
        }
        
        
        var res = maxW + 6;
        res = max(Sizes.chartMinPriceScaleWidth,res)
        //
        // alexb: релатив от начала экрана+пограничные значения - приводят к багу #52741
        //        В таком случае включая режим ширины только на увеличение со сбросом при смене инструмента
        //
        if (seriesDataType == TerceraChartCashItemSeriesDataType.relative && series != nil && series!.settings.basisType == TerceraChartCashItemSeriesDataTypeBasisType.beginOfScreen)
        {
            // reset on change symbol
            if (prevSymbol != symbol.symbolID)
            {
                prevPreferredWidth = 0;
            }
            
            res = max(prevPreferredWidth, res);
            
            prevPreferredWidth = res;
            prevSymbol = symbol.symbolID;
        }
        
        return res;
    }
    
    fileprivate var prevPreferredWidth:CGFloat = 0;
    fileprivate var prevSymbol:PFSymbolId?;
    
    var yDeltaPx:CGFloat = 0;
    var yDeltaPrice:Double = 0;
    
  
}
