//
//  SimpleChartSeries.swift
//  Protrader 3
//
//  Created by Yuriy on 27/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import Foundation
import ProFinanceApi


class SimpleChartSeries
{
    var dataHolder:[Double]?
    var points = [CGPoint]()
    var historyHolders:[QuoteHolder]?
    var chart:SimpleChart
    var from:Int64 = -1
    var to:Int64 = -1
    var minPrice:Double = Double.greatestFiniteMagnitude
    var maxPrice:Double = -Double.greatestFiniteMagnitude
    var paddingY:CGFloat = 10
    
    var chartHeight:CGFloat = 0
    
    init(chart:SimpleChart) {
        self.chart = chart
        changeLayout()
    }
    
    func changeLayout()
    {
        chartHeight = chart.tableRenderer!.chartRect.height  - paddingY * 2
        if historyHolders != nil
        {
            recalculateData()
        }
    }
    
    func getTimeByCoordinate(xCoordinate:CGFloat) -> Int64?
    {
        if from == -1 || to == -1
        {
            return nil
        }
        return from + Int64(CGFloat(to - from) * xCoordinate / self.chart.frame.width)
    }
    
    func getPriceByXCoordinate(xCoordinate:CGFloat) -> Double?  {
        if dataHolder == nil
        {
            return nil
        }
        let coordinate = Int(xCoordinate)
        guard let res = dataHolder?[coordinate] else {return nil}
        if res.isNaN
        {
            var leftPrice = Double.nan
            var leftOffset = 1
            while (true)
            {
                let position = coordinate - leftOffset
                if position < 0
                {
                    break
                }
                else
                {
                    guard let currentValue = dataHolder?[position] else {break}
                    if !currentValue.isNaN
                    {
                        leftPrice = currentValue
                        break
                    }
                }
                leftOffset += 1
            }
            
            var rightPrice = Double.nan
            var rightOffset = 1
            while (true)
            {
                let position = coordinate + rightOffset
                if position >= dataHolder!.count
                {
                    break
                }
                else
                {
                    guard let currentValue = dataHolder?[position] else {break}
                    if !currentValue.isNaN
                    {
                        rightPrice = currentValue
                        break
                    }
                }
                rightOffset += 1
            }
            if rightPrice.isNaN || leftPrice.isNaN
            {
                return nil
            }
            else
            {
                let res = (rightPrice * Double(leftOffset) + leftPrice * Double(rightOffset)) / Double(rightOffset + leftOffset)
                
                return res
            }
            
        }
        else
        {
            return res
        }
    }
    
    func getYForPrice(price:Double) -> CGFloat
    {
        if price == minPrice
        {
            return chart.tableRenderer!.chartRect.maxY - paddingY
        }
        else if price == maxPrice
        {
            return chart.tableRenderer!.chartRect.minY + paddingY
        }
      
        return (chartHeight - CGFloat(price - minPrice) * chartHeight / CGFloat(maxPrice - minPrice)) + chart.tableRenderer!.chartRect.minY + paddingY
    }
    
    
    func recalculateData()
    {
        guard let historyHolders = historyHolders else {
            dataHolder = nil
            return
        }
        if Int(self.chart.frame.width) <= 0
        {
            dataHolder = nil
            return
        }
        minPrice = Double.greatestFiniteMagnitude
        maxPrice = -Double.greatestFiniteMagnitude
        dataHolder = Array.init(repeating: Double.nan, count: Int(self.chart.frame.width))
        points = [CGPoint]()
       
        let count = Int64(dataHolder!.count)
        var priceSum:Double = 0
        var priceCount:Double = 0
        var lastPrice:Double = 0
        var lastPosition = 0
        let period = (to - from) / count
        
        for historyHolder in historyHolders
        {
            let infoTemp = historyHolder.info ?? historyHolder.askInfo
            guard let info = infoTemp else {continue}
            let currentPosition = Int((info.leftTimeTicks - from) / period)
            
            if lastPosition != currentPosition
            {
                if priceSum > 0
                {
                    lastPrice = priceSum / priceCount
                    minPrice = min(lastPrice, minPrice)
                    maxPrice = max(lastPrice, maxPrice)
                    dataHolder![lastPosition] = lastPrice
                    
                }
                lastPosition = currentPosition
                priceCount = 0
                priceSum = 0
            }
            if !info.close.isNaN && info.close > 0
            {
                priceCount += 1
                priceSum += info.close
            }
        }
        
        
        if lastPrice != 0
        {
            dataHolder![dataHolder!.count - 1] = lastPrice
        }
        
        var position:CGFloat = 0
        for price in dataHolder!
        {
            if !price.isNaN
            {
                points.append(CGPoint(x: position, y: getYForPrice(price: price)))
            }
            position += 1
        }
    }
}
