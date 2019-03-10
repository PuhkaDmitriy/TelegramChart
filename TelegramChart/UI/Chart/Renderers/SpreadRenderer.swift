//
//  SpreadRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 13/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class SpreadRenderer: BaseRenderer {
    var spreadBrush:CGColor!
    var askPen:Pen!
    var askBrush:UIColor!
    var bidPen:Pen!
    var bidBrush:UIColor!
    var lastPen:Pen!
    var lastBrush:UIColor!
    
    var spreadIncorrectBackBrush:CGColor!
    var priceIndicatorDrawingType = TercaraChartPriceIndicatorType.scaleMarker
    var terceraChartSpreadType = TerceraChartSpreadType.lines
    var priceScaleFont = Font.avenirRoman11
    
    override init(chartBase:ChartBase) {
        super.init(chartBase: chartBase)
        self.themeChanged(true)
    }
    
    func themeChanged(_ resetLayout: Bool) {
        spreadBrush = Colors.instance.chart_SpreadBrush.cgColor
        spreadIncorrectBackBrush = Colors.instance.chart_SpreadIncorrectBackBrush.cgColor
        askPen = Pen(color: Colors.instance.sellColor.withAlphaComponent(0.5).cgColor,dashStyle:.shaped)
        bidPen = Pen(color: Colors.instance.buyColor.withAlphaComponent(0.5).cgColor, dashStyle:.shaped)
        lastPen = Pen(color: Colors.instance.chart_lastPrice_LastIndicatorColor.withAlphaComponent(0.5).cgColor,dashStyle:.shaped)
        askBrush = Colors.instance.sellColor
        bidBrush = Colors.instance.buyColor
        lastBrush = Colors.instance.chart_lastPrice_LastIndicatorColor
    }
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
    
        ctx.saveGState()
        if (!self.visible)
        {
            return;
        }
        guard let chart = self.chartBase as? ProChart else {return}
        
        guard let symbol = chart.symbol else {return}
        guard let account = chart.account else {return}
        
        if (symbol.quote == nil)
        {
            return;
        }
        
        guard let dataType = chart.cashItemSeriesSettings?.dataType else {return}
        let lastValueClipRect = chart.mainWindow?.priceScaleRenderer?.rectangle;
        let mainClipRect = window!.clientRectangle;
        guard let cashItemSeries = chart.mainPriceRenderer?.series else {return}
        
        ctx.addRect(CGRect(x: mainClipRect.minX, y: mainClipRect.minY, width: lastValueClipRect!.maxX - mainClipRect.minX, height: lastValueClipRect!.maxY - mainClipRect.minY))
        ctx.clip()
        //        #region Main pointer
        //
        // for tick own case
        let tickPeriod = cashItemSeries.cashItem?.period == Periods.TIC;
        let bidPrice = cashItemSeries.cashItem?.historyType != PFQuoteBarType.ask;
        let tradePrice = cashItemSeries.cashItem?.historyType == PFQuoteBarType.trade;
        
        var curPriceValue:Double = 0;
        var invertCurPriceValue:Double = 0;
        
        var spreadBid:Double = 0;
        var spreadAsk:Double = 0;
        var spreadLast:Double = 0;
        var spreadBidY:CGFloat = 0;
        var spreadAskY:CGFloat = 0;
        var spreadLastY:CGFloat = 0;
        
        var spreadlastFormated = "";
        var formatcurPriceValue = "";
        var invertFormatcurPriceValue = "";
        let quote = symbol.quote;
        let spreadPlanID = account.spreadPlanID
        
        switch (dataType)
        {
        case TerceraChartCashItemSeriesDataType.absolute:
            
            spreadBid = quote.bid(spreadPlanID)
            spreadAsk = quote.ask(spreadPlanID)
            spreadBidY = window!.pointConverter!.getScreenY(spreadBid);
            spreadAskY = window!.pointConverter!.getScreenY(spreadAsk);
            
            spreadLast = quote.lastPrice;
            spreadLastY = window!.pointConverter!.getScreenY(spreadLast);
            spreadlastFormated = symbol.formatPrice(spreadLast, useVariableTickSize: true)
            
            curPriceValue = bidPrice ? spreadBid : spreadAsk;
            invertCurPriceValue = bidPrice ? spreadAsk : spreadBid;
            
            formatcurPriceValue = symbol.formatPrice(curPriceValue, useVariableTickSize: true)
            invertFormatcurPriceValue = symbol.formatPrice(invertCurPriceValue, useVariableTickSize: true)
            
            break;
            
        case TerceraChartCashItemSeriesDataType.relative:
            
            spreadBid = cashItemSeries.settings.relativeDataConverter.calculate(quote.bid(spreadPlanID))
            spreadAsk = cashItemSeries.settings.relativeDataConverter.calculate(quote.ask(spreadPlanID))
            spreadBidY = window!.pointConverter!.getScreenY(spreadBid);
            spreadAskY = window!.pointConverter!.getScreenY(spreadAsk);
            
            spreadLast = cashItemSeries.settings.relativeDataConverter.calculate(quote.lastPrice)
            spreadLastY = window!.pointConverter!.getScreenY(spreadLast);
            spreadlastFormated = String.init(format: "%2f%", spreadLast);
            
            curPriceValue = bidPrice ? spreadBid : spreadAsk;
            invertCurPriceValue = bidPrice ? spreadAsk : spreadBid;
            
            formatcurPriceValue = String.init(format: "%2f%", curPriceValue);
            invertFormatcurPriceValue = String.init(format: "%2f%", invertCurPriceValue);
            
            
            break;
            
        case TerceraChartCashItemSeriesDataType.log:
            spreadBid = cashItemSeries.settings.logDataConverter.calculate(quote.bid(spreadPlanID))
            spreadAsk = cashItemSeries.settings.logDataConverter.calculate(quote.ask(spreadPlanID))
            spreadBidY = window!.pointConverter!.getScreenY(spreadBid);
            spreadAskY = window!.pointConverter!.getScreenY(spreadAsk);
            
            spreadLast = cashItemSeries.settings.logDataConverter.calculate(quote.lastPrice)
            spreadLastY = window!.pointConverter!.getScreenY(spreadLast);
            spreadlastFormated = symbol.formatPrice(cashItemSeries.settings.logDataConverter.revert(spreadLast), useVariableTickSize: true)
            curPriceValue = bidPrice ? spreadBid : spreadAsk;
            invertCurPriceValue = bidPrice ? spreadAsk : spreadBid;
            
            formatcurPriceValue = symbol.formatPrice(cashItemSeries.settings.logDataConverter.revert(curPriceValue), useVariableTickSize: true)
            invertFormatcurPriceValue = symbol.formatPrice(cashItemSeries.settings.logDataConverter.revert(invertCurPriceValue), useVariableTickSize: true)
            
            break;
        }
        //
        if (self.priceIndicatorDrawingType != TercaraChartPriceIndicatorType.none)
        {
            //
            // BID/ASK marker
            //
            if (!tradePrice)
            {
                if (tickPeriod)
                {
                    if curPriceValue >= 0
                    {
                        window?.mainDrawPointers.append(DrawPointer(drawPointerTypeEnum: DrawPointerTypeEnum.bidAsk, curPriceValue: curPriceValue, backgroundBrush: bidPrice ? bidBrush.cgColor : askBrush.cgColor, formatcurPriceValue: formatcurPriceValue))
                    }
                    if invertCurPriceValue >= 0
                    {
                        window?.mainDrawPointers.append(DrawPointer(drawPointerTypeEnum: DrawPointerTypeEnum.bidAsk, curPriceValue: invertCurPriceValue, backgroundBrush: bidPrice ? askBrush.cgColor : bidBrush.cgColor, formatcurPriceValue: invertFormatcurPriceValue))
                    }
                }
                else
                {
                    if (curPriceValue >= 0)
                    {
                        ctx.setShouldAntialias(false)
                        let color = bidPrice ? bidBrush.cgColor : askBrush.cgColor
                        let pen = bidPrice ? bidPen : askPen
                        ctx.drawLine(pen: pen, x1: mainClipRect.minX + 2, y1: spreadLastY, x2: mainClipRect.maxX - 1, y2: spreadLastY)
                        window?.mainDrawPointers.append(DrawPointer(drawPointerTypeEnum: DrawPointerTypeEnum.bidAsk, curPriceValue: curPriceValue, backgroundBrush: color,formatcurPriceValue:formatcurPriceValue))
                    }
                }
                //TerceraChartUtils.DrawPointer(gr, window, curPriceValue, bidPrice ? bidBrush : askBrush, formatcurPriceValue);
            }
                //
                // Trade marker
                //
            else
            {
                curPriceValue = spreadLast;
                // last
                if curPriceValue >= 0
                {
                   
                    ctx.setShouldAntialias(false)
                    ctx.drawLine(pen: lastPen, x1: mainClipRect.minX + 2, y1: spreadLastY, x2: mainClipRect.maxX - 1, y2: spreadLastY)
                    
                    window?.mainDrawPointers.append(DrawPointer(drawPointerTypeEnum: DrawPointerTypeEnum.bidAsk, curPriceValue: spreadLast, backgroundBrush: lastBrush.cgColor, formatcurPriceValue: spreadlastFormated))
                }
            }
        }
        
    
        ctx.restoreGState()
    }
    
}
