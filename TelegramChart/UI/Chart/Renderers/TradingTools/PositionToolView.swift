//
//  PositionTradingView.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class PositionToolView: OrderToolView {
   
    var buyNotActiveImage:UIImage?
    var sellNotActiveImage:UIImage?
    
    override func processClose(){
        if let position = marketOperation as? Position
        {
            renderer?.closePosition(position: position)
        }
    }
    
    override var price:Double?
    {
        get
        {
            return marketOperation?.price.doubleValue
        }
    }
    
    override var allowCancel:Bool
    {
        get
        {
            guard let symbol = marketOperation?.getSymbol() else {return false}
            guard let account = marketOperation?.getAccount() else {return false}
            
            return symbol.isOperationAllowed(.orderEntry, account:account)
        }
    }
    
    override init(marketOperation: MarketOperation, renderer: TradingToolsRenderer) {
        super.init(marketOperation: marketOperation, renderer: renderer)
        buyImage = UIImage(named:"positionBlue")
        sellImage = UIImage(named:"positionRed")
        dashStyle = .solid
    }
    
    override var orderType:PFOrderType{
        get{
            return marketOperation?.orderType ?? .market
        }
    }
    
    override func descriptionText() -> String {
        if let position = marketOperation as? Position
        {
            let assetPresission = position.getAccount()?.currentAsset?.assetType?.minChange ?? 0.01
            let currency = position.getAccount()?.currentAsset?.assetType?.name
            return String.stringFormatWithRoundingFor(position.netPnL, tickSize: assetPresission, suffix: currency, alwaysPositiveValue: false)!
        }
        return ""
    }
}
