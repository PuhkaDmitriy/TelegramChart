//
//  TerceraChartUtils.swift
//  Protrader 3
//
//  Created by Yuriy on 07/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

enum TerceraChartHistoryTypeEnum: Int {
    case `default`
    case byBid
    case byTrades
    case byAsk

    static func getValues(isTicks: Bool, selected: TerceraChartHistoryTypeEnum) -> [TerceraChartHistoryTypeEnum] {
        if isTicks {
            var bidAskElement = TerceraChartHistoryTypeEnum.byBid
            if selected == .byBid || selected == .byAsk {
                bidAskElement = selected
            }
            return [.`default`, .byTrades, bidAskElement]
        } else {
            return [.`default`, .byBid, .byTrades, .byAsk]
        }
    }


    //переводим значение по умолчанию в bid ask, trade
    func getReal(symbol: SymbolInfo?, isTicks: Bool) -> TerceraChartHistoryTypeEnum {
        if self == .`default` {
            if isTicks {
                if symbol!.getInstrument().chartBarType == PFQuoteBarType.trade {
                    return .byTrades
                } else {
                    return .byBid
                }
            } else {
                switch symbol!.getInstrument().chartBarType {
                case PFQuoteBarType.ask:
                    return .byAsk
                case PFQuoteBarType.bid:
                    return .byBid
                default:
                    return .byTrades
                }
            }

        } else {
            return self
        }
    }

    func toString(symbol: SymbolInfo?, isTicks: Bool) -> String {
        switch self {
        case .`default`:
            guard let symbol = symbol else {
                return ""
            }
            var defType: TerceraChartHistoryTypeEnum = .byTrades
            if isTicks {
                if symbol.getInstrument().chartBarType == PFQuoteBarType.trade {
                    defType = .byTrades
                } else {
                    defType = .byBid
                }
            } else {
                switch symbol.getInstrument().chartBarType {
                case PFQuoteBarType.ask:
                    defType = .byAsk
                case PFQuoteBarType.bid:
                    defType = .byBid
                default:
                    defType = .byTrades
                }
            }
            return NSLocalizedString("chart.dataType.default", comment: "") + " (\(defType.toString(symbol: nil, isTicks: isTicks)))"
        case .byBid:
            if isTicks {
                return NSLocalizedString("chart.dataType.bidAsk", comment: "")
            }
            return NSLocalizedString("chart.dataType.bid", comment: "")
        case .byTrades:
            return NSLocalizedString("chart.dataType.last", comment: "")
        case .byAsk:
            if isTicks {
                return NSLocalizedString("chart.dataType.bidAsk", comment: "")
            }
            return NSLocalizedString("chart.dataType.ask", comment: "")

        }
    }

}


class TerceraChartHistoryType: NSObject {
    var chartDataType = TerceraChartHistoryTypeEnum.default;

    init(typeEnum: TerceraChartHistoryTypeEnum) {
        self.chartDataType = typeEnum;
        super.init();
    }

    static func getOriginalHistoryType(_ chartDataType: TerceraChartHistoryTypeEnum, symbol: PFISymbol?) -> PFQuoteBarType {
        switch chartDataType {
        case TerceraChartHistoryTypeEnum.default:
            return symbol != nil ? symbol!.instrument.chartBarType : PFQuoteBarType.bid

        case TerceraChartHistoryTypeEnum.byBid:
            return PFQuoteBarType.bid;

        case TerceraChartHistoryTypeEnum.byTrades:
            return PFQuoteBarType.trade;

        case TerceraChartHistoryTypeEnum.byAsk:
            return PFQuoteBarType.ask;
        }
    }
}
