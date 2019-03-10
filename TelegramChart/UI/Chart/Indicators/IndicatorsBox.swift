//
//  IndicatorsBox.swift
//  Protrader 3
//
//  Created by Yuriy on 23/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import Foundation

public enum EIndicatorType {
    case channels
    case movingAvarages
    case oscilators
    case trend
    case volatility
    case volume
    
    public static func values() -> [EIndicatorType]
    {
        return [.channels, .movingAvarages, .oscilators, .trend, .volatility, .volume]
    }
    
    
    public func toString() -> String
    {
        switch (self)
        {
        case .channels:
            return NSLocalizedString("indicators.type.channels", comment: "")
        case .movingAvarages:
            return NSLocalizedString("indicators.type.moving averages", comment: "")
        case .oscilators:
            return NSLocalizedString("indicators.type.oscillators", comment: "")
        case .trend:
            return NSLocalizedString("indicators.type.trend", comment: "")
        case .volatility:
            return NSLocalizedString("indicators.type.volatility", comment: "")
        case .volume:
            return NSLocalizedString("indicators.type.volume", comment: "")
        }
    }
}



class IndicatorsBox {
    
    static var instance:IndicatorsBox = IndicatorsBox()
    
    private init() {}
    
    
    func availableKeys() -> [String]
    {
        return [BBIndicator.nameKey, ChannelIndicator.nameKey, SMAIndicator.nameKey, MMAIndicator.nameKey, LWMAIndicator.nameKey, EMAIndicator.nameKey,SMMAIndicator.nameKey,ICHIndicator.nameKey,SARIndicator.nameKey]
    }
    
    func availableIndicators() -> [BaseIndicator]
    {
        var availableIndicators = [BaseIndicator]()
        for key in availableKeys()
        {
            let indicator = IndicatorsBox.indicatorByKey(key: key)
            if indicator != nil
            {
                availableIndicators.append(indicator!)
            }
        }
        return availableIndicators
    }
    
    static func indicatorByKey(key:String) -> BaseIndicator?
    {
        switch key {
        case BBIndicator.nameKey:
            return BBIndicator()
        case ChannelIndicator.nameKey:
            return ChannelIndicator()
        case SMAIndicator.nameKey:
            return SMAIndicator()
        case MMAIndicator.nameKey:
            return MMAIndicator()
        case LWMAIndicator.nameKey:
            return LWMAIndicator()
        case EMAIndicator.nameKey:
            return EMAIndicator()
        case MACDIndicator.nameKey:
            return MACDIndicator()
        case CCIIndicator.nameKey:
            return CCIIndicator()
        case SMMAIndicator.nameKey:
            return SMMAIndicator()
        case ICHIndicator.nameKey:
            return ICHIndicator()
        case SARIndicator.nameKey:
            return SARIndicator()
        default:
            return nil
        }
    }
}

