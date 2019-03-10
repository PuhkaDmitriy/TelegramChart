//
//  TradingObjectsRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 15/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TradingToolsRenderer: BaseRenderer {
    override var useInAutoScale : Bool
    {
        get{return Settings.shared.fitOrdersPositions}
    }
    var tradingTools = [TradingToolKey:TradingToolView]()
    
    override init(chartBase: ChartBase) {
        super.init(chartBase: chartBase)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.orderChanged(_:)), name: SessionNotification.ORDER_CHANGE, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.orderActionInnerRefuse(_:)), name: SessionNotification.ORDER_ACTION_INNER_REFUSE, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.positionActionInnerRefuse(_:)), name: SessionNotification.POSITION_ACTION_INNER_REFUSE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.orderRemoved(_:)), name: SessionNotification.ORDER_REMOVED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.orderRemoved(_:)), name: SessionNotification.ORDER_FILLED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.positionChanged(_:)), name: SessionNotification.POSITION_CHANGE, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.processBusinessReject(_:)), name: SessionNotification.BUSINESS_MESSAGE_REJECT, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.populateTools), name: Settings.SHOW_POSITIONS_SETTINGS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.populateTools), name: Settings.SHOW_ORDERS_SETTINGS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TradingToolsRenderer.populateTools), name: Settings.FIT_ORDERS_POSITIONS_SETTINGS, object: nil)
    }
    
    func getSortedTools() -> [TradingToolView]
    {
        let array = tradingTools.values.sorted { (tool1, tool2) -> Bool in
            if tool1.isActive
            {
                return false
            }
            else if tool2.isActive
            {
                return true
            }
            else if tool1.priority > tool2.priority
            {
                return false
            }
            return true
        }
        return array
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext, window: ChartWindow?, windowsContainer: WindowContainer?) {
        
        let array = getSortedTools()
        for tool in array
        {
            tool.draw(ctx: ctx, window: window)
        }
    }
    
    @objc func orderRemoved(_ notification: Notification)
    {
        guard let order = notification.object as? Order else {return}
        if (order.accountID == chartBase?.account?.accountID && order.symbolID.isSame(chartBase?.symbol?.symbolID))
        {
            removeOrder(order: order)
            (chartBase as? ProChart)?.redrawToolsLayer(forceRedraw: true)
        }
    }
    
    
    @objc func orderChanged(_ notification: Notification)
    {
        let order = notification.object as! Order
        if ((Settings.shared.showOrders || !order.isOpen) && order.accountID == chartBase?.account?.accountID && order.symbolID.isSame(chartBase?.symbol?.symbolID))
        {
            if Session.sharedSession.dataCache.ordersDictionary[order.orderID] != nil
            {
                updateOrder(order: order)
            }
            else
            {
                removeOrder(order: order)
            }
            (chartBase as? ProChart)?.redrawToolsLayer(forceRedraw: true)
        }
    }
    
    
    @objc func positionChanged(_ notification: Notification)
    {
        guard let position = notification.object as? Position else {return}
        if (Settings.shared.showPositions && position.accountID == chartBase?.account?.accountID && position.symbolID.isSame(chartBase?.symbol?.symbolID))
        {
            if Session.sharedSession.dataCache.positionsDictionary[position.positionID] != nil
            {
                updatePosition(position: position)
            }
            else
            {
                removePosition(position: position)
            }
            
            (chartBase as? ProChart)?.redrawToolsLayer(forceRedraw: true) 
        }
    }
    
    @objc func processBusinessReject(_ notification: Notification)
    {
        populateTools()
    }
    
    
    
    private func  keyFromMarketOperation(marketOperaion:MarketOperation) -> TradingToolKey
    {
        if let marketOperation = marketOperaion as? Position
        {
            let positionID = marketOperation.positionID
            return TradingToolKey(id: positionID, isPosition: true)
        }
        else
        {
            let orderID = marketOperaion.orderID
            return TradingToolKey(id: orderID, isPosition: false)
        }
    }
    
    func removePosition(position:Position)
    {
        tradingTools.removeValue(forKey: keyFromMarketOperation(marketOperaion: position))
    }

    func removeOrder(order:Order) {
        if order.isOpen
        {
            tradingTools.removeValue(forKey: keyFromMarketOperation(marketOperaion: order))
        }
        else
        {
            if let positionToolView = tradingTools[TradingToolKey(id: order.positionID, isPosition: true)] as? PositionToolView
            {
                if order.orderType == .limit
                {
                    positionToolView.tpOrder = nil
                }
                else if order.orderType == .stop || order.orderType == .stopLimit
                {
                    positionToolView.slOrder = nil
                }
            }
        }
    }
    
    @discardableResult
    func updatePosition(position:Position) -> PositionToolView?
    {
        if position.symbolID.isSame(chartBase?.symbol?.symbolID)
        {
            
            var positionToolView = tradingTools[keyFromMarketOperation(marketOperaion: position)] as? PositionToolView
            if positionToolView == nil
            {
                positionToolView = PositionToolView(marketOperation: position, renderer: self)
                tradingTools[keyFromMarketOperation(marketOperaion: position)] = positionToolView
            }
            if let positionToolView = positionToolView
            {
                if let stopLossOrder = position.stopLossOrder as? MarketOperation
                {
                    if positionToolView.slOrder != nil
                    {
                        positionToolView.slOrder?.marketOperation = stopLossOrder
                    }
                    else
                    {
                        let slToolView = SLToolView(renderer:self, parentToolView: positionToolView, marketOperation: stopLossOrder)
                        positionToolView.slOrder = slToolView
                    }
                }
                else
                {
                    positionToolView.slOrder = nil
                }
                
                if let takeProfitOrder = position.takeProfitOrder as? MarketOperation
                {
                    if positionToolView.tpOrder != nil
                    {
                        positionToolView.tpOrder?.marketOperation = takeProfitOrder
                    }
                    else
                    {
                        let tpToolView = TPToolView(renderer:self, parentToolView: positionToolView, marketOperation:takeProfitOrder)
                        positionToolView.tpOrder = tpToolView
                    }
                }
                else
                {
                    positionToolView.tpOrder = nil
                }
                return positionToolView
            }
        }
        return nil
    }
    
    @discardableResult
    func updateOrder(order:Order) -> OrderToolView?
    {
        if ( order.symbolID.isSame(chartBase?.symbol?.symbolID) && order.orderType != .market)
        {
            if (order.isOpen)
            {
                var orderToolView = tradingTools[keyFromMarketOperation(marketOperaion: order)] as? OrderToolView
                if orderToolView == nil
                {
                    orderToolView = OrderToolView(marketOperation: order, renderer: self)
                    tradingTools[keyFromMarketOperation(marketOperaion: order)] = orderToolView
                }
                
                if let orderToolView = orderToolView
                {
                    if (order.stopLossPrice != nil)
                    {
                        if orderToolView.slOrder == nil
                        {
                            let slToolView = SLToolView(renderer:self, parentToolView: orderToolView)
                            orderToolView.slOrder = slToolView
                        }
                    }
                    else
                    {
                        orderToolView.slOrder = nil
                    }
                    
                    if (order.takeProfitPrice != nil)
                    {
                        if orderToolView.tpOrder == nil
                        {
                            let tpToolView = TPToolView(renderer:self, parentToolView: orderToolView)
                            orderToolView.tpOrder = tpToolView
                        }
                    }
                    else
                    {
                        orderToolView.tpOrder = nil
                    }
                    
                    return orderToolView
                }
            }
        }
        return nil
    }
    
    @objc func populateTools()
    {
        let dataCache = Session.sharedSession.dataCache
        
        var newOrderToolsViews = [TradingToolKey:TradingToolView]()
        
        for order in dataCache.ordersDictionary.values
        {
            if Settings.shared.showOrders || !order.isOpen
            {
                if let orderToolView = updateOrder(order: order)
                {
                    newOrderToolsViews[keyFromMarketOperation(marketOperaion: order)] = orderToolView
                }
            }
        }
        
        if Settings.shared.showPositions
        {
            for position in dataCache.positionsDictionary.values
            {
                if let positionToolView = updatePosition(position: position)
                {
                    newOrderToolsViews[keyFromMarketOperation(marketOperaion: position)] = positionToolView
                }
            }
        }
        tradingTools = newOrderToolsViews
        (self.chartBase as? ProChart)?.redrawBuffer(forceRedrawPriceScale: true, forceRedrawToolsLayer: true)
    }
    
    override func processTap(recognizer:UITapGestureRecognizer, coordinate:CGPoint) -> Bool
    {
        let array = getSortedTools().reversed()
        var activated:Bool = false
        for tool in array
        {
            if activated
            {
                tool.priority += 1
            }
            else
            {
                if tool.processTap(recognizer: recognizer, coordinate: coordinate)
                {
                    activated = true
                    tool.priority = 0
                }
                else
                {
                    tool.priority += 1
                }
            }
        }
        if activated
        {
            return true
        }
        return false
    }
    
    func placeOrder(order:Order)
    {
        
    }
    
    func closePosition(position:Position)
    {
        if Settings.shared.positionClosing
        {
            if let baseController = self.chartBase?.viewController() as? BaseViewController
            {
                AlertManager(baseController).alert(.closePosition, marketOperation: position, { isConformed in
                    if(isConformed) {
                        position.clientPanelID = PFPanelId.chart_VISUAL
                        Session.sharedSession.positionBox.closePosition(position)
                    }
                })
            }
        }
        else
        {
            Session.sharedSession.positionBox.closePosition(position)
        }
    }
    
    func cancelOrder(order:Order)
    {
        if Settings.shared.orderCancelling
        {
            if let baseController = self.chartBase?.viewController() as? BaseViewController
            {
                AlertManager(baseController).alert(.closeOrder, marketOperation: order, { isConformed in
                    if(isConformed) {
                        order.clientPanelID = PFPanelId.chart_VISUAL
                        Session.sharedSession.orderBox.cancelOrder(order)
                    }
                })
            }
        }
        else
        {
            order.clientPanelID = PFPanelId.chart_VISUAL
            Session.sharedSession.orderBox.cancelOrder(order)
        }
    }
    
    func modifyOrder(order:Order)
    {
        if Settings.shared.orderModifying
        {
            if let baseController = self.chartBase?.viewController() as? BaseViewController
            {
                AlertManager(baseController).alert(.modifyOrder, marketOperation: order, { isConformed in
                    if(isConformed) {
                        order.clientPanelID = PFPanelId.chart_VISUAL
                        Session.sharedSession.orderBox.replaceOrder(order)
                    }
                })
            }
        }
        else
        {
            Session.sharedSession.orderBox.replaceOrder(order)
        }
    }
    
    func modifyPosition(position:Position)
    {
        if Settings.shared.positionModifying
        {
            if let baseController = self.chartBase?.viewController() as? BaseViewController
            {
                AlertManager(baseController).alert(.modifyPosition, marketOperation: position, { isConformed in
                    if(isConformed) {
                        position.clientPanelID = PFPanelId.chart_VISUAL
                        Session.sharedSession.positionBox.modifyPosition(position)
                    }
                })
            }
        }
        else
        {
            Session.sharedSession.positionBox.modifyPosition(position)
        }
    }
    
    
    override func findMinMax(_ min: inout Double, max: inout Double, window: ChartWindow) -> Bool
    {
        min = Double.greatestFiniteMagnitude;
        max = -Double.greatestFiniteMagnitude;
        
        for toolView in tradingTools.values
        {
            if let price = toolView.price
            {
                if (price > max)
                {
                    max = price;
                }
                if (price < min)
                {
                    min = price;
                }
            }
            
            if let orderTool = toolView as? OrderToolView, orderTool.isActive
            {
                if let slTool = orderTool.slOrder, let price = slTool.price
                {
                    if (price > max)
                    {
                        max = price;
                    }
                    if (price < min)
                    {
                        min = price;
                    }
                }
                
                if  let tpTool = orderTool.tpOrder, let price = tpTool.price
                {
                    if (price > max)
                    {
                        max = price;
                    }
                    if (price < min)
                    {
                        min = price;
                    }
                }
            }
        }
        return true;
    }
}



