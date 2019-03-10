//
//  SLToolView.swift
//  Protrader 3
//
//  Created by Yuriy on 19/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class SLToolView: ClosingOrderToolView {
    
    override var allowTtailingStop:Bool
    {
        get
        {
            guard let symbol = self.linkedTool?.marketOperation?.getSymbol() else {return false}
            guard let account = self.linkedTool?.marketOperation?.getAccount() else {return false}
            return Validator.allowPlaceOrder(symbol: symbol, account: account) && account.rules.allowTrailing && symbol.isAvailableOrderType(PFOrderType.trailingStop, account: account)
        }
    }
    
    override var orderType:PFOrderType{
        get{
            if let marketOperation = marketOperation
            {
                return marketOperation.orderType
            }
            else if let lindedTool = linkedTool
            {
                if lindedTool.marketOperation?.slPriceType == .trailingOffset
                {
                    return .trailingStop
                }
            }
            return .stop
        }
    }
    
    override func processTrailing(){
        if let parentOrder = linkedTool?.marketOperation as? Position
        {
            let modifyPosition = Position(position: parentOrder)
            if modifyPosition.stopLossOrder != nil
            {
                modifyPosition.stopLossOrder = Order(order: modifyPosition.stopLossOrder as! Order)
            }
            if modifyPosition.takeProfitOrder != nil
            {
                modifyPosition.takeProfitOrder = Order(order: modifyPosition.takeProfitOrder as! Order)
            }
            if self.marketOperation?.orderType == .stop
            {
                modifyPosition.slTrailingOffset = parentOrder.getSLOffset()
                modifyPosition.slPriceType = PFPriceType.trailingOffset
            }
            else
            {
                modifyPosition.stopLossPrice = parentOrder.getRealSLPrice()
                modifyPosition.slPriceType = PFPriceType.price
            }
            renderer?.modifyPosition(position: modifyPosition)
        }
        else if let parentOrder = linkedTool?.marketOperation as? Order
        {
            let modifyOrder = Order(order: parentOrder)
            
            if parentOrder.slPriceType != PFPriceType.trailingOffset
            {
                modifyOrder.stopLossPrice = parentOrder.getSLOffset()
                modifyOrder.slPriceType = PFPriceType.trailingOffset
            }
            else
            {
                if MarketOperationsBuilder.allowSLTPOffset(marketOperation: modifyOrder, orderType: orderType)
                {
                    modifyOrder.stopLossPrice = parentOrder.getSLOffset()
                    modifyOrder.slPriceType = PFPriceType.offset
                }
                else
                {
                    modifyOrder.stopLossPrice = parentOrder.getRealSLPrice()
                    modifyOrder.slPriceType = PFPriceType.price
                }
            }
            
            renderer?.modifyOrder(order: modifyOrder)
        }
    }
    
    override var leftText:String?
    {
        get{
            return "SL"
        }
    }
    
}
