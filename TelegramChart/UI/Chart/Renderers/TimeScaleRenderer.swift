//
//  TimeScaleRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 03/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TimeScaleRenderer: BaseRenderer {

    var settings : TerceraChartTimeScaleRendererSettings;
    let stepMinutes : [Int] = [1, 5, 15, 30, 60, 240, 1440, 2880, 4320, 5760, 7200, 14400, 43200, 86400, 129600, 432000];
    
    override init(chartBase : ChartBase)
    {
        self.settings = (chartBase as! ProChart).timeScaleRendererSettings;
        super.init(chartBase: chartBase)
    }
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?)
    {
        guard  let windowsContainer = windowsContainer else {return}
        ctx.saveGState();
    
        ctx.setShouldAntialias(false)

        
        ctx.setPen(settings.scaleAxisPen)
        
        ctx.move(to: CGPoint(x: window!.windowContainer!.mainWindow!.clientRectangle.minX, y: rectangle.minY));
        ctx.addLine(to: CGPoint(x: window!.windowContainer!.mainWindow!.clientRectangle.maxX, y: rectangle.minY));
        ctx.strokePath();
        
        let cashItemSeries = self.series;
        
        if(cashItemSeries == nil)
        {
            //restore state
            ctx.restoreGState();
            
            return;
        }
        
        let screenData = cashItemSeries!.chartScreenData.storage;
        
        if(screenData.count == 0)
        {
            ctx.restoreGState();
            return;
        }
 
        var allItems : [NSMutableArray?] = Array<NSMutableArray?>(repeating: nil, count: 5);
        for i in 0..<allItems.count
        {
            allItems[i] = NSMutableArray();
        }
        var pixelMap = [Bool](repeating: false, count: Int(self.rectangle.size.width));
        
        let TEXT_PADDING_ADDITIONAL = 6;
        let TEXT_PLATE_SIZE = 14;
        
        //1. Определяем подходящий шаг в пикселях (не чаще чем)
        // Пока фиксируем, потом возможно будем реагировать на шрифт
        let stepPixel : Int = 45;
        
        //2. Определяем подходящий шаг в минутах
        var stepMin : Int = -1;
        let currentPeriod : Int = cashItemSeries!.cashItem!.period;
        
        
            for i in 0..<stepMinutes.count
            {
                if(Int(Double(stepMinutes[i]) / Double(currentPeriod) * window!.xScale) >= stepPixel)
                {
                    stepMin = stepMinutes[i];
                    break;
                }
            }
            
            if(stepMin == -1)
            {
                stepMin = stepMinutes[stepMinutes.count - 1];
            }
            
            //По идее не должно быть такого, столкнулся на месяце при крупном масштабе
            if(stepMin < currentPeriod)
            {
                stepMin = currentPeriod;
            }
        
        
        //3. Расчитываем данные для шкалы
        let scX = Int(window!.xScale);
        var curX : Double = Double(window!.clientRectangle.maxX);
        
        var lastDrawingX : Int = 0;
        
        
        let timeScaleRect = CGRect(x: window!.windowContainer!.mainWindow!.clientRectangle.minX, y: window!.windowContainer!.rectangle.minY, width: window!.windowContainer!.mainWindow!.clientRectangle.width, height: window!.windowContainer!.rectangle.height)
        
       
   
        
        for i in stride(from: screenData.count - 1, through: 0, by: -1)
        {
            let curData = screenData[i]
            let dt = curData.dateTime
            //Важно округлять в меньшую сторонуя, т.к. смещаются бары (связано с определением ширины бара: TerceraChartMainPriceRenderer.ProcessBarWidth)
            let currentDrawingX = Int(floor(curX - window!.xScale / 2));
            var isMultiplier = false;
            if(stepMin == 0)
            {
                //Чтобы не рисовать сильно часто
                if(curData.dateChangeType != .none || abs(currentDrawingX - lastDrawingX) > stepPixel)
                {
                    isMultiplier = true;
                    lastDrawingX = currentDrawingX;
                }
            }
                //Если шаг равет периоду - на уаждом баре
            else if(stepMin == currentPeriod)
            {
                isMultiplier = true;
            }
                //Шаг меньше дня - часы+минут должны быть кратны
            else if(stepMin < Periods.DAY)
            {
                isMultiplier = (curData.hour * 60 + curData.minute) % stepMin == 0;
                
                //Сепаратор может находиться на любом баре
                if(!isMultiplier && curData.dateChangeType != .none)
                {
                    isMultiplier = true;
                }
            }
                //Шаг день - на баре должна быть смена дня (или старше)
            else if(stepMin == Periods.DAY)
            {
                isMultiplier = curData.dateChangeType != .none;
            }
                //Шаг больше дня - смена недели/месяца/года или дни кратны шагу
            else
            {
                //произошла смена недели/месяца/года
                if(curData.dateChangeType != .none && curData.dateChangeType != .day)
                {
                    isMultiplier = true;
                }
                    //
                else if(currentPeriod >= Periods.MONTH)
                {
                    isMultiplier = curData.month % (stepMin / Periods.MONTH) == 0;
                }
                    //Период больше либо равен дневке - смотрим чтобы был кратен
                else if(currentPeriod >= Periods.DAY)
                {
                    isMultiplier = curData.day % (stepMin / Periods.DAY) == 0;
                }
                    //Период меньше дневки - смотрим кратный день, плюс чтобы был флаг смены дня
                else
                {
                    isMultiplier = curData.day % (stepMin / Periods.DAY) == 0 && curData.dateChangeType == .day;
                }
            }
            
            if(stepMin >= Periods.DAY && curData.dateChangeType == .none)
            {
                curData.dateChangeType = .day;
            }
            //
            if(isMultiplier)
            {
                var text = "";
                var curFont = self.settings.scaleFont;
                var activeList = allItems[0];
                
                //Видимость переходов может быть выключена, рисуем предыдущий переход в таком случае
               
                
                switch curData.dateChangeType
                {
                case .none:
                    if(currentPeriod < Periods.TIC || (currentPeriod > 0 && currentPeriod % Periods.SECOND == 0))
                    {
                        text = dt.mediumTimeString()
                    }
                    else if(currentPeriod == Periods.TIC || currentPeriod == Periods.RANGE)
                    {
                        text = dt.mediumTimeWithMilliseconds()
                    }
                        //Все что дневка и выше - подписи даты
                    else if(currentPeriod >= Periods.DAY)
                    {
                        text = dt.shortDateString();
                    }
                    else
                    {
                        text = dt.shortTimeString();
                    }
                    activeList = allItems[0];
                    break;
                case .day:
                    text = dt.shortDateString();
                    curFont = self.settings.scaleFont;
                    activeList = allItems[1];
                    break;
                case .week:
                    text = dt.shortDateString();
                    curFont = self.settings.scaleFont;
                    activeList = allItems[2];
                    break;
                case .month:
                    if(self.settings.monthSeparatorVisability){
                        text = dt.stringDateWithFormat(format:"MMMM");
                    }else{
                        text = dt.shortDateString();
                    }
                    curFont = self.settings.scaleFont;
                    activeList = allItems[3];
                    break;
                case .year:
                    if(self.settings.yearSeparatorVisability){
                        text = dt.stringDateWithFormat(format:"yyyy");
                    }else{
                        text = dt.shortDateString();
                    }
                    curFont = self.settings.scaleFont;
                    activeList = allItems[4];
                    break;
                }
                
                var attribute = [NSAttributedStringKey : NSObject]();
                attribute[NSAttributedStringKey.font] = curFont;
                
                let attrString = NSAttributedString.init(string: text as String, attributes: attribute);
                let size = attrString.size();
                
                //
                let textWidth : Int = Int(round(size.width)) + TEXT_PADDING_ADDITIONAL;
                let rightBorder : Int = curData.dateChangeType == .none ? currentDrawingX + textWidth / 2 : currentDrawingX + textWidth + TEXT_PLATE_SIZE;
                activeList!.add(TerceraChartTimeScaleRendererItem(changeType: curData.dateChangeType, lBorder: currentDrawingX - textWidth / 2, rBorder: rightBorder, text: text, x: currentDrawingX));
            }
            curX -= Double(scX);
        }
        
        //Определение уровня шкалы, для которого будем использовать жирный шрифт
        var boldLevel : Int = 100;
        var filledLevelsCount : Int = 0;
        for k in stride(from: allItems.count - 1, through: 0, by: -1)
        {
            if(allItems[k]!.count > 0)
            {
                if(boldLevel == 100)
                {
                    boldLevel = k;
                }
                filledLevelsCount += 1;
            }
        }
        if(filledLevelsCount < 2)
        {
            boldLevel = 100;
        }
        let gridPath = CGMutablePath()
        let axisPath = CGMutablePath()
        //Рисование, на основе расчитанных данных
      
        for k in stride(from: allItems.count - 1, through: 0, by: -1)
        {
            let items = allItems[k]!;
            
            for i in 0..<items.count
            {
                let item = items[i] as! TerceraChartTimeScaleRendererItem;
                
                //черточка на шкале
               
                axisPath.move(to: CGPoint(x: item.x, y: rectangle.minY))
                axisPath.addLine(to: CGPoint(x: item.x, y: rectangle.minY + 3))
                
                //Сетка
                if(self.settings.scaleGridVisability)
                {
                    for j in 0..<windowsContainer.windows.count
                    {
                        let windowClientRectangle = windowsContainer.windows[j].clientRectangle;
                        gridPath.move(to: CGPoint(x: item.x, y: windowClientRectangle.minY))
                        gridPath.addLine(to: CGPoint(x: item.x, y: windowClientRectangle.maxY))
                    }
                }
                
                if(isCanBePlaced(item, pixelMap: &pixelMap))
                {
                    //Текст
                    var attribute = [NSAttributedStringKey : NSObject]();
                    attribute[NSAttributedStringKey.font] = k == boldLevel ? self.settings.scaleFont : self.settings.scaleFont;
                    attribute[NSAttributedStringKey.foregroundColor] = settings.scaleTextColor;
                    
                    let attrString = NSAttributedString.init(string: item.text, attributes: attribute);
                    
                    var textRect = CGRect();
                    let stringSize = attrString.size();
                    if(item.dataChangeType == .none)
                    {
                        textRect = CGRect(x: item.x - stringSize.width / 2, y: self.rectangle.minY + (self.rectangle.height - stringSize.height) / 2, width: stringSize.width, height: stringSize.height);
                    }
                    else
                    {
                        textRect = CGRect(x: item.x + CGFloat(TEXT_PLATE_SIZE / 2 + TEXT_PADDING_ADDITIONAL), y: self.rectangle.minY + (self.rectangle.height - stringSize.height) / 2, width: stringSize.width, height: stringSize.height);
                    }
                    
                    ctx.setShouldAntialias(true)
                    attrString.draw(in: textRect)
//                    ctx.drawString(attributedString: attrString, rectangle: textRect)
                    
                    //Draw separators
                    var separatorPen : Pen?;
                    var separatorText = "";
                    
                    switch item.dataChangeType
                    {
                    case .day:
                        if(self.settings.daySeparatorVisability)
                        {
                            separatorPen = self.settings.daySeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Day", comment: "")
                        }
                    case .week:
                        if(self.settings.weekSeparatorVisability)
                        {
                            separatorPen = self.settings.weekSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Week", comment: "")
                        }else if(self.settings.daySeparatorVisability)
                        {
                            separatorPen = self.settings.daySeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Day", comment: "")
                        }
                    case .month:
                        if(self.settings.monthSeparatorVisability)
                        {
                            separatorPen = self.settings.monthSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Month", comment: "")
                        }else if(self.settings.weekSeparatorVisability)
                        {
                            separatorPen = self.settings.weekSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Week", comment: "")
                        }else if(self.settings.daySeparatorVisability)
                        {
                            separatorPen = self.settings.daySeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Day", comment: "")
                        }
                    case .year:
                        if(self.settings.yearSeparatorVisability)
                        {
                            separatorPen = self.settings.yearSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Year", comment: "")
                        }else if(self.settings.monthSeparatorVisability)
                        {
                            separatorPen = self.settings.monthSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Month", comment: "")
                        }else if(self.settings.weekSeparatorVisability)
                        {
                            separatorPen = self.settings.weekSeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Week", comment: "")
                        }else if(self.settings.daySeparatorVisability)
                        {
                            separatorPen = self.settings.daySeparatorPen
                            separatorText = NSLocalizedString("TerceraChartCashItemChangeType.Day", comment: "")
                        }
                    default:
                        break;
                    }
                    
                    if(separatorPen != nil)
                    {
                        //Протянуть по всем окнам
                        for j in 0..<windowsContainer.windows.count
                        {
                            let windowClientRectangle = windowsContainer.windows[j].clientRectangle;
                            
                            ctx.setPen(separatorPen!)
                            
                            ctx.move(to: CGPoint(x: item.x, y: CGFloat(windowClientRectangle.minY)));
                            ctx.addLine(to: CGPoint(x: item.x, y: CGFloat(window!.clientRectangle.maxY)));
                            ctx.strokePath();
                        }
                        
                        var attribute = [NSAttributedStringKey : NSObject]();
                        attribute[NSAttributedStringKey.font] = self.settings.scaleFont;
                        attribute[NSAttributedStringKey.foregroundColor] = settings.textSeparatorColor;
                        
                        let attrString = NSAttributedString.init(string: separatorText, attributes: attribute);
                        let textSize = attrString.size();
                        
                        let rect = CGRect(x: item.x - CGFloat(TEXT_PLATE_SIZE) / 2, y: self.rectangle.minY + 1, width: CGFloat(TEXT_PLATE_SIZE), height: self.rectangle.height - 2);
                        
                        ctx.setFillColor(separatorPen!.color);
                        ctx.fill(rect);
                        
                        let textRect = CGRect(x: rect.origin.x + (rect.width - textSize.width) / 2 + 1, y: rect.origin.y + (rect.height - textSize.height) / 2 + 1, width: textSize.width, height: textSize.height).integral
                        ctx.setShouldAntialias(true)
                        attrString.draw(in: textRect)
//                        ctx.drawString(attributedString: attrString, rectangle:textRect);
                    }
                }
            }
        }
        
        ctx.setPen(self.settings.scaleGridPen)
        ctx.addPath(gridPath)
        ctx.setShouldAntialias(false)
        ctx.strokePath();
        
        ctx.setPen(self.settings.scaleAxisPen)
        ctx.addPath(axisPath)
        ctx.strokePath();
        
        
        //restore state
        ctx.restoreGState();
    }
    
    func getPreferredHeight() -> CGFloat
    {
        
        var attribute = [NSAttributedStringKey : NSObject]();
        attribute[NSAttributedStringKey.font] = self.settings.scaleFont;
        
        var attrString = NSAttributedString.init(string: " ", attributes: attribute);
        var maxH = attrString.size().height + 1 ;
        
        attribute[NSAttributedStringKey.font] = self.settings.scaleFont;
        
        attrString = NSAttributedString.init(string: " ", attributes: attribute);
        let curH = attrString.size().height + 1;
        if(maxH < curH)
        {
            maxH = curH;
        }
        
        if (maxH < 18)
        {
            maxH = 18
        }
        
        return maxH ;
    }
    
    func isCanBePlaced(_ item : TerceraChartTimeScaleRendererItem, pixelMap : inout [Bool]) -> Bool
    {
        if(item.leftBorder > pixelMap.count - 1)
        {
            return false;
        }
        
        //Check
        if(item.leftBorder < 0)
        {
            item.leftBorder = 0;
        }
        if(item.rightBorder < 0)
        {
            item.rightBorder = 0;
        }
        if(item.rightBorder > pixelMap.count - 1)
        {
            item.rightBorder = pixelMap.count - 1;
        }
        
        
        //Check free place - light
        if(pixelMap[item.leftBorder] || pixelMap[item.rightBorder])
        {
            return false;
        }
        
        if (item.rightBorder - 1) > (item.leftBorder + 1)
        {
            //Check free place - full
            for i in (item.leftBorder + 1)..<(item.rightBorder - 1)
            {
                if(pixelMap[i])
                {
                    return false;
                }
            }
        }
        if (item.rightBorder > item.leftBorder)
        {
            //Store place
            for i in item.leftBorder..<item.rightBorder
            {
                pixelMap[i] = true;
            }
        }
        
        return true;
    }
}

class TerceraChartTimeScaleRendererItem: NSObject
{
    var dataChangeType : TerceraChartCashItemSeriesCacheScreenDataDateChangeType = .none;
    var leftBorder : Int = 0;
    var rightBorder : Int = 0;
    var text : String
    var x : CGFloat = 0;
    
    init(changeType : TerceraChartCashItemSeriesCacheScreenDataDateChangeType, lBorder : Int, rBorder : Int, text : String, x : Int)
    {
        self.dataChangeType = changeType;
        self.leftBorder = lBorder;
        self.rightBorder = rBorder;
        self.text = text;
        self.x = CGFloat(x);
    }
}
