//
//  SeriesDataConverter.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

import Darwin

open class TerceraChartSeriesDataConverter
{
    var basisValue:Double?
    
    func calculate(_ originalValue:Double) -> Double
    {
        return originalValue;
    }
    
    func revert(_ value:Double) ->Double
    {
        return value;
    }
    
    /// <summary>
    /// Преобразования между конверторами
    /// </summary>
    func convert(_ value:Double, converter1:TerceraChartSeriesDataConverter?, converter2:TerceraChartSeriesDataConverter?) -> Double
    {
        if converter1 === converter2
        {
            return value;
        }
        
        var valueInAbs = value;
        if (converter1 != nil)
        {
            valueInAbs = converter1!.revert(value);
        }
        
        if (converter2 != nil)
        {
            return converter2!.calculate(valueInAbs);
        }
        else
        {
            return valueInAbs;
        }
    }
}

class TerceraChartSeriesRelativeDataConverter : TerceraChartSeriesDataConverter
{
    override func calculate(_ originalValue:Double) -> Double
    {
        if (basisValue == 0)
        {
            return 100;
        }
        else
        {
            return (originalValue - basisValue!) / basisValue! * 100;
        }
    }
    
    override func revert(_ value:Double) -> Double
    {
        return (value * basisValue!) / 100 + basisValue!;
    }
}




open class TerceraChartSeriesLogDataConverter : TerceraChartSeriesDataConverter
{
    override func calculate(_ oValue:Double) -> Double
    {
        var originalValue = oValue
        // fix by Тополь
        if (originalValue == 0)
        {
            originalValue = 0.0000001;
        }
        
        return log(originalValue / basisValue!)
    }
    
    override func revert(_ value:Double) -> Double
    {
        return exp(value) * basisValue!;
    }
}

