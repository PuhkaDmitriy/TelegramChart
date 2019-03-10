//
//  TerceraChartTradingDelegate.swift
//  Protrader 3
//
//  Created by Yuriy on 20/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

protocol TerceraChartTradingDelegate: class {
    func placeOrder(order:Order)
    func closePositions(positions:[Position])
    func cancelOrders(orders:[Order])
    func modifyOrders(orders:[Order])
    func modifyPosition(position:Position)
}
