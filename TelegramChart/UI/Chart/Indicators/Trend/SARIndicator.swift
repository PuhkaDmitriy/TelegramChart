//
//  SARIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 29/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class SARIndicator: BaseIndicator {
    var stepPeriod:NSDecimalNumber = NSDecimalNumber.decimalNum(from: 0.02)
    {
        didSet
        {
            getDataSource()?.stepPeriod = stepPeriod.doubleValue
        }
    }
    var maxStepPeriod: NSDecimalNumber = NSDecimalNumber.decimalNum(from: 0.2)
    {
        didSet
        {
            getDataSource()?.maxStepPeriod = maxStepPeriod.doubleValue
        }
    }
    
    func getDataSource() ->IndSARDataSource?
    {
        return dataSource as? IndSARDataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.SAR"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.SAR"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.trend
    }
    
    
    override func setupDataSource(cashItem:CashItem)
    {
        super.setupDataSource(cashItem: cashItem)
        dataSource = IndSARDataSource(cashItem: cashItem, stepPeriod: stepPeriod.doubleValue, maxStepPeriod: maxStepPeriod.doubleValue)
    }
    
    override func preInit() {
        showPeriodProperty = false
        let pen = Pen(color: Colors.instance.chart_indicator_line_color_2.cgColor, lineWidth: 2, dashStyle: .dot)
        setIndicatorLine(dataSourceIndex: IndSARDataSource.sarDataKey,sideSourceIndex: IndSARDataSource.loc2Key, name: NSLocalizedString("property.indicator.line", comment: ""), pen: pen)
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
        return "SAR(\(stepPeriod),\(maxStepPeriod))"
    }
    
    
    override func getProperties() -> Array<DynProperty>
    {
        var dynProperties = super.getProperties()
        
//        let stepPeriodProperty = DecimalNumberDynProperty(value: stepPeriod, localizabeStringKey: "property.indicator.stepPeriod", groupID: .parameters, subGroupId: .view, minValue: NSDecimalNumber.zero, maxValue: NSDecimalNumber.oneHundred(), step: NSDecimalNumber.decimalNum(from: 0.01)) { [weak self] (value) in
//            self?.stepPeriod = value
//        }
//        dynProperties.append(stepPeriodProperty)
//        
//        let maxStepPeriodProperty = DecimalNumberDynProperty(value: maxStepPeriod, localizabeStringKey: "property.indicator.maxStepPeriod", groupID: .parameters, subGroupId: .view, minValue: NSDecimalNumber.zero, maxValue: NSDecimalNumber.oneHundred(), step: NSDecimalNumber.decimalNum(from: 0.01)) { [weak self] (value) in
//            self?.maxStepPeriod = value
//        }
//        dynProperties.append(maxStepPeriodProperty)
        
        return dynProperties
    }

}
