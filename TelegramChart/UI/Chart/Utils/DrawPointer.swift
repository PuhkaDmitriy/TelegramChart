//
//  DrawPointer.swift
//  Protrader 3
//
//  Created by Yuriy on 10/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit



class DrawPointer{
    /// <summary>
    /// если установлен yLocation - брать высоту с него  иначе из priceValue через преобразование
    /// </summary>
    private(set) var yLocation:CGFloat?;
    /// <summary>
    /// если установлен yLocation - брать высоту с него  иначе из priceValue через преобразование
    /// </summary>
    private(set) var priceValue:Double
    private(set) var backgroundBrush:CGColor
    private(set) var formatPriceValue:String
    private(set) var font:UIFont?;
    private(set) var borderPen:Pen?;
    private(set) var stringFormat:String?;
    private(set) var drawPointerTypeEnum:DrawPointerTypeEnum
    private(set) var textColor:UIColor?
    
    /// <summary>
    /// class to hold values needed to draw Pointer
    /// </summary>
    /// <param name="DrawPointerTypeEnum">Type of pointer - for sorting draw order</param>
    /// <param name="curPriceValue">level for drawing pointer. если установлен yLocation - брать высоту с него  иначе из priceValue через преобразование</param>
    /// <param name="backgroundBrush">backGround color</param>
    /// <param name="formatcurPriceValue">formatted text</param>
    /// <param name="f"></param>
    /// <param name="borderPen">border if needed</param>
    /// <param name="sf"></param>
    /// <param name="yLocation">если установлен yLocation - брать высоту с него  иначе из priceValue через преобразование</param>
    init ( drawPointerTypeEnum:DrawPointerTypeEnum, curPriceValue:Double, backgroundBrush:CGColor, formatcurPriceValue:String, f:UIFont? = nil, borderPen:Pen? = nil, sf:String? = nil, yLocation:CGFloat? = nil, textColor:UIColor? = nil)
    {
        self.priceValue = curPriceValue;
        self.backgroundBrush = backgroundBrush;
        self.formatPriceValue = formatcurPriceValue;
        self.font = f;
        self.borderPen = borderPen;
        self.stringFormat = sf;
        self.drawPointerTypeEnum = drawPointerTypeEnum;
        self.yLocation = yLocation;
        self.textColor = textColor
    }
    
}

enum DrawPointerTypeEnum:Int {
    case bidAsk = 0
    case indicator
    case overlay
    case visualTrading
    case lowPriority
}

