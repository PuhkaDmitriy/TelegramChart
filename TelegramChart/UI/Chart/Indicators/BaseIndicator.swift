//
//  BaseIndicator.swift
//  Protrader 3
//
//  Created by Yuriy on 23/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import Foundation
import ProFinanceApi


class BaseIndicator :NSObject, IProperty, NSCoding{
    
    var dataSource:IndDataSource?
    var linesCount = 0
    var separatedWindow = false
    var onlyDefaultLine = true
    var isBackground = false
    var roundToInstrumentTickSize = true
    var precision = 5
    var periodMinValue = 1
    var periodMaxValue = 1000
    var showPeriodProperty = true
    
    var period:Int = 1
    {
        didSet
        {
            dataSource?.period = period
        }
    }
    
    var indicarorLines = [IndicatorLine]()
    var indicatorInterLines = [IndicatorInterLine]()
    
    
    weak var chart:ProChart?
    
    deinit {
        dataSource?.removeFromCashItem()
    }
    
    class var nameKey:String
    {
        return ""
    }
    
    class var descriptionKey:String
    {
        return ""
    }
    
    class var type:EIndicatorType
    {
        return EIndicatorType.channels
    }
    
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(linesCount, forKey: "linesCount")
        aCoder.encode(onlyDefaultLine, forKey: "onlyDefaultLine")
        aCoder.encode(indicarorLines, forKey: "indicatorLines")
        aCoder.encode(indicatorInterLines, forKey: "indicatorInterLines")
        
        for line in indicarorLines
        {
            line.indicator = self
        }
        
        let propertyObject = PropertyObject()
        PropertyManager.sharedManager.uploadProperties(properties: self.getProperties(), toPropertyObject: propertyObject)
        aCoder.encode(propertyObject, forKey: CoderKeys.properties)
        
    }
    
    public func preInit(){/* for override*/ }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init()
        
        linesCount = aDecoder.decodeInteger(forKey: "linesCount")
        onlyDefaultLine = aDecoder.decodeBool(forKey: "onlyDefaultLine")
        let indObj = aDecoder.decodeObject(forKey: "indicatorLines")
        if indObj != nil
        {
            indicarorLines = indObj as! [IndicatorLine]
        }
        
        let indInterLineObj = aDecoder.decodeObject(forKey: "indicatorInterLines")
        if indInterLineObj != nil
        {
            indicatorInterLines = indInterLineObj as! [IndicatorInterLine]
        }
        
        let userPropertyObject = aDecoder.decodeObject(forKey: CoderKeys.properties) as! PropertyObject?
        
        self.loadProperties(propertyObject: userPropertyObject)
        
    }
    
    override init() {
        super.init()
        
        preInit()
        loadProperties(propertyObject: nil)
    }
    
    func loadProperties(propertyObject:PropertyObject?)
    {
        PropertyManager.sharedManager.loadPropertiesForObject(self, userPropertyObject: propertyObject)
    }
    
    func getIndicatorShortName() -> String
    {
        //For override
        return ""
    }
    
    func setupDataSource(cashItem:CashItem)
    {
        if (dataSource != nil)
        {
            cashItem.removeIndicator(indicator: dataSource!)
        }
    }
    
    func setIndicatorLine(dataSourceIndex:Int,sideSourceIndex: Int? = nil , name:String, pen:Pen)
    {
        let indicatorLine = IndicatorLine(indicator: self,dataSourceIndex:dataSourceIndex,sideSourceIndex:sideSourceIndex, name: name, pen: pen)
        indicarorLines.append(indicatorLine)
    }
    
    func setIndicatorInterLine(type:EInterLineType,dataSourceUpperIndex:Int, dataSourceLowerIndex:Int, name:String, upperPen:Pen, lowerPen:Pen, background1:CGColor,background2:CGColor)
    {
        let indicatorInterLine = IndicatorInterLine(type:type, indicator: self, dataSourceUpperIndex: dataSourceUpperIndex, dataSourceLowerIndex: dataSourceLowerIndex, name: name, upperPen:upperPen, lowerPen:lowerPen,background1:background1, background2:background2)
        indicatorInterLines.append(indicatorInterLine)
    }
    
    func closePropertyWindow()
    {
        
        self.dataSource?.build()
        
        self.chart?.redrawBuffer()
    }
    
    func getPropertiesTitle() -> String
    {
        let baseType = Swift.type(of: self)
        return NSLocalizedString(baseType.nameKey, comment: "")
    }
    
    
    func getProperties() -> Array<DynProperty>
    {
        var properties = [DynProperty]()
//        properties.append(BoolDynProperty(value: isBackground, localizabeStringKey: "property.indicator.isBackground", groupID: .parameters, subGroupId:.view, сlosure: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//            strongSelf.isBackground = value
//            strongSelf.chart?.redrawBuffer()
//        }))
//
//        if showPeriodProperty
//        {
//            let periodDynProperty = IntDynProperty(value: period, localizabeStringKey: "property.indicator.period", groupID: .parameters, subGroupId: .view,minValue:periodMinValue, maxValue:periodMaxValue, сlosure: { [weak self] (value) in
//                self?.period = value
//            })
//            properties.append(periodDynProperty)
//        }
//
//        for line in indicarorLines
//        {
//            properties += line.getProperties()
//        }
//
//        for line in indicatorInterLines
//        {
//            properties += line.getProperties()
//        }
        return properties
    }
    
    
    
}
