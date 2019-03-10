//
//  SMMAIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 25/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation

class SMMAIndicator: BaseIndicator {
    func getDataSource() ->IndSMMADataSource?
    {
        return dataSource as? IndSMMADataSource
    }
    
    override class var nameKey:String
    {
        return "indicators.name.SMMA"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.SMMA"
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
        dataSource = IndSMMADataSource(cashItem: cashItem, period: period, priceType: priceType)
    }
    
    override func preInit() {
        period = 9
        let pen = Pen(color: Colors.instance.chart_indicator_line_color_7.cgColor, lineWidth: 1, dashStyle: .solid)
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
            return "SMMA"
        }
        return "SMMA(\(dataSource!.period))"
    }
    
    
    override func getProperties() -> Array<DynProperty>
    {
        var dynProperties = super.getProperties()
        return dynProperties
    }

}
