import Foundation

enum EInterLineType:Int
{
    case cloud
    case simple
}

class IndicatorInterLine:NSObject, IProperty, NSCoding
{
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(dataSourceLowerIndex, forKey: "dataSourceLowerIndex")
        aCoder.encode(dataSourceUpperIndex, forKey: "dataSourceUpperIndex")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(type.rawValue, forKey:"type")
        
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        dataSourceLowerIndex = aDecoder.decodeInteger(forKey: "dataSourceLowerIndex")
        dataSourceUpperIndex = aDecoder.decodeInteger(forKey: "dataSourceUpperIndex")
        name = aDecoder.decodeObject(forKey: "name") as! String
        type = EInterLineType(rawValue: aDecoder.decodeInteger(forKey: "type"))!
    }
    
    
    init(type:EInterLineType, indicator:BaseIndicator, dataSourceUpperIndex:Int, dataSourceLowerIndex:Int, name:String, upperPen:Pen, lowerPen:Pen,background1:CGColor,background2:CGColor ) {
        self.type = type
        self.indicator = indicator
        self.name = name
        self.dataSourceUpperIndex = dataSourceUpperIndex
        self.dataSourceLowerIndex = dataSourceLowerIndex
        self.upperPen = upperPen
        self.lowerPen = lowerPen
        self.background1 = background1
        self.background2 = background2
    }
    
    var type:EInterLineType = EInterLineType.simple
    var dataSourceLowerIndex:Int
    var dataSourceUpperIndex:Int
    var name = ""
    var upperPen = Pen(color: UIColor.white.cgColor)
    var lowerPen = Pen(color: UIColor.white.cgColor)
    var background1:CGColor = UIColor.blue.cgColor
    var background2:CGColor = UIColor.blue.cgColor
    var timeShift  = 0
    var visible = true
    var showLineMarker = true
    weak var indicator:BaseIndicator?
    
    
    func getProperties() -> Array<DynProperty> {
        return []
//        let groupDynProperty = GroupDynProperty(key: "line_property_\(self.dataSourceLowerIndex)", label: name, groupID: .properties)
//
//        let visibilityDynProperty = BoolDynProperty(value: visible, localizabeStringKey: "property.indicator.visible", groupID: .properties, subGroupId:.view, сlosure: { [weak self] (value) in
//            guard let strongSelf = self else { return }
//            strongSelf.visible = value
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(visibilityDynProperty)
//
//        let upperLineDynProperty = LineStyleDynProperty(pen: upperPen, localizabeStringKey: "property.indicator.upperLineStyle", localizabeDescriptionKey: "property.indicator.upperLineStyle", groupID: .properties, subGroupId: .view, сlosure: { [weak self] (pen) in
//            guard let strongSelf = self else { return }
//            strongSelf.upperPen = pen
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(upperLineDynProperty)
//
//        let lowerLineDynProperty = LineStyleDynProperty(pen: lowerPen, localizabeStringKey: "property.indicator.lowerLineStyle", localizabeDescriptionKey: "property.indicator.lowerLineStyle", groupID: .properties, subGroupId: .view, сlosure: { [weak self] (pen) in
//            guard let strongSelf = self else { return }
//            strongSelf.lowerPen = pen
//            strongSelf.indicator?.chart?.redrawBuffer()
//        })
//        groupDynProperty.properties.append(lowerLineDynProperty)
//
//        let backgrolundLocalization = (type == .cloud) ? "property.indicator.background1" : "property.indicator.background"
//        let backgroundProperty = ColorDynProperty(value: NSColor(cgColor: background1), localizabeStringKey: backgrolundLocalization, localizabeDescriptionKey: "", groupID: .appearance, subGroupId: .view, сlosure: { [weak self] (color) in
//            guard let strongSelf = self else { return }
//            if color != nil
//            {
//                strongSelf.background1 = color!.cgColor
//                if strongSelf.type != .cloud
//                {
//                    strongSelf.background2 = color!.cgColor
//                }
//                strongSelf.indicator?.chart?.redrawBuffer()
//            }
//        })
//        groupDynProperty.properties.append(backgroundProperty)
//
//        if (type == .cloud)
//        {
//            let backgroundProperty2 = ColorDynProperty(value: NSColor(cgColor: background2), localizabeStringKey: "property.indicator.background2", localizabeDescriptionKey: "", groupID: .appearance, subGroupId: .view, сlosure: { [weak self](color) in
//                guard let strongSelf = self else { return }
//                if color != nil
//                {
//                    strongSelf.background2 = color!.cgColor
//                    strongSelf.indicator?.chart?.redrawBuffer()
//                }
//            })
//            groupDynProperty.properties.append(backgroundProperty2)
//        }
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
//
//        groupDynProperty.properties.append(showLineMarkerDynProperty)
//
//        return [groupDynProperty]
    }
}

