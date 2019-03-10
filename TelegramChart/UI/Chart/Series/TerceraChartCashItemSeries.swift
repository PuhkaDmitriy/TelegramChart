//
//  CashItemSeries.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TerceraChartCashItemSeries: Any , BarChangeDelegate{
    
    weak var chart:ProChart?
    var reachStartOftheHistory = false
    var settings : TerceraChartCashItemSeriesSettings;
    
    var from : Int64;
    var to : Int64;
    
    var cashItem : CashItem?
    {
        get
        {
            return _cashItem;
        }
        set
        {
            if(self.cashItem != nil)
            {
                cashItem?.barsChangedDelegates.removeDelegate(self)
            }
            
            self._cashItem = newValue;
            
            if(cashItem != nil)
            {
                //subscribe
                cashItem?.barsChangedDelegates.addDelegate(self)
                
                self.relativePeriodBar = BaseInterval.getIntervalLength(cashItem!.period);
                self.barDuration = TerceraChartCashItemSeries.getBarDuration(cashItem!);
                self.nonLinearTimeLine = self.relativePeriodBar == 0 || (cashItem!.chartDataType != ChartDataType.default) || cashItem!.period % Periods.RANGE == 0;
                self.dayBasedData = !self.nonLinearTimeLine && cashItem!.period >= Periods.DAY && cashItem!.period % Periods.SECOND != 0;
                recalcIndices()
                
                
            }
            
            self.tickInOneBar = cashItem == nil || cashItem!.period == Periods.TIC ? 1 : Int64(cashItem!.period) * 60 * Int64(Periods.TICKS_PER_SECOND);
        }
    }
    fileprivate var _cashItem : CashItem?;
    
    var chartScreenData : TerceraChartCashItemSeriesCacheScreenDataStorage = TerceraChartCashItemSeriesCacheScreenDataStorage();
    
    var dataBlocks = [TerceraChartCashItemSeriesDataBlock]();
    var indexList = [Int]();
    var zeroTimes = [Double]();
    
    
    var nonLinearTimeLine : Bool = false;
    fileprivate var barDuration : Int64 = 1;
    var leftRelativeBorder : Int64 = 0;
    var rightRelativeBorder : Int64 = 0;
    var relativePeriodBar : Int64 = 1;
    
    var tickInOneBar : Int64 = 1;
    
    var isCustomRange : Bool = false;
    var dayBasedData : Bool = false;
    
    var disposed = false;
    var count: Int
    {
        get
        {
            return indexList.count;
        }
    }
    init(chart:ProChart?, newCashItem : CashItem, fromDate : Int64, toDate : Int64, seriesSetting : TerceraChartCashItemSeriesSettings, loadVolumeData : Bool = true, token : NSObject! = nil, forceReload : Bool = false)
    {
        self.chart = chart
        self.settings = seriesSetting;
        self.from = fromDate;
        self.to = toDate;
     
        
        //только после супер инит, а то сетер не отработает
        self.cashItem = newCashItem;
        
        //force loadData
        
    }
    
    func finalize()
    {
        self.disposed = true;
        //super.finalize()
    }
    
    func disableCashItemEvents()
    {
        if(self.cashItem != nil)
        {
        }
    }
    
    //Кэширование данных для указанного промежутка (обычно видимые на экране)
    func cacheScreenData(_ start : Int, end : Int, ins : SymbolInfo?)
    {
        let period = cashItem != nil ? cashItem!.period : Periods.MIN;
        
        let tempChartScreenData = TerceraChartCashItemSeriesCacheScreenDataStorage();
        
        var weekFlag = false;
        var yearFlag = false;
        var monthFlag = false;
        var lastTimeHolder = TimeHolder(Int64(self.getValue((start > 0 ? start - 1 : start), level: .timeIndex)))
        
        //Обновлят нужно до основного цикла, данные зависят от базового значения
        self.updateBasisValue(start, ins: ins);
        
        let from = max(0, start);
        var subItemStartIndex = self.profileFindInterval(from);
        
        let customInstrSessions = false;
      
        
        //InstrumentHistory
        
        for i in from...end
        {
            //Уже не актуально (фоновое рисование)
            if(self.disposed)
            {
                return
            }
            
            let cs = TerceraChartCashItemSeriesCacheScreenData(Int64(self.getValue(i, level: CashItemLevel.timeIndex)));
            
            // mark barstoright hole
            if(i < 0)
            {
                cs.hole = true;
            }
            
            //isMain session
            let biIndex = self.getIndex(i);
            
            //This case is allowed for MultiInstrument
            //continue
            
            if(biIndex == CashItem.PADDING_BAR)
            {
                continue;
            }
            
            // mark barstoright hole
            if(biIndex < 0)
            {
                cs.hole = true;
            }
            
            cs.baseIntervalIndex = biIndex;
            if(biIndex >= 0 && cashItem != nil)//&& не кэшитемфайл
            {
                let bbi = cashItem!.getInterval(biIndex);
                if(bbi != nil)
                {
                    if(customInstrSessions)
                    {
                        //unused                         let components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: bbi!.leftTime);
                        //unused                        let dayTime = Date(year: components.year!, month: components.month!, day: components.day!)
                    }
                    else
                    {
                        cs.isMainSession = TradeSessionPeriod.isMainType(bbi!.sessionType);
                    }
                    cs.separator = bbi!.separator;
                }
            }
            
            if(i < 0 || biIndex == -1)
            {
                cs.hole = true;
            }
            
            //add correct time for holes
            if(i < 0)
            {
                cs.time = self.leftRelativeBorder + Int64(i) * self.barDuration
            }
            else if(i >= self.indexList.count)
            {
                cs.time = rightRelativeBorder + Int64(i - self.indexList.count) * self.barDuration;
            }
            
            cs.open = getValue(i, level: CashItemLevel.openIndex);
            cs.close = getValue(i, level: CashItemLevel.closeIndex);
            cs.volume = getVolume(i);
            
            if period != Periods.TIC || cashItem?.chartDataType == .renko
            {
                cs.high = getValue(i, level: CashItemLevel.highIndex);
                cs.low = getValue(i, level: CashItemLevel.lowIndex);
            }else{
                cs.high =  cs.close
                cs.low =  cs.open
            }
            
            
            
            if(settings.clusterEnabled)
            {
                //self.getTickVolumeInfo(info, i);
                //self.getClusterData(ins, info, cs);
            }
            
            if(cashItem != nil && cashItem!.timeFrameInfo.tradeAnalysisType == TradeAnalysisType.marketProfile)
            {
                cs.profileData = self.getProfileData(cs, index: i, subProfileIndex: &subItemStartIndex, ins: ins, sett: settings);
            }
            
            let validData = cs.time > 0;
            
            
            //Control min/max
            var low = cs.low;
            var high = cs.high;
            if(period == Periods.TIC)
            {
                low = min(cs.open, cs.close);
                high = max(cs.open, cs.close);
            }
            
            
            if(!cs.hole && low < tempChartScreenData.minLow)
            {
                if(low != 0)
                {
                    tempChartScreenData.minLow = low;
                }
                else if(cashItem != nil && !cashItem!.loading && validData)// 0 принмаем, только если кэш итем в этот момент не грузится
                {
                    tempChartScreenData.minLow = low;
                }
            }
            
            if(!cs.hole && high > tempChartScreenData.maxHigh)
            {
                tempChartScreenData.maxHigh = high;
            }
            
            //Change day/month/year
            var daySeparate = cs.separator;
            let isRange = period % Periods.RANGE == 0;
            let isSeconds = period % Periods.SECOND == 0 || period < 0; // секунды или тиковая
            
            
            //сервер сейчас криво дает эту инфу, сами пока
            
            daySeparate = lastTimeHolder.day != cs.day;
            
            //Days separartor
            if(period <= Periods.HOUR4 || isRange || isSeconds)
            {
                //для 2 минуты присылает сервак признак, иначе определяем самостоятельно
                if(period != Periods.MIN)
                {
                    daySeparate = lastTimeHolder.day != cs.day;
                }
                
                if(daySeparate)
                {
                    cs.dateChangeType = .day;
                }
            }
            
            //Week separartor
            if(period < Periods.DAY || isRange || isSeconds)
            {
                let changeWeek = lastTimeHolder.weekOfYear != cs.weekOfYear;
                if(changeWeek)
                {
                    weekFlag = true;
                }
                
                //set flags
                if(weekFlag && daySeparate)
                {
                    weekFlag = false;
                    cs.dateChangeType = .week;
                }
            }
            
            //Month separator
            if(period < Periods.MONTH || isSeconds)
            {
                let changeMonth = lastTimeHolder.month != cs.month;
                if(changeMonth)
                {
                    monthFlag = true;
                }
                
                //set flags
                if(monthFlag && daySeparate)
                {
                    monthFlag = false;
                    cs.dateChangeType = .month;
                }
            }
            
            //year separator
            if(period < Periods.YEAR || isSeconds)
            {
                let changeYear = lastTimeHolder.year != cs.year;
                if(changeYear)
                {
                    yearFlag = true;
                }
                
                //set flags
                if(yearFlag)
                {
                    yearFlag = false;
                    cs.dateChangeType = .year;
                }
            }
            if cs.time > 0
            {
                lastTimeHolder = cs;
            }
            
            tempChartScreenData.storage.append(cs);
        }
        
        if(tempChartScreenData.minLow == Double.greatestFiniteMagnitude || tempChartScreenData.maxHigh == -Double.greatestFiniteMagnitude)
        {
            //некоректные данные, скорее всего в этот момент грузился кэшитем игнорим их
        }
        else
        {
            //Replace
            self.chartScreenData = tempChartScreenData;
        }
        
    }
    
    func getMaxZeroBars(_ cashItem : CashItem?) -> Int
    {
        if(cashItem == nil)
        {
            return 0;
        }
        
        let period = cashItem!.period;
        if(period > Periods.TIC)
        {
            if(period < Periods.DAY)
            {
                //Пустых баров не более 24 часов
                return 24 * Periods.HOUR / period;
            }
            else if(period < Periods.MONTH)
            {
                //день и неделя - макс длина дыры = 1 месяц
                return Periods.MONTH / period;
            }
            else
            {
                //для месяцев максимальная дыра = 1 год
                return 12;
            }
        }
        else
        {
            // для тик-интервальных и тиковых баров дырок не бывает
            return 0;
        }
    }
    
    func recalcIndices()
    {
        var bufferList = [Int]();
        var bufferZero = [Double]();
        bufferZero.append(0);
        var bufferBlocks = [TerceraChartCashItemSeriesDataBlock]();
        var leftBorder: Int64 = 0;
        var rightBorder: Int64 = 0;
        let maxBarsCount : Int = getMaxZeroBars(self.cashItem);
        
        let startTicks : Int64 = self.from
        let endTicks : Int64 = self.to;
        
        
        
        let bi : BaseInterval? = cashItem!.getInterval(0);
        let barLength = bi != nil ? bi!.rightTimeTicks - bi!.leftTimeTicks : 0;
        
        var curBlock : TerceraChartCashItemSeriesDataBlock? = nil;
        var addedIndex : Int = 0;
        
        
        //Учитываем фейковый отступ слева для подгрузки
        var leftFakeDataBlock : TerceraChartCashItemSeriesDataBlock? = nil;
        if(self.paddingBarsCount > 0)
        {
            leftFakeDataBlock = TerceraChartCashItemSeriesPaddingDataBlock()
            bufferBlocks.append(leftFakeDataBlock!);
            
            for _ in 0...self.paddingBarsCount
            {
                bufferList.append(CashItem.PADDING_BAR);
            }
            
            addedIndex += 1;
        }
        
        //Показывать дырки
        if !self.isCustomRange
        {
            if(self.settings.showEmptyBars)
            {
                let sessionOffset:Int64 = self.chart?.symbol?.getInstrument().tradeSession?.beginDayTimeGMTOffset() ?? 0
                var prevBi : BaseInterval? = nil;
                let array : BaseIntervalHolder = cashItem!.nonEmptyCashArray;
                let startIndex = array.binarySearchIndexByTime(startTicks)
                
                for i in startIndex...array.count
                {
                    let curBi : BaseInterval = array[i];
                    
                    //проверка временного диапазона
//                    if(curBi.leftTimeTicks >= endTicks)
//                    {
//                        break
//                    }
                    
                    //remember time borders
                    if(leftBorder == 0)
                    {
                        leftBorder = curBi.leftTimeTicks;
                    }
                    rightBorder = curBi.rightTimeTicks;
                    
                    //Дырка?
                    if(prevBi != nil && prevBi!.rightTimeTicks < curBi.leftTimeTicks)
                    {
                        let zeroes = prevBi!.calculateNextInterv(curBi.leftTimeTicks, sessionOffset: sessionOffset, period: self.cashItem!.period, instrumentCalendar:self.cashItem!.instrumentCalendar );
                        
                        //Слишком большие дырки не добавляем
                        let controlBigHole = true;
                        if(zeroes < maxBarsCount || !controlBigHole)
                        {
                            if(zeroes > 0)
                            {
                                curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex, time: curBi.leftTimeTicks);
                                bufferBlocks.append(curBlock!);
                                for j in 0...zeroes
                                {
                                    let zeroBarTime : Int64 = prevBi!.rightTimeTicks + Int64(j) * barLength;
                                    
                                    bufferZero.append(Double(zeroBarTime));
                                    bufferList.append((bufferZero.count - 1) * -1);
                                    addedIndex += 1;
                                }
                                curBlock = nil;
                            }
                            else if(self.dayBasedData)
                            {
                                //Create block for hole
                                curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex - 1, time: prevBi!.rightTimeTicks);
                                curBlock!.isHole = true;
                                bufferBlocks.append(curBlock!);
                                curBlock = nil;
                            }
                        }
                        else
                        {
                            //Create block for hole
                            curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex, time: prevBi!.rightTimeTicks);
                            curBlock!.isHole = true;
                            bufferBlocks.append(curBlock!);
                            curBlock = nil;
                        }
                    }
                        //В нахлест бары лежат - начинаем новый блок
                    else if(self.dayBasedData && prevBi != nil && prevBi!.rightTimeTicks > curBi.leftTimeTicks)
                    {
                        curBlock = nil;
                    }
                    
                    // Create new block for data
                    if(curBlock == nil)
                    {
                        curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex, time: curBi.leftTimeTicks);
                        bufferBlocks.append(curBlock!);
                    }
                    
                    bufferList.append(i);
                    addedIndex += 1;
                    prevBi = curBi;
                }
            }
                //Без дырок
            else
            {
                var prevBi : BaseInterval? = nil;
                let array = self.cashItem!.nonEmptyCashArray;
                let startIndex = array.binarySearchIndexByTime(startTicks)
                
                for i in startIndex..<array.count
                {
                    let curBi : BaseInterval = array[i];
                    
//                    //Проверка временного диапазона
//                    if(curBi.leftTimeTicks >= endTicks)
//                    {
//                        break
//                    }
                    
                    if(leftBorder == 0)
                    {
                        leftBorder = curBi.leftTimeTicks;
                    }
                    rightBorder = curBi.rightTimeTicks;
                    
                    //Дырка?
                    if(prevBi != nil && prevBi!.rightTimeTicks < curBi.leftTimeTicks && self.relativePeriodBar != 0)
                    {
                        //Create block for hole
                        curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex - 1, time: prevBi!.rightTimeTicks);
                        curBlock!.isHole = true;
                        bufferBlocks.append(curBlock!);
                        curBlock = nil;
                    }
                        // В нахлест бары лежат - начинаем новый блок
                    else if dayBasedData && prevBi != nil && prevBi!.rightTimeTicks > curBi.leftTimeTicks
                    {
                        curBlock = nil;
                    }
                    
                    //Create new block for data
                    if(curBlock == nil)
                    {
                        curBlock = TerceraChartCashItemSeriesDataBlock(index: addedIndex, time: curBi.leftTimeTicks);
                        bufferBlocks.append(curBlock!);
                    }
                    
                    bufferList.append(i);
                    addedIndex += 1;
                    prevBi = curBi;
                }
            }
        }
        //Учитываем фейковый блок - двигаем левую границу
        if(leftFakeDataBlock != nil)
        {
            let newLeftTime : Int64 = Int64(leftBorder - paddingTime);
            leftBorder = newLeftTime;
            bufferBlocks[0].leftTime = newLeftTime;
        }
        
        //Сначала во временной массив, иначе лажает на промежуточных этапах
        self.indexList = bufferList;
        self.zeroTimes = bufferZero;
        
        self.leftRelativeBorder = leftBorder;
        self.rightRelativeBorder = rightBorder;
        self.dataBlocks = bufferBlocks;
        
        // Выставляем положение скроллера
     
        chart?.setContentSize()
        self.chart?.setPositionOfScroll()
       
    }
    
    //Вычисление времени по указанному индексу (в т.ч. дробному)
    func findTimeExactly(_ barIndex : Double) -> Double
    {
        var mlt : Double = Double(self.barDuration);
        
        let count = Double((self.cashItem != nil && cashItem?.period == Periods.TIC) ? self.count - 1 : self.count);
        
        if(barIndex < 0)//Look into the past...
        {
            let delta : Double = Double(self.leftRelativeBorder) + barIndex * mlt;
            return delta;
        }
        else if(barIndex > count)//Look into the future...
        {
            let delta = barIndex - count;
            return delta * mlt + Double(self.rightRelativeBorder);
        }
        else// inside the cashItem
        {
            let ival = Int(barIndex);
            let openTime = getValue(ival, level: CashItemLevel.timeIndex);
            
            if(self.cashItem!.period == 0)//для тиков берем расстояние между барами
            {
                mlt = getValue(ival + 1, level: CashItemLevel.timeIndex) - openTime;
            }
            else if(self.nonLinearTimeLine)//для нелинейной шкалы длина бара = close - open
            {
                mlt = getValue(ival, level: CashItemLevel.timeCloseIndex) - openTime;
            }
            
            return openTime + (barIndex - Double(ival)) * mlt;
        }
    }
    
    //Вычисление индекса бар (в т.ч. дробного) для указанного времени
    func findIntervalExactly(_ time : Double) -> Double
    {
        //look into the past
        if(time < Double(self.leftRelativeBorder))
        {
            let e : Double = (time - Double(self.leftRelativeBorder)) / Double(self.barDuration);
            return e;
        }
        
        //look into the future
        if(time >= Double(self.rightRelativeBorder))
        {
            let count = (cashItem != nil && cashItem?.period == Periods.TIC) ? self.count - 1 : self.count;
            let e : Double = Double(count) + (time - Double(self.rightRelativeBorder)) / Double(self.barDuration);
            return e;
        }
        
        //Ticks
        if(cashItem!.period == 0)
        {
            let i : Int = findIntervalBinary(time);
            
            let curTime = getValue(i, level: CashItemLevel.timeIndex);
            let nextTime = getValue(i + 1, level: CashItemLevel.timeIndex);
            if(nextTime == curTime)
            {
                return Double(i);
            }
            let left = time - curTime;
            return Double(i) + left / (nextTime - curTime);
        }
        else if(self.nonLinearTimeLine)//Non linear
        {
            let i : Int = findIntervalBinary(time);
            
            let openBarTime = getValue(i, level: CashItemLevel.timeIndex);
            let closeBarTime = getValue(i, level: CashItemLevel.timeCloseIndex);
            let left = time - openBarTime;
            return Double(i) + left / (closeBarTime - openBarTime);
        }
        else //linear timeline
        {
            return findBlockBinary(time);
        }
    }
    
    //Поиск по блокам - оптимизировано для линейных шкал
    func findBlockBinary(_ time : Double) -> Double
    {
        if(self.dataBlocks.count == 0)
        {
            return 0
        }
        
        var from : Int = 0;
        var to : Int = self.dataBlocks.count - 1;
        
        //Бинарный поиск
        while((to - from) > 1)
        {
            let middle : Int = from + (to - from) / 2;
            let leftTime = (dataBlocks[middle]).leftTime;
            if(time >= Double(leftTime))
            {
                from = middle;
            }
            else
            {
                to = middle;
            }
        }
        
        //Берем блок
        var db : TerceraChartCashItemSeriesDataBlock? = nil;
        if(to == from)
        {
            db = (self.dataBlocks[to]);
        }
        else if((to - from) == 1)
        {
            let rightDb = self.dataBlocks[to];
            db = (Double(rightDb.leftTime) <= time) ? rightDb : self.dataBlocks[from];
        }
        
        if(db!.isHole)
        {
            return Double(db!.leftIndex);
        }
        else
        {
            return Double(db!.leftIndex) + (time - Double(db!.leftTime)) / Double(self.relativePeriodBar);
        }
    }
    
    //Поиск индекса бара по времени. Старый способ - бинарный поиск, используем для нелинейных шкал
    func findIntervalBinary(_ time : Double) -> Int
    {
        var from : Int = 0
        var to : Int = self.count - 1;
        var leftTime : Double = 0.0;
        var rightTime : Double = 0.0;
        
        //Бинарный поиск
        while((to - from) > 1)
        {
            let middle = from + (to - from) / 2;
            self.getTime(middle, lt: &leftTime, rt: &rightTime);
            if(time >= leftTime)
            {
                from = middle;
            }
            else
            {
                to = middle;
            }
        }
        
        //Анализ результата
        if((to - from) == 0)
        {
            self.getTime(from, lt: &leftTime, rt: &rightTime);
            
            if(time >= leftTime && time < rightTime)
            {
                return from;
            }
            else if(from > 0)
            {
                return from - 1;
            }
            else
            {
                return -1;
            }
        }
        else if((to - from) == 1)
        {
            self.getTime(from, lt: &leftTime, rt: &rightTime);
            
            var leftTime1 : Double = 0.0;
            var rightTime1 : Double = 0.0;
            
            self.getTime(to, lt: &leftTime1, rt: &rightTime1);
            
            if(time >= leftTime && time < rightTime)
            {
                return from;
            }
            else if(time >= leftTime1 && time < rightTime1)
            {
                return to;
            }
            else if(time > leftTime && time < leftTime1)//возможно между интервалами дырка, тогда предположим, что дырка - продолжение левого интервала
            {
                return from;
            }
            else if(cashItem != nil && to == (cashItem!.nonEmptyCashArray.count - 1))//Добавить проверку на период == тик
            {
                return to;
            }
            else if(time > rightTime)
            {
                return -1;
            }
            else if(from > 0)
            {
                return from - 1;
            }
            else
            {
                return Int((Double(time) - self.getValue(0, level: CashItemLevel.timeIndex)) / Double(self.tickInOneBar));
            }
        }
        
        return -1;
    }
    
    //Получить время границы
    func getTime(_ index : Int, lt: inout Double, rt : inout Double)
    {
        //получаем не расширенную длину истории
        let length : Int = self.indexList.count;
        
        //если это доступ ко времени, то вычисляем время бара в будующем
        if(index < 0)
        {
            lt = 0;
            rt = 0;
        }
        else if(index >= 0 && index < length)
        {
            let newIndex = self.getIndex(index);
            
            if(newIndex == CashItem.PADDING_BAR)
            {
                lt = Double(self.leftRelativeBorderIgnorePadding + (Int64(index) - self.paddingBarsCount) * self.barDuration);
                rt = lt + Double(self.barDuration);
            }
            else if(index < 0)
            {
                lt = self.zeroTimes[newIndex * -1];
                rt = lt + self.getTime(1);
            }
            else
            {
                lt = Double(cashItem!.getOpenTime(newIndex));
                rt = Double(cashItem!.getCloseTime(newIndex));
            }
            
        }
        else
        {
            let lastIndex : Int = self.getIndex(length - 1);
            lt = Double(cashItem!.getOpenTime(lastIndex)) + self.getTime(index - length + 1);
        }
    }
    
    
    //Получить реальный индекс в кеш итеме по индексу екстендера (Может быть отрицаельным - значит там дырка)
    func getIndex(_ index : Int, getIndexType : TerceraChartCashItemSeriesGetIndexType = TerceraChartCashItemSeriesGetIndexType.exactly) -> Int
    {
        if(getIndexType == TerceraChartCashItemSeriesGetIndexType.exactly)
        {
            return index >= 0 && index < self.indexList.count ? self.indexList[index]: -1;
        }
        else
        {
            //Incorrect case
            if(index < 0 || index >= self.indexList.count)
            {
                return -1;
            }
            
            var i = index;
            var res : Int = self.indexList[index];
            if(res < 0)
            {
                while(res < 0)
                {
                    i += 1;
                    if(i >= self.indexList.count)//не нашли в итоге
                    {
                        return -1;
                    }
                    res = self.indexList[i];
                }
            }
            return res;
        }
    }
    
    func getTime(_ count : Int) -> Double
    {
        let period = cashItem!.period;
        
        if(period < Periods.TIC)
        {
            return Double(count * (-period) * Periods.TICKS_PER_SECOND);
        }
        else if(period == Periods.TIC || period % Periods.SECOND == 0)
        {
            return Double(count * Periods.TICKS_PER_SECOND);
        }
        else
        {
            return Double(Int64(count) * Int64(period) * 60 * Int64(Periods.TICKS_PER_SECOND));
        }
    }
    
    func getValue(_ index: Int, level: CashItemLevel) -> Double
    {
        var res : Double = 0;
        if(cashItem == nil)
        {
            return res;
        }
        //Обращение ко времени - дополнительная логика
        //для дырок, прошлого и будущего
        if(level == .timeIndex || level == .timeCloseIndex)
        {
            let length = self.indexList.count;
            if(index < 0)
            {
                res = 0;
            }
            else if(index >= 0 && index < length)
            {
                let originalIndex = index
                var index = getIndex(index);
                
                if(index == CashItem.PADDING_BAR)
                {
                    if level == .timeIndex
                    {
                        return Double(leftRelativeBorderIgnorePadding + (Int64(originalIndex) - paddingBarsCount) * barDuration);
                    }
                    else
                    {
                        return Double(leftRelativeBorderIgnorePadding + (Int64(originalIndex) - paddingBarsCount) * barDuration);
                    }
                    
                }
                else if(index < 0)
                {
                    index = -1;
                    return index < zeroTimes.count ? zeroTimes[index] : 0;
                }
                else
                {
                    res = cashItem![index, level];
                }
            }
            else
            {
                let lastIndex = getIndex(length - 1);
                res = cashItem![lastIndex, level] + getTime(index - length + 1);
            }
        }
            //Обращение к ценам - находим соответсвующий индекс в кешитеме
        else
        {
            let index = getIndex(index);
            if(index < 0)
            {
                res = 0;
            }
            else
            {
                res = cashItem![index, level];
            }
        }
        
        return res;
    }
    
    func getVolume(_ index : Int) -> Double
    {
        if(!TerceraChartCashItemSeriesSettings.allowNewVolumeBars || !self.settings.useRealTicksData)
        {
            return self.getValue(index, level: CashItemLevel.volumeIndex);
        }
        
        let newIndex = getIndex(index);
        if(newIndex < 0)
        {
            return 0;
        }
        
        return self.getVolumeFromVolumeInfo(newIndex);
    }
    
    //To do
    func getVolumeFromVolumeInfo(_ index : Int) -> Double
    {
        if(self.cashItem == nil)
        {
            return 0;
        }
        
        let bi = cashItem!.getInterval(index);
        
        if(bi == nil || bi!.info == nil)
        {
            return 0;
        }
        
        guard let info = bi?.info else {return 0}
        switch settings.volumeMode {
        case .delta:
            return info.delta
        case .totalVolume:
            return info.totalVolume;
            
        case .buyVolume:
            return info.buysVolume;
            
        case .sellVolume:
            return info.sellsVolume;
            
        case .averageTotalSize:
            return info.averageTotalSize;
            
        case .averageBuySize:
            return info.averageBuysSize;
            
        case .averageSellSize:
            return info.averageSellsSize;
            
        case .customTotalVolumePercent:
            return info.customTotalVolume(amount: settings.customAmount);
            
        case .customBuyVolumePercent:
            return info.customBuysVolume(amount: settings.customAmount);
            
        case .customSellVolumePercent:
            return info.customSellsVolume(amount: settings.customAmount);
        default:
            return 0
        }
    }
    
    
    fileprivate func updateBasisValue(_ startIndex: Int, ins : SymbolInfo?)
    {
        //        var newBasisValue:Double = 0;
        //
        //        var indexOfBeginDataBar = indexList.count > 0 ? indexList[0] : -1;
        //
        //        switch (settings.BasisType)
        //        {
        //        case TerceraChartCashItemSeriesDataTypeBasisType.BeginOfScreen:
        //            if (startIndexBar >= 0)
        //            {
        //                startIndexBar = GetIndex(startIndexBar + 1, TerceraChartCashItemSeriesGetIndexType.ExactlyOrNearestNonEmpty);
        //                if (startIndexBar < 0)
        //                {
        //                    // ?
        //                }
        //                else
        //                newBasisValue = cashItem[startIndexBar, CashItem.OPEN_INDEX];
        //            }
        //            else if (indexOfBeginDataBar != -1)
        //            newBasisValue = cashItem[indexOfBeginDataBar, CashItem.OPEN_INDEX];
        //
        //            break;
        //        case TerceraChartCashItemSeriesDataTypeBasisType.BeginOfData:
        //            if (indexOfBeginDataBar != -1)
        //            newBasisValue = cashItem[indexOfBeginDataBar, CashItem.OPEN_INDEX];
        //            break;
        //        case TerceraChartCashItemSeriesDataTypeBasisType.BeginOfDay:
        //            if (ins != null)
        //            newBasisValue = Instrument.PrevCloseSpread(ins);
        //            break;
        //        }
        //
        //        settings.logDataConverter.BasisValue = settings.relativeDataConverter.BasisValue = newBasisValue;
    }
    
    //To do
    fileprivate func getProfileData(_ cs : TerceraChartCashItemSeriesCacheScreenData, index : Int, subProfileIndex : inout Int, ins : PFISymbol?, sett : TerceraChartCashItemSeriesSettings) -> TerceraChartCashItemSeriesCacheScreenData.ProfileData
    {
        return TerceraChartCashItemSeriesCacheScreenData.ProfileData();
    }
    
    //To do
    fileprivate func profileFindInterval(_ index : Int) -> Int
    {
        return 0;
    }
    
    fileprivate static func getBarDuration(_ cashItem : CashItem) -> Int64
    {
        //не влияет на движени тулзовин
        //влияет на шкалу времени и на получение времени, например, функциями рисования .net индикаторов
        let period = cashItem.period;
        
        //1 тик и N тиков - 1 секунда
        if(period <= Periods.TIC)
        {
            return Int64(Periods.TICKS_PER_SECOND);
        }
        
        //рейндж - 1 сек
        if(period % Periods.RANGE == 0)
        {
            return Int64(Periods.TICKS_PER_SECOND);
        }
        
        //ренко to do
        
        
        return BaseInterval.getIntervalLength(cashItem.period);
    }
    
    func getCopy() -> TerceraChartCashItemSeries
    {
        let copy = TerceraChartCashItemSeries(chart: self.chart, newCashItem: self.cashItem!, fromDate: self.from, toDate: self.to, seriesSetting: self.settings)
        return copy;
    }
    
    //MARK: Downloading history
    
    //Количество баров для докачки выраженное в тиках
    var paddingTime : Int64
    {
        get
        {
            return self.paddingBarsCount * self.barDuration
        }
    }
    var leftRelativeBorderIgnorePadding : Int64
    {
        get
        {
            var db : TerceraChartCashItemSeriesDataBlock?;
            if(self.paddingBarsCount > 0  && self.dataBlocks.count > 1)
            {
                db = self.dataBlocks[1];
            }
            
            if(db !=  nil)
            {
                return db!.leftTime;
            }
            else
            {
                return self.leftRelativeBorder;
            }
        }
    }
    
    func paddingLeft(_ count : Int, clearPrev : Bool = true)
    {
        self.paddingBarsCount = Int64(count);
        recalcIndices()
        
    }
    
    //Колличество добавленных баров
    var paddingBarsCount : Int64 = 0;
    
    
    private var lastUpdate = CFAbsoluteTime()
    
    private let minUpdateTime:Double = 0.3
    private var timerScheduled = false
    private var needRecalcIndices = false
    
    
    private func redrawInTimeout()
    {
        if timerScheduled == false
        {
            timerScheduled = true
            cashItem?.cashItemQueue.asyncAfter(deadline: .now() + .milliseconds(300) , execute: {[weak self] in
                self?.redrawBuffer()
                self?.timerScheduled = false
            })
        }
    }
    
    
    func redrawBufferWithTimeCheck()
    {
        if CFAbsoluteTime() - lastUpdate < minUpdateTime
        {
            redrawInTimeout()
        }
        else
        {
            redrawBuffer()
        }
    }
    
    func redrawBuffer()
    {
        if needRecalcIndices
        {
            recalcIndices()
            needRecalcIndices = false
        }
        DispatchQueue.main.async {
            self.chart?.redrawBuffer()
        }
    }
    
    
    func historyExpanded() {
        needRecalcIndices = true
        redrawBufferWithTimeCheck()
    }
    
    func historyRenewal() {
        redrawBufferWithTimeCheck()
    }
}


enum TerceraChartCashItemSeriesDataType
{
    case absolute
    case relative
    case log
}

enum TerceraChartCashItemSeriesDataTypeBasisType
{
    case beginOfScreen
    case beginOfData
    case beginOfDay
};

enum TerceraChartCashItemSeriesGetIndexType
{
    case exactly
    case exactlyOrNearestNonEmpty
}

