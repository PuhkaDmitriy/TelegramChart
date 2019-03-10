//
//  AggregationTypeView.swift
//  Protrader 3
//
//  Created by Yuriy on 06/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit


protocol AggregationTypeViewDelegate:class {
    func didSelect(aggregationType:AggregationType)
}

class AggregationTypeView: UIScrollView {
    
    weak var aggregationTypeViewDelegate:AggregationTypeViewDelegate?
    let buttonWidth:CGFloat = 40
    let buttonHeight:CGFloat = 20
    var buttons = [UIButton]();
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    @objc func buttonAction(sender: UIButton)
    {
        sender.isSelected = true
        for button in buttons
        {
            if button !== sender
            {
                button.isSelected = false
            }
        }
        aggregationTypeViewDelegate?.didSelect(aggregationType: AggregationType(rawValue: sender.tag)!)
    }
    
    func setSelected(type:AggregationType)
    {
        for button in buttons
        {
            if button.tag == type.rawValue
            {
                button.isSelected = true
            }
            else
            {
                button.isSelected = false
            }
        }
    }
    
    private func initialize()
    {
        var lastXPosition:CGFloat = 0
        for aggregationType in AggregationType.allValues
        {
            let rect = CGRect(x: lastXPosition, y: 0, width: buttonWidth, height: buttonHeight)
            let button = UIButton(frame: rect)
          
            button.setTitleColor(Colors.instance.chart_aggregationTextColor, for: .normal)
            var activeAttributes = [NSAttributedStringKey : NSObject]();
            activeAttributes[NSAttributedStringKey.font] = Font.avenirHeavy13;
            activeAttributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_aggregationTextColorActive;
//            activeAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
            activeAttributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue as NSObject
            let selectAttributed = NSAttributedString(string: aggregationType.description, attributes: activeAttributes)
            button.setAttributedTitle(selectAttributed, for: .selected)
            
            
            var normalAttributes = [NSAttributedStringKey : NSObject]();
            normalAttributes[NSAttributedStringKey.font] = Font.avenirHeavy13;
            normalAttributes[NSAttributedStringKey.foregroundColor] = Colors.instance.chart_aggregationTextColor;
            //            activeAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle

            let normalAttributed = NSAttributedString(string: aggregationType.description, attributes: normalAttributes)
            button.setAttributedTitle(normalAttributed, for: .normal)
            
            button.titleLabel?.font = Font.avenirMedium14
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            button.tag = aggregationType.rawValue
            lastXPosition = rect.maxX
            buttons.append(button)
            self.addSubview(button)
        }
        
        self.contentSize = CGSize(width: lastXPosition, height: buttonHeight)
    }
}
