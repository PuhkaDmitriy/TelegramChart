//
//  IndicatorLine.swift
//  Protrader 3
//
//  Created by Yuriy on 23/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import Foundation

class IndicatorLine :NSObject, IProperty, NSCoding
{
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(dataSourceIndex, forKey: "dataSourceIndex")
        if sideSourceIndex != nil
        {
            aCoder.encode(sideSourceIndex!, forKey: "sideSourceIndex")
        }
        aCoder.encode(name, forKey: "name")
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        dataSourceIndex = aDecoder.decodeInteger(forKey: "dataSourceIndex")
        if aDecoder.containsValue(forKey: "sideSourceIndex")
        {
            sideSourceIndex = aDecoder.decodeInteger(forKey: "sideSourceIndex")
        }
        name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    
    init(indicator:BaseIndicator, dataSourceIndex:Int,sideSourceIndex:Int? = nil, name:String, pen:Pen) {
        self.indicator = indicator
        self.name = name
        self.pen = pen
        self.dataSourceIndex = dataSourceIndex
        self.sideSourceIndex = sideSourceIndex
    }
    
    var dataSourceIndex = 0
    var sideSourceIndex:Int? // индекс для массива, указывающего сторону и прерывания линии
    var name = ""
    var pen:Pen = Pen()
    var timeShift  = 0
    var visible = true
    var showLineMarker = true
    weak var indicator:BaseIndicator?
    
    
    func getProperties() -> Array<DynProperty> {
        return []
//        let groupDynProperty = GroupDynProperty(key: "line_property_\(self.dataSourceIndex)", label: name, groupID: .properties)
//
//        let visibilityDynProperty = BoolDynProperty(value: visible, localizabeStringKey: "property.indicator.visible", groupID: .properties, subGroupId:.view, сlosure: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//            strongSelf.visible = value
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(visibilityDynProperty)
//
//        let lineDynProperty = LineStyleDynProperty(pen: pen, localizabeStringKey: "property.indicator.lineStyle", localizabeDescriptionKey: "property.indicator.lineStyle", groupID: .properties, subGroupId: .view, сlosure: { [weak self] (pen) in
//            guard let strongSelf = self else { return }
//            strongSelf.pen = pen
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(lineDynProperty)
//
//
//        let timeShiftDynProperty = IntDynProperty(value: timeShift, localizabeStringKey:  "property.indicator.timeShift", groupID: .parameters, subGroupId: .view, minValue:-1000, maxValue:1000, сlosure: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//            strongSelf.timeShift = value
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(timeShiftDynProperty)
//
//        let showLineMarkerDynProperty = BoolDynProperty(value: showLineMarker, localizabeStringKey: "property.indicator.showLineMarker", groupID: .properties, subGroupId:.view, сlosure: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//            strongSelf.showLineMarker = value
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(showLineMarkerDynProperty)
//
//        return [groupDynProperty]
    }
}
