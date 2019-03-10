//
//  ClosingOrderToolView.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class ClosingOrderToolView: TradingToolView {
    
    var activeTrailingImage:UIImage?
    var buyTrailingImage:UIImage?
    var sellTrailingImage:UIImage?
    
    override func processClose(){
        if let order = self.marketOperation as? Order
        {
            renderer?.cancelOrder(order:order)
        }
        else
        {
            if let order = self.linkedTool?.marketOperation as? Order
            {
                let modifyOrder = Order(order: order)
                if self is SLToolView
                {
                    modifyOrder.slOffset = nil
                    modifyOrder.slPriceType = .null
                    modifyOrder.stopLossPrice = nil
                    modifyOrder.slPriceDouble = nil
                    modifyOrder.stopLossOrderID = -1
                }
                else
                {
                    modifyOrder.tpOffset = nil
                    modifyOrder.tpPriceType = .null
                    modifyOrder.tpPriceDouble = nil
                    modifyOrder.takeProfitPrice = nil
                    modifyOrder.takeProfitOrderID = -1
                }
                renderer?.modifyOrder(order: modifyOrder)
            }
        }
    }
    
    
    
    override var price: Double?
    {
        get {
            if let position = linkedTool?.marketOperation as? Position
            {
                return position.price.doubleValue
            }
            else
            {
                if let order = linkedTool?.marketOperation as?  Order
                {
                    if self is SLToolView
                    {
                        let slPrice = order.getRealSLPrice()
                        return slPrice == nil ? Double.nan : slPrice?.doubleValue
                    }
                    else
                    {
                        let tpPrice = order.getRealTPPrice()
                        return tpPrice == nil ? Double.nan : tpPrice?.doubleValue
                    }
                }
            }
            return nil
        }
    }
    
    
    init(renderer:TradingToolsRenderer, parentToolView:OrderToolView, marketOperation:MarketOperation? = nil) {
        super.init(renderer:renderer)
        self.activeTrailingImage = UIImage(named:"hook")
        self.buyTrailingImage = UIImage(named:"hookBlue")
        self.sellTrailingImage = UIImage(named:"hookRed")
        self.linkedTool = parentToolView
        self.marketOperation = marketOperation
        isActive = true
    }
    
    override var trailingImage:UIImage?
    {
        get{
            if orderType == .trailingStop
            {
                return activeTrailingImage
            }
            else
            {
                if side == .buy
                {
                    return buyTrailingImage
                }
                else
                {
                    return sellTrailingImage
                }
            }
        }
    }
        
    override var allowCancel:Bool
    {
        get
        {
            if let linkedTool = linkedTool
            {
                if linkedTool is PositionToolView
                {
                    guard let symbol = marketOperation?.getSymbol() else {return false}
                    guard let account = marketOperation?.getAccount() else {return false}
                    
                    return symbol.isOperationAllowed(.cancel, account:account)
                }
                else
                {
                    guard let symbol = linkedTool.marketOperation?.getSymbol() else {return false}
                    guard let account = marketOperation?.getAccount() else {return false}
                    
                    return symbol.isOperationAllowed(.modify, account:account)
                }                
            }
            else
            {
                return false
            }
        }
    }
    
    override var side:PFMarketOperationType{
        get{
            if let parentMarketOperation = linkedTool?.marketOperation
            {
                return parentMarketOperation.operationType == .buy ? .sell : .buy
            }
            return .buy
        }
    }
    
    override func descriptionText() -> String {
        let offsetTicks = getOffsetTicks()
        guard let symbol = linkedTool?.marketOperation?.getSymbol() else {return ""}
        var shortDescriptionText = !offsetTicks.isNaN ? String.stringFormatForOffset(offsetInTicks: NSDecimalNumber.decimalNum(from: offsetTicks), symbol: symbol, offsetType: Settings.shared.offsetType(), suffixFormat: .short) : "";
        
        if (errorMode || shortDescriptionText.isEmpty) {
            shortDescriptionText = NSLocalizedString("chart.visualTrading.Invalid price", comment: "")
            errorMode = true
        }
        
        return shortDescriptionText;
    }
    
    func getOffsetTicks() -> Double {
        // от цены открытия.
        guard let parentObject = linkedTool?.marketOperation else {return 0}
        guard let account = parentObject.getAccount() else {return 0}
        guard let symbol = parentObject.getSymbol() else {return 0}
        guard let price = price else {return 0}
        var orderPrice = parentObject.price.doubleValue;
        if parentObject is Position
        {
            
                if (parentObject.operationType == PFMarketOperationType.sell)
                {
                    orderPrice = symbol.quote.ask(account.spreadPlanID)
                }
                else
                {
                    orderPrice = symbol.quote.bid(account.spreadPlanID)
                }
                
                if (orderPrice < 0)
                {
                    orderPrice = symbol.quote.lastPrice
                }
            
        }
        
        let orderPriceInTicks = symbol.convertPriceToTicks(orderPrice)
        let sltpPriceInTicks = symbol.convertPriceToTicks(price)
        
        return abs(sltpPriceInTicks - orderPriceInTicks)
    }
    
}
