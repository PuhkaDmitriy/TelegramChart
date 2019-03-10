//
//  TerceraChartDrawingType.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

enum TerceraChartDrawingType: Int {
    case line
    case bar
    case candle
    case dot
    case dotLine
    case forest
    case solid
    case ticTac
    case kagi
    case linesBreak
    case cluster
    case profile


    static let allValues: [TerceraChartDrawingType] = [.line, .bar, .candle, .dot, .dotLine, .forest, solid]

    func getLocalizationKey() -> String {
        switch self {
        case .line:
            return "chart.tool.line"
        case .bar:
            return "chart.tool.bar"
        case .candle:
            return "chart.tool.candle"
        case .dot:
            return "chart.tool.dots"
        case .dotLine:
            return "chart.tool.dottedLine"
        case .forest:
            return "chart.tool.forest"
        case .solid:
            return "chart.tool.area"
        case .ticTac:
            return "chart.tool.tictac"
        case .kagi:
            return "chart.tool.kagi"
        case .linesBreak:
            return "chart.tool.threelines"
        case .cluster:
            return "chart.tool.cluster"
        case .profile:
            return "chart.tool.profile"
        }
    }
}

// SPREAD INDICATOR
enum TercaraChartPriceIndicatorType: Int {
    case scaleMarker
    case scaleMarkerWithLine
    case none
};

// SPREAD INDICATOR
enum TerceraChartSpreadType: Int {
    case area
    case lines
    case linesWithPrices
    case none
}

