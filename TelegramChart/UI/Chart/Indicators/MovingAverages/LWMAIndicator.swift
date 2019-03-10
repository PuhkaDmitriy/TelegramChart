//
//  LVMAIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class LWMAIndicator: BaseIndicator {
   
    func getDataSource() ->IndLWMADataSource?
    {
        return dataSource as? IndLWMADataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.LWMA"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.LWMA"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.movingAvarages
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
        dataSource = IndLWMADataSource(cashItem: cashItem, period: period, priceType: priceType)
    }
    
    override func preInit() {
        period = 9
        periodMinValue = 2
        let pen = Pen(color: Colors.instance.chart_indicator_line_color_5.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorLine(dataSourceIndex: 0, name: NSLocalizedString("property.indicator.line", comment: ""), pen: pen)
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
            return "LWMA"
        }
        return "LWMA(\(dataSource!.period))"
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
        
        return dynProperties
    }
    

}
