//
//  ExpandableMenuView.swift
//  Protrader 3
//
//  Created by Yuriy on 17/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class ChartMenuItem:ExpandableObject {
    var title:String?
    var image:UIImage?
    var activeImage:UIImage?
    var closure:(()->Void)?
    
    init(title:String?, imageName:String,activeImageName:String, closure:(()->Void)?) {
        self.title = title
        self.image = UIImage(named:imageName)
        self.activeImage = UIImage(named:activeImageName)
        self.closure = closure
    }
}

enum ChartMenuType
{
    case mainMenu
    case drawingsMenu
    case chartStyleMenu
    case indicatorsMenu
}


class ChartMenuView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var table:ExpandableTableView
    var indicatorGroups = [IndicatorGroup]()
    

    weak var chart:ProChart?
    var chartMenuType:ChartMenuType
    {
        didSet
        {
            var items = [ExpandableObject]()
            switch chartMenuType {
            case .mainMenu:
            
                let drawingTypeImage = getImageNameByDrawingType(Settings.shared.chartStyle())
                items.append(ChartMenuItem(title: NSLocalizedString("chart.menu.chartStyle",comment: ""), imageName: drawingTypeImage.noActive, activeImageName: drawingTypeImage.active, closure: { [weak self] in
                    self?.chart?.showMenu(menuType: .chartStyleMenu)
                }))
                
                items.append(ChartMenuItem(title: NSLocalizedString("chart.menu.indicators",comment: ""), imageName: "indicators", activeImageName: "indicatorsActive", closure: {
                    DispatchQueue.main.async {
                        self.chart?.showMenu(menuType: .indicatorsMenu)
                    }
                }))
                
                items.append(ChartMenuItem(title: NSLocalizedString("chart.menu.drawings",comment: ""), imageName: "drawings", activeImageName: "drawingsActive", closure: {[weak self] in
                    DispatchQueue.main.async {
                        self?.chart?.showMenu(menuType: .drawingsMenu)
                    }
                }))
            
            case .drawingsMenu:
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.horizontal",comment: ""), imageName: "drawingsHorizontalLineBig", activeImageName: "drawingsHorizontalLineBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.vertical",comment: ""), imageName: "drawingsVerticalLineBig", activeImageName: "drawingsVerticalLineBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.Line",comment: ""), imageName: "drawingsLineBig", activeImageName: "drawingsLineBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.priceChannel",comment: ""), imageName: "drawingsPriceChannelBig", activeImageName: "drawingsPriceChannelBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.Triangle",comment: ""), imageName: "drawingsTriangleBig", activeImageName: "drawingsTriangleBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.Rectangle",comment: ""), imageName: "drawingsRectangleBig", activeImageName: "drawingsRectangleBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.Fibretr",comment: ""), imageName: "drawingsFibonacciRetracementBig", activeImageName: "drawingsFibonacciRetracementBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.FibFan",comment: ""), imageName: "drawingsFibonacciFansBig", activeImageName: "drawingsFibonacciFansBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.GannLine",comment: ""), imageName: "drawingsGannLineBig", activeImageName: "drawingsGannLineBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tools.GannFan",comment: ""), imageName: "drawingsGannFanBig", activeImageName: "drawingsGannFanBigActive", closure: { [weak self] in
                    self?.chart?.hideMenu()
                }))
            case .chartStyleMenu:
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tool.line",comment: ""), imageName: "line", activeImageName: "lineActive", closure: { [weak self] in
                    Settings.shared.setChartStyle(.line)
                    self?.chart?.redrawBuffer()
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tool.candle",comment: ""), imageName: "style", activeImageName: "styleActive", closure: { [weak self] in
                    Settings.shared.setChartStyle(.candle)
                    self?.chart?.redrawBuffer()
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tool.bar",comment: ""), imageName: "bar", activeImageName: "barActive", closure: { [weak self] in
                    Settings.shared.setChartStyle(.bar)
                    self?.chart?.redrawBuffer()
                    self?.chart?.hideMenu()
                }))
                items.append(ChartMenuItem(title: NSLocalizedString("chart.tool.area",comment: ""), imageName: "area", activeImageName: "areaActive", closure: { [weak self] in
                    Settings.shared.setChartStyle(.solid)
                    self?.chart?.redrawBuffer()
                    self?.chart?.hideMenu()
                }))
            case .indicatorsMenu:
                
                let activeIndicatorGroup = getActiveIndicatorsGroup()
                if activeIndicatorGroup.innerObjects.count > 0
                {
                    items.append(getActiveIndicatorsGroup())
                }
                for group in indicatorGroups
                {
                    items.append(group)
                }
            }
            table.objects = items
        }
    }
    
    func getActiveIndicatorsGroup() -> IndicatorGroup
    {
        let indicatorGroup = IndicatorGroup()
        indicatorGroup.isOpen = true
        if let indicators = chart?.getAllActiveIndicators()
        {
            for indicator in indicators
            {
                let indicatorObject = IndicatorObject(indicator: indicator, editClosure: {
                    
                    self.chart?.redrawBuffer()
                    self.chart?.hideMenu()
                }, closeClosure: {
                    self.chart?.removeIndicator(indicator: indicator)
                    self.chart?.redrawBuffer()
                    self.chart?.hideMenu()
                })
                indicatorObject.isActive = true
                indicatorGroup.innerObjects.append(indicatorObject)
            }
        }
        return indicatorGroup
    }
    
    func getImageNameByDrawingType(_ type:TerceraChartDrawingType) -> (noActive:String,active:String)
    {
        switch type {
        case .bar:
            return (noActive:"bar", active:"barActive")
        case .candle:
            return (noActive:"style", active:"styleActive")
        case .line:
            return (noActive:"line", active:"lineActive")
        case .solid:
            return (noActive:"area", active:"areaActive")
        
        default:
            return (noActive:"", active:"")
        }
    }
    
    func initIndicators()
    {
        var indicatorGroupByType = [EIndicatorType:IndicatorGroup]()
        let indicatorsBox = IndicatorsBox.instance
        for indicator in indicatorsBox.availableIndicators()
        {
            let baseType = type(of: indicator)
//            let name = NSLocalizedString(baseType.nameKey, comment: "")
//            let description = NSLocalizedString(baseType.descriptionKey, comment: "")
            let indicatorGroup = indicatorGroupByType[baseType.type] ?? IndicatorGroup(indicatorType: baseType.type)
            indicatorGroup.isOpen = true
            indicatorGroupByType[baseType.type] = indicatorGroup
            let indicatorObject = IndicatorObject(indicator:indicator, closure:{ [weak self] in
  
                self?.chart?.redrawBuffer()
                self?.chart?.hideMenu()
                self?.chart?.addIndicators(indicators: [indicator])
            })
            indicatorGroup.innerObjects.append(indicatorObject)
            
            indicatorGroups = indicatorGroupByType.values.sorted {$0.name > $1.name}
        }
    }
    
    init(frame: CGRect, chart:ProChart) {
        
        let tableFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        table = ExpandableTableView(frame: tableFrame, style: .plain)
        
        chartMenuType = .mainMenu
        super.init(frame: frame)
        self.initIndicators()
        table.separatorStyle = .none
        table.backgroundColor = Colors.instance.defaultViewBackground
        self.backgroundColor = Colors.instance.chart_menuBackgroundColor
        addSubview(table)
        table.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        table.delegate = self
        table.dataSource = self
        setShadow()
        
        self.chart = chart
        let nib = UINib.init(nibName:"ChartMenuCell" , bundle: nil)
        table.register(nib, forCellReuseIdentifier: identifier)
        
        let indicatorsGroupNib = UINib.init(nibName:"IndicatorGroupTableViewCell" , bundle: nil)
        table.register(indicatorsGroupNib, forCellReuseIdentifier: indicatorGroupIdentifier)
        
        let indicatorsNib = UINib.init(nibName:"IndicatorTableViewCell" , bundle: nil)
        table.register(indicatorsNib, forCellReuseIdentifier: indicatorIdentifier)
        
        let activeIndicatorsNib = UINib.init(nibName:"ActiveIndicatorViewCellTableViewCell" , bundle: nil)
        table.register(activeIndicatorsNib, forCellReuseIdentifier: activeIndicatorIdentifier)
    }
    
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculatePreferedWidth() -> CGFloat
    {
        var res:CGFloat = 100
        if chartMenuType == .indicatorsMenu
        {
            res =  350
        }
        else {
            var attributes = [NSAttributedStringKey : NSObject]();
            attributes[NSAttributedStringKey.font] = UIFont(name: "Avenir-Medium", size: 14)
            
            
            var maxWidth:CGFloat = 40
            for item in table.objects
            {
                if let item = item as? ChartMenuItem
                {
                    if let title = item.title
                    {
                        let attributedString = NSAttributedString(string: title, attributes: attributes)
                        if attributedString.size().width > maxWidth
                        {
                            maxWidth = attributedString.size().width
                        }
                    }
                }
            }
            res = 85 + maxWidth
        }
        return min(res, chart!.frame.width)
    }
    
    var heightForObjects:CGFloat = 40

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = table.getObject(indexPath: indexPath) as? ChartMenuItem
        {
            item.closure?()
        }
        if let _ = table.getObject(indexPath: indexPath) as? IndicatorGroup
        {
            if !table.expand(indexPath: indexPath){
                tableView.reloadData()
            }
        }
        if let item = table.getObject(indexPath: indexPath) as? IndicatorObject
        {
            item.closure?()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if chartMenuType == .indicatorsMenu
        {
            return 40
        }
        else
        {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.getCount()
    }
    
    
    
    let identifier = "chartMenuCell"
    let indicatorGroupIdentifier = "indicatorGroupIdentifier"
    let indicatorIdentifier = "indicatorIdentifier"
    let activeIndicatorIdentifier = "activeIndicatorIdentifier"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chartMenuType == .indicatorsMenu
        {
            let item = table.getObject(indexPath: indexPath)
            if let item = item as? IndicatorGroup
            {
                var cell = table.dequeueReusableCell(withIdentifier: indicatorGroupIdentifier) as? IndicatorGroupTableViewCell
                if cell == nil
                {
                    cell = IndicatorGroupTableViewCell(style: .default, reuseIdentifier: indicatorGroupIdentifier)
                }
                if item.isOpen
                {
                    cell?.arrow.image = UIImage(named:"rowDown")
                }
                else
                {
                    cell?.arrow.image = UIImage(named:"rowUp")
                }
                
                cell?.label.text = item.name.uppercased()
                return cell!
            }
            else if let item = item as? IndicatorObject
            {
                if item.isActive
                {
                    var cell = table.dequeueReusableCell(withIdentifier: activeIndicatorIdentifier) as? ActiveIndicatorViewCellTableViewCell
                    if cell == nil
                    {
                        cell = ActiveIndicatorViewCellTableViewCell(style: .default, reuseIdentifier: activeIndicatorIdentifier)
                    }
                    let baseType = type(of: item.indicator)
                    let name = NSLocalizedString(baseType.nameKey, comment: "")
                    let description = NSLocalizedString(baseType.descriptionKey, comment: "")
                    cell?.label.text = "\(name) (\(description))"
                    cell?.indicatorObject = item
                    cell?.editButton.imageView?.image = UIImage(named:"fill24")
                    cell?.closeButton.imageView?.image = UIImage(named:"closeIndicator")
               
                    return cell!
                }
                else
                {
                    var cell = table.dequeueReusableCell(withIdentifier: indicatorIdentifier) as? IndicatorTableViewCell
                    if cell == nil
                    {
                        cell = IndicatorTableViewCell(style: .default, reuseIdentifier: indicatorIdentifier)
                    }
                    let baseType = type(of: item.indicator)
                    let name = NSLocalizedString(baseType.nameKey, comment: "")
                    let description = NSLocalizedString(baseType.descriptionKey, comment: "")
                    cell?.label.text = "\(name) (\(description))"
                    cell?.plus.image = UIImage(named:"add")
                    return cell!
                }
            }
            else
            {
                return UITableViewCell()
            }
        }
        else
        {
            var cell = table.dequeueReusableCell(withIdentifier: identifier) as? ChartMenuCell
            if cell == nil
            {
                cell = ChartMenuCell(style: .default, reuseIdentifier: identifier)
            }
            if let item = table.getObject(indexPath: indexPath) as? ChartMenuItem
            {
                cell?.cellImage.image = item.image
                cell?.cellImage.highlightedImage = item.activeImage
                
                if item.title != nil
                {
                    cell?.label?.text = item.title
                }
            }
            return cell!
        }
    }
    
    func setShadow() {
        let shadowPath: UIBezierPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false;
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset =  CGSize(width: -2, height: -4)
        layer.shadowOpacity = 0.3;
        layer.shadowPath = shadowPath.cgPath;
    }
}

