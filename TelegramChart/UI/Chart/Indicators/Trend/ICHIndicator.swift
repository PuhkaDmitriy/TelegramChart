//
//  ICHIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 27/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class ICHIndicator: BaseIndicator {
    
    var tenkanPeriod:Int = 9
    {
        didSet
        {
            getDataSource()?.tenkanPeriod = tenkanPeriod
        }
    }
    var kijunPeriod:Int  = 26
    {
        didSet
        {
            getDataSource()?.kijunPeriod = kijunPeriod
        }
    }
    var senkouSpanBPeriod:Int = 52
    {
        didSet
        {
            getDataSource()?.senkouSpanBPeriod = senkouSpanBPeriod
        }
    }
    
    func getDataSource() ->IndICHDataSource?
    {
        return dataSource as? IndICHDataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.ICH"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.ICH"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.trend
    }
    
    override func setupDataSource(cashItem:CashItem)
    {
        super.setupDataSource(cashItem: cashItem)
        dataSource = IndICHDataSource(cashItem: cashItem, tenkanPeriod: tenkanPeriod, kijunPeriod: kijunPeriod, senkouSpanBPeriod: senkouSpanBPeriod)
    }
    
    override func preInit() {
        showPeriodProperty = false
        isBackground = true
        tenkanPeriod = 9
        kijunPeriod = 26
        senkouSpanBPeriod = 52
        periodMinValue = 1

        let tenkanPen = Pen(color: Colors.instance.chart_indicator_line_color_5.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorLine(dataSourceIndex: IndICHDataSource.tenkanDataKey, name: NSLocalizedString("property.indicator.conversionLine", comment: ""), pen: tenkanPen)

        let kijunPen = Pen(color: Colors.instance.chart_indicator_line_color_6.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorLine(dataSourceIndex: IndICHDataSource.kijunDataKey, name: NSLocalizedString("property.indicator.baseLine", comment: ""), pen: kijunPen)
      

        let chinkouSpanPen = Pen(color: Colors.instance.chart_indicator_line_color_7.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorLine(dataSourceIndex: IndICHDataSource.chinkouSpanDataKey, name: NSLocalizedString("property.indicator.laggingSpan", comment: ""), pen: chinkouSpanPen)
        indicarorLines.last?.timeShift = -kijunPeriod
        
        let upperPen = Pen(color: Colors.instance.chart_indicator_line_color_1.cgColor, lineWidth: 1, dashStyle: .solid)
        let lowerPen = Pen(color: Colors.instance.chart_indicator_line_color_2.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorInterLine(type:.cloud,dataSourceUpperIndex: IndICHDataSource.senokuSpanADataKey, dataSourceLowerIndex: IndICHDataSource.senokuSpanBDataKey, name: NSLocalizedString("property.indicator.cloud", comment: ""), upperPen: upperPen, lowerPen: lowerPen, background1: Colors.instance.chart_indicator_background_2.cgColor, background2: Colors.instance.chart_indicator_background_1.cgColor)
        indicatorInterLines.last?.timeShift = kijunPeriod
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
            return "ICH"
        }
        return "ICH(\(tenkanPeriod),\(kijunPeriod),\(senkouSpanBPeriod))"
    }
    
    override func getProperties() -> Array<DynProperty>
    {
        var properties = super.getProperties()
//        let tenkanPeriodDynProperty = IntDynProperty(value: tenkanPeriod, localizabeStringKey: "property.indicator.tenkan_period", groupID: .parameters, subGroupId: .view,minValue:periodMinValue, maxValue:periodMaxValue, сlosure: { [weak self] (value) in
//            self?.tenkanPeriod = value
//        })
//        properties.append(tenkanPeriodDynProperty)
//        
//        let kijunPeriodDynProperty = IntDynProperty(value: kijunPeriod, localizabeStringKey: "property.indicator.kijun_period", groupID: .parameters, subGroupId: .view,minValue:periodMinValue, maxValue:periodMaxValue, сlosure: { [weak self] (value) in
//            self?.kijunPeriod = value
//        })
//        properties.append(kijunPeriodDynProperty)
//        
//        let senkokuSpanBPeriodDynProperty = IntDynProperty(value: senkouSpanBPeriod, localizabeStringKey: "property.indicator.senkouSpanB_period", groupID: .parameters, subGroupId: .view,minValue:periodMinValue, maxValue:periodMaxValue, сlosure: { [weak self] (value) in
//            self?.senkouSpanBPeriod = value
//        })
//        properties.append(senkokuSpanBPeriodDynProperty)
        
        return properties
    }


}
