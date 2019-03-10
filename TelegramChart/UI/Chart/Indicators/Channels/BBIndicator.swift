//
//  BollingerBandsIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class BBIndicator: BaseIndicator {
    
    var deviation:NSDecimalNumber = NSDecimalNumber.decimalNum(from: 2)
    {
        didSet
        {
            self.getDataSource()?.deviation = deviation.doubleValue
        }
    }

    var movingAverageType:EMovingAverageType = EMovingAverageType.simple
    {
        didSet
        {
            self.getDataSource()?.movingAverageType = movingAverageType
        }
    }
    
    func getDataSource() ->IndBBDataSource?
    {
        return dataSource as? IndBBDataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.BB"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.BB"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.channels
    }
    
    var priceType:EPriceType = .close
    {
        didSet
        {
            self.getDataSource()?.priceType = priceType
        }
    }
    
    override func setupDataSource(cashItem:CashItem)
    {
        super.setupDataSource(cashItem: cashItem)
        dataSource = IndBBDataSource(cashItem: cashItem, period: period, priceType: priceType,movingAverageType:movingAverageType, deviation:deviation.doubleValue)
    }
    
    override func preInit() {
        isBackground = true
        period = 20
        periodMinValue = 1
        let pen = Pen(color: Colors.instance.chart_indicator_line_color_2.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorLine(dataSourceIndex: IndBBDataSource.centerDataKey, name: NSLocalizedString("property.indicator.averageLine", comment: ""), pen: pen)
        
        let upperPen = Pen(color: Colors.instance.chart_indicator_line_color_1.cgColor, lineWidth: 1, dashStyle: .solid)
        let lowerPen = Pen(color: Colors.instance.chart_indicator_line_color_1.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorInterLine(type:.simple,dataSourceUpperIndex: IndBBDataSource.upperDataKey, dataSourceLowerIndex: IndBBDataSource.lowerDataKey, name: NSLocalizedString("property.indicator.bollingerBands", comment: ""), upperPen: upperPen, lowerPen: lowerPen, background1: Colors.instance.chart_indicator_background_1.cgColor, background2: Colors.instance.chart_indicator_background_1.cgColor)
    }
    
    override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    public override func encode(with aCoder: NSCoder)
    {
        super.encode(with: aCoder)
        
    }
    
    override func getIndicatorShortName() -> String
    {
        if dataSource == nil
        {
            return "BB"
        }
        return "BB(\(period), \(deviation))"
    }
    
    
    override func getProperties() -> Array<DynProperty>
    {
        var dynProperties = super.getProperties()
        
//        var dataSourceValues = [IntPopUpItem]()
//        for dataType in EPriceType.values()
//        {
//            dataSourceValues.append(IntPopUpItem(value: dataType.rawValue, localizationKey: dataType.toString()))
//        }
//        
//        let property = IntPopUpDynProperty(value: priceType.rawValue, localizabeStringKey: "property.HistoryType", intItems: dataSourceValues, groupID: .parameters, subGroupId: .view, сlosure: { [weak self] (value) in
//            self?.priceType = EPriceType(rawValue: value)!
//        })
//        
//        dynProperties.append(property)
//        
//        var averageTypeValues = [IntPopUpItem]()
//        for movingAverage in EMovingAverageType.values()
//        {
//            averageTypeValues.append(IntPopUpItem(value: movingAverage.rawValue, localizationKey: movingAverage.toString()))
//        }
//        
//        let movAverageProperty = IntPopUpDynProperty(value: movingAverageType.rawValue, localizabeStringKey: "property.indicator.movingAverageType", intItems: averageTypeValues, groupID: .parameters, subGroupId: .view, сlosure: { [weak self] (value) in
//            self?.movingAverageType = EMovingAverageType(rawValue:value)!
//        })
//        
//        dynProperties.append(movAverageProperty)
//        
//        let deviationProperty = DecimalNumberDynProperty(value: deviation, localizabeStringKey: "property.indicator.deviation", groupID: .parameters, subGroupId: .view, minValue: NSDecimalNumber.zero, maxValue: NSDecimalNumber.oneHundred(), step: NSDecimalNumber.one) { [weak self] (value) in
//            self?.deviation = value
//        }
//        dynProperties.append(deviationProperty)
//        
        return dynProperties
    }
}
