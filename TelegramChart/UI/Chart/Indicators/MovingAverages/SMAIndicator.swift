//
//  SMAIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class SMAIndicator: BaseIndicator {
    
    func getDataSource() ->IndSMADataSource?
    {
        return dataSource as? IndSMADataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.SMA"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.SMA"
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
        dataSource = IndSMADataSource(cashItem: cashItem, period: period, priceType: priceType)
    }
    
    override func preInit() {
        period = 200
        let pen = Pen(color: Colors.instance.chart_indicator_line_color_2.cgColor, lineWidth: 1, dashStyle: .solid)
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
            return "SMA"
        }
        return "SMA(\(dataSource!.period))"
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
        return dynProperties
    }
    
    
}
