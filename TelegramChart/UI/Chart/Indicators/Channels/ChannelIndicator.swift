//
//  ChannelIndicator.swift
//  ProtraderMac
//
//  Created by Yuriy on 06/01/2017.
//  Copyright © 2017 PFSOFT. All rights reserved.
//

import Foundation
import ProFinanceApi

class ChannelIndicator: BaseIndicator {
    
    func getDataSource() ->IndPriceChannelDataSource?
    {
        return dataSource as? IndPriceChannelDataSource
    }

    override class var nameKey:String
    {
        return "indicators.name.Channel"
    }
    
    override class var descriptionKey:String
    {
        return "indicators.description.Channel"
    }
    
    override class var type:EIndicatorType
    {
        return EIndicatorType.channels
    }
    
    override func setupDataSource(cashItem:CashItem)
    {
        super.setupDataSource(cashItem: cashItem)
        dataSource = IndPriceChannelDataSource(cashItem: cashItem, period: period)
    }
    
    override func preInit() {
        isBackground = true
        period = 10
        periodMinValue = 1
        
        let upperPen = Pen(color: Colors.instance.chart_indicator_line_color_1.cgColor, lineWidth: 1, dashStyle: .solid)
        let lowerPen = Pen(color: Colors.instance.chart_indicator_line_color_1.cgColor, lineWidth: 1, dashStyle: .solid)
        setIndicatorInterLine(type:.simple, dataSourceUpperIndex: IndPriceChannelDataSource.upperDataKey, dataSourceLowerIndex: IndPriceChannelDataSource.lowerDataKey, name: NSLocalizedString("property.indicator.priceChannel", comment: ""), upperPen: upperPen, lowerPen: lowerPen, background1: Colors.instance.chart_indicator_background_1.cgColor, background2:Colors.instance.chart_indicator_background_1.cgColor )
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
            return "Channel"
        }
        return "Channel(\(period))"
    }
    
}
