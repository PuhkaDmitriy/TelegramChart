//
//  OrderTradingView.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class OrderToolView: TradingToolView {
    var slOrder:SLToolView?
    var tpOrder:TPToolView?
    
    var buyImage:UIImage?
    var sellImage:UIImage?
    
    init (marketOperation:MarketOperation,renderer: TradingToolsRenderer)
    {
        super.init(renderer:renderer)
        self.marketOperation = marketOperation
        buyImage = UIImage(named:"orderBlue")
        sellImage = UIImage(named:"orderRed")
    }
    
    override func processClose(){
        if let order = marketOperation as? Order
        {
            renderer?.cancelOrder(order: order)
        }
    }
    
    override var leftImage: UIImage?
    {
        get{
            if side == .buy
            {
                return buyImage
            }
            else
            {
                return sellImage
            }
        }
    }
    
    override var price:Double?
    {
        get
        {
            return marketOperation?.price.doubleValue
        }
    }
    
    override var orderType:PFOrderType{
        get{
            return marketOperation?.orderType ?? .market
        }
    }
    
    override var allowCancel:Bool
    {
        get
        {
            guard let symbol = marketOperation?.getSymbol() else {return false}
            guard let account = marketOperation?.getAccount() else {return false}
            
            return symbol.isOperationAllowed(PFTradeSessionAllowedOperationType.cancel, account:account)
        }
    }
    
    override var side:PFMarketOperationType
    {
        get{
            return marketOperation?.operationType ?? .buy
        }
    }
    
    override func descriptionText() -> String {
        if errorMode
        {
            return  NSLocalizedString("chart.visualTrading.Invalid price", comment: "")
        }
        else
        {
            return marketOperation?.getAmountInString() ?? ""
        }
    }
}
