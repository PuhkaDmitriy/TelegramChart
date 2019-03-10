//
//  Enum.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/10/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

public enum EPriceType : Int
{
    // цена открытия
    case open
    
    // цена закрытия
    case close
    
    // максимальная цена
    case high
    
    // минимальная цена
    case low
    
    // средняя цена
    case median
    
    // (hight + low + close) / 3
    case typical
    
    // средневзвешенная цена
    case weight
    
    public func toString() -> String
    {
        switch self {
        case .close:
            return NSLocalizedString("indicators.properties.close", comment: "Close")
        case .open:
            return NSLocalizedString("indicators.properties.open", comment: "Open")
        case .high:
            return NSLocalizedString("indicators.properties.high", comment: "High")
        case .low:
            return NSLocalizedString("indicators.properties.low", comment: "Low")
        case .typical:
            return NSLocalizedString("indicators.properties.typical", comment: "Typical")
        case .median:
            return NSLocalizedString("indicators.properties.median", comment: "Median")
        case .weight:
            return NSLocalizedString("indicators.properties.weighted", comment: "Weight")
        }
    }
    
    public func tooltip() -> String
    {
        switch self {
        case .close:
            return NSLocalizedString("indicators.properties.close", comment: "")
        case .open:
            return NSLocalizedString("indicators.properties.open", comment: "")
        case .high:
            return NSLocalizedString("indicators.properties.high", comment: "")
        case .low:
            return NSLocalizedString("indicators.properties.low", comment: "")
        case .typical:
            return NSLocalizedString("property.indicator.typical.descr", comment: "")
        case .median:
            return NSLocalizedString("property.indicator.median.descr", comment: "")
        case .weight:
            return NSLocalizedString("property.indicator.weighted.descr", comment: "")
        }
    }
    
    public static func values() -> [EPriceType]
    {
        return [.close, .open, .high, .low, .typical, .median, .weight]
    }
}
