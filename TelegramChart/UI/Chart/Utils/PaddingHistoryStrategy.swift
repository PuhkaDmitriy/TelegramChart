//
//  PaddingHistoryStrategy.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

enum LoadingHistoryMode
{
    case finish
    case partial
}

enum StartingReason
{
    case dragging
    case emptySpace
    case current
}

enum LoadingHistoryByDraggingRequestContextType:Int {
    case normal
    case weekend
}

class PaddingHistoryStrategy: Any
{
    var desireAmount:Int = 0
    
    weak var chart:ProChart?
    
    var barsToLoad:Int = 0
    
    let maxAttemptCount:Int = 4
    
    var attemptCount = 0;
    
    var lastCashItemCount = -1
    
    var enable:Bool = false
    {
        didSet
        {
            DispatchQueue.main.async {[weak self] in
                if self?.enable == true {
                    if self!.chart!.hasCorrectData
                    {
                        self?.updateLoaderImagePosition()
                        self?.nsProgressIndicator.isHidden = false
                        self?.nsProgressIndicator.startAnimating()
                    }
                }
                else
                {
                    self?.nsProgressIndicator.isHidden = true
                    self?.nsProgressIndicator.stopAnimating()
                }
            }
        }
    }
    
    var lastMouseDownLeftPadding:Int = 0
    
    var startingReason:StartingReason = .dragging
    
    var wasDragging = false
    
    var nsProgressIndicator:UIActivityIndicatorView!
    
    var availableDragging = true
    
    init(chart:ProChart) {
        self.chart = chart
        nsProgressIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        nsProgressIndicator.color = UIColor.white
        chart.addSubview(nsProgressIndicator)
        nsProgressIndicator.isHidden = true
    }
    
    //    func stopThread()
    //    {
    //        chart?.loadingQueue.cancelAllOperations()
    //
    //    }
    
    func updateLoaderImagePosition()
    {
        let x = chart?.mainWindow?.clientRectangle.minX ?? 0
        let y = chart?.mainWindow?.clientRectangle.midY ?? 0
        
        nsProgressIndicator.frame = CGRect(x: x + 10, y: y, width: 20, height: 20)
    }
    
    func checkResults(_ cashItemSeries : TerceraChartCashItemSeries) -> LoadingHistoryMode
    {
        
        let currentBarsAmount = cashItemSeries.count - chart!.barsToRight_Bars
        
        //Получили необходимое количество баров = догрузка завершена
        if currentBarsAmount >= desireAmount && Int(chart!.mainWindow!.im) <= cashItemSeries.count
        {
            attemptCount = 0
            lastCashItemCount = -1
            stopLoading()
            return LoadingHistoryMode.finish
        }
            // Похоже на конец истории - прекращаем загрузку
        else if attemptCount >= maxAttemptCount
        {
            cashItemSeries.reachStartOftheHistory = true
            stopLoading()
            return LoadingHistoryMode.finish
        }
            // Баров еще не хватает
        else
        {
            //            if chart!.mainCashItemSeries == nil
            //            {
            //                stopLoading()
            //                return LoadingHistoryMode.finish
            //            }
            
            //Добавим дырку, на количество недостающих баров
            var noEnough = desireAmount - currentBarsAmount
            let emptySpaceCount = Int(chart!.mainWindow!.im) - cashItemSeries.count
            noEnough = max(emptySpaceCount, noEnough)
            cashItemSeries.paddingLeft(noEnough)
            
            //Move left border again
            var reqTime:Int64 = 0
            if chart!.mainCashItemSeries != nil
            {
                reqTime =  chart!.mainCashItemSeries!.leftRelativeBorderIgnorePadding - chart!.mainCashItemSeries!.leftRelativeBorder
            }
            var contextType = LoadingHistoryByDraggingRequestContextType.normal
            if maxAttemptCount == attemptCount
            {
                contextType = LoadingHistoryByDraggingRequestContextType.weekend
            }
            let historyFrom = chart!.historyFrom - getRequiredLoadingTime(tfInfo: chart!.timeFrameInfo!, desireRange: reqTime, contextType: contextType)
            chart!.historyFrom =  historyFrom
            if lastCashItemCount == cashItemSeries.count
            {
                attemptCount += 1;
            }
            lastCashItemCount = cashItemSeries.count
            
            // На текущий момент причина запуска догрузки неактульна
            if startingReason == .emptySpace && !emptySpaceCondition
            {
                cashItemSeries.paddingLeft(0);
                
                //
                stopLoading();
                
                return LoadingHistoryMode.finish;
            }
                
            else
            {
                return LoadingHistoryMode.partial;
            }
        }
    }
    
    func processMouseDown()
    {
        wasDragging = false;
        if chart?.mainCashItemSeries != nil
        {
            lastMouseDownLeftPadding = Int(chart!.mainCashItemSeries!.paddingBarsCount);
        }
    }
    
    func processMouseUp()
    {
        if !wasDragging
        {
            return
        }
        
        desireAmount = chart!.mainCashItemSeries!.count - chart!.barsToRight_Bars
        
        if !enable
        {
            if chart?.mainCashItemSeries != nil && !chart!.emptyContentView.isLoading
            {
                startLoading(context: .normal, startingReason: .dragging)
            }
        }
        wasDragging = false
    }
    
    func refresh()
    {
        self.stopLoading()
        attemptCount = 0
    }
    
    func stopLoading()
    {
        enable = false
        lastCashItemCount = -1
        desireAmount = 0
    }
    
    var emptySpaceCondition:Bool
    {
        get
        {
            return chart?.mainCashItemSeries != nil && Int64(chart!.mainCashItemSeries!.count) - chart!.mainCashItemSeries!.paddingBarsCount < Int64(chart!.mainWindow!.im) && chart!.mainCashItemSeries!.count > 0 && !chart!.emptyContentView.isLoading && !chart!.mainCashItemSeries!.reachStartOftheHistory;
        }
    }
    
    func endOfScrolling()
    {
        if !wasDragging
        {
            return
        }
        
        desireAmount = chart!.mainCashItemSeries!.count - chart!.barsToRight_Bars
        
        if !enable
        {
            if chart?.mainCashItemSeries != nil && !chart!.emptyContentView.isLoading
            {
                startLoading(context: .normal, startingReason: .dragging)
            }
        }
        wasDragging = false
    }
   
//    func processScrollWheel(e: TerceraChartMouseEvent) {
//
//        if (e.baseEvent.phase == NSEvent.Phase.ended || e.baseEvent.momentumPhase == NSEvent.Phase.ended)
//        {
//
//            if !wasDragging
//            {
//                return
//            }
//
//            desireAmount = chart!.mainCashItemSeries!.count - chart!.barsToRight_Bars
//
//            if !enable
//            {
//                if chart?.mainCashItemSeries != nil && !chart!.loadingNow
//                {
//                    startLoading(context: .normal, startingReason: .dragging)
//                }
//            }
//            wasDragging = false
//
//
//        }
//    }
    
    func processResize()
    {
        updateLoaderImagePosition()
        if chart?.mainCashItemSeries == nil || !chart!.hasCorrectData || chart!.emptyContentView.isLoading || attemptCount >= maxAttemptCount || chart!.suspendRefreshChart
        {
            return
        }
        let necessaryCount = Int(chart!.mainWindow!.im) - chart!.mainCashItemSeries!.count
        
        if necessaryCount > 0  && enable == false
        {
            desireAmount = necessaryCount
            startLoading(context: .normal, startingReason: .emptySpace)
        }
    }
    
    func processDraggingLeft(newI1:Double)
    {
        if chart?.mainCashItemSeries == nil || !chart!.hasCorrectData || attemptCount >= maxAttemptCount || chart!.suspendRefreshChart || !availableDragging
        {
            return
        }
        
        //Насколько подвинули?
        let needToLoadBars = Int((chart!.mainWindow!.im - newI1).rounded())
        
        // Следим чтобы в итоге за экран не выходило
        var newPaddingValue:Int = needToLoadBars + lastMouseDownLeftPadding;
        newPaddingValue = min(newPaddingValue, Int(chart!.mainWindow!.im / 2))
        
        // Наполнили дырку
        (chart?.mainCashItemSeries)?.paddingLeft(newPaddingValue);
        
        wasDragging = true;
        
    }
    
    func startLoading(context:LoadingHistoryByDraggingRequestContextType, startingReason:StartingReason)  {
        
        if !availableDragging {return}
        
        if startingReason != .current
        {
            self.startingReason = startingReason
        }
        self.loadingHistory(context: context)
    }
    
    func loadingHistory(context:LoadingHistoryByDraggingRequestContextType){
        
        enable = true
        
        guard let historyParams = chart?.getHistoryParams() else {enable = false; return}
        
        // Update left border for history range
        guard let cashItem = chart!.mainCashItemSeries!.cashItem else {
            stopLoading();
            return
            
        }
        let desireRange = chart!.mainCashItemSeries!.leftRelativeBorderIgnorePadding - chart!.mainCashItemSeries!.leftRelativeBorder
        let requiredLoadingTime = getRequiredLoadingTime(tfInfo: chart!.timeFrameInfo!, desireRange: desireRange, contextType: context)
        
        let toTime = cashItem.nonEmptyCashArray.count > 0 ? cashItem.lastRequestedFromTime : Date().msecondsTimeStamp()
        
        historyParams.fromTime = toTime - requiredLoadingTime
        historyParams.toTime = toTime
        
        chart?.cashItem?.reload(historyParams)
        
        chart?.historyFrom = historyParams.fromTime
    }
    
    
    static let minute:Int64 = 60 * 1000
    static let hour:Int64 = minute * 60
    static let day:Int64 = hour * 24
    
    func getRequiredLoadingTime(tfInfo:TimeFrameInfo, desireRange:Int64, contextType:LoadingHistoryByDraggingRequestContextType) -> Int64
    {
        if !availableDragging {
            return 0
        }
        
        var desireRange = desireRange
        var result = PaddingHistoryStrategy.day
        let basePeriod = tfInfo.getBasePeriod()
        
        switch basePeriod {
        case .tick:
            result = PaddingHistoryStrategy.hour
        case .day:
            result = PaddingHistoryStrategy.day * 365
        default:
            if contextType == .normal
            {
                result = PaddingHistoryStrategy.day
            }
            else
            {
                result = PaddingHistoryStrategy.day * 3
            }
        }
        
        // Закачиваем с запасом
        desireRange = desireRange * 2
        
        // Закачиваем не меньше рекомендуемого минимума
        if result < desireRange
        {
            result = desireRange
        }
        return result
    }
}

