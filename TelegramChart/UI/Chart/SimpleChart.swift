//
//  SimpleChart.swift
//  Protrader 3
//
//  Created by Yuriy on 24/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

enum SimpleChartPeriods: CustomStringConvertible {
    case year
    case sixMonths
    case threeMonths
    case oneMonth
    case oneWeek
    case oneDay

    static let allValues: [SimpleChartPeriods] = [.oneDay, .oneWeek, .oneMonth, .threeMonths, .sixMonths, .year]

    var description: String {
        get {
            switch self {
            case .year:
                return NSLocalizedString("simpleChart.year", comment: "")
            case .sixMonths:
                return NSLocalizedString("simpleChart.6month", comment: "")
            case .threeMonths:
                return NSLocalizedString("simpleChart.3month", comment: "")
            case .oneMonth:
                return NSLocalizedString("simpleChart.1month", comment: "")
            case .oneWeek:
                return NSLocalizedString("simpleChart.1weak", comment: "")
            case .oneDay:
                return NSLocalizedString("simpleChart.1day", comment: "")
            }
        }
    }

    func getTFI(symbol: SymbolInfo) -> (tfi: TimeFrameInfo, from: Int64, to: Int64) {
        let oneDay: Int64 = 24 * 60 * 60 * 1000
        let toDate = Date().msecondsTimeStamp()
        var fromDate = Date().msecondsTimeStamp()
        var period: Int = Periods.MIN
        switch self {
        case .year:
            fromDate = toDate - 365 * oneDay
            period = Periods.DAY
        case .sixMonths:
            fromDate = toDate - 183 * oneDay
            period = Periods.DAY
        case .threeMonths:
            fromDate = toDate - 91 * oneDay
            period = Periods.DAY
        case .oneMonth:
            fromDate = toDate - 30 * oneDay
            period = Periods.DAY
        case .oneWeek:
            fromDate = toDate - 7 * oneDay
        case .oneDay:
            fromDate = symbol.getInstrument().tradeSession?.beginDayTime ?? toDate - oneDay
        }

        let timeFrameInfo = TimeFrameInfo(tfPeriod: period, hType: symbol.getInstrument().chartBarType, spreadPlanID: -1)
        return (tfi: timeFrameInfo, from: fromDate, to: toDate)
    }
}


class SimpleChart: ChartBase, HistoryLoaderDelegate {

    var series: SimpleChartSeries?
    var currentPeriod: SimpleChartPeriods? = .sixMonths
    var tableRenderer: SimpleChartTableRenderer?
    var cursorRenderer:SimpleCursorRenderer?
    var headerRenderer: SimpleHeaderRenderer?
    var renderers: [BaseRenderer] = []


    var lastRequestID: Int64 = -1

    override func initialization() {
        super.initialization()
        self.tableRenderer = SimpleChartTableRenderer(chartBase: self)
        renderers.append(self.tableRenderer!)
        self.cursorRenderer = SimpleCursorRenderer(chartBase:self)
        renderers.append(self.cursorRenderer!)
        self.headerRenderer = SimpleHeaderRenderer(chartBase: self)
        renderers.append(self.headerRenderer!)
        layoutChart()
        series = SimpleChartSeries(chart: self)
    }

    override func symbolChanged() {
        super.symbolChanged()
        requestHistory()
    }

    override func newQuote(_ quote: Quote) {
        redrawWithTimeCheck()
    }

    override func newQuoteLevel3(_ quote: Quote, message: Level3QuoteMessage) {
        redrawWithTimeCheck()
    }

    func redrawWithTimeCheck() {
        if CFAbsoluteTime() - lastUpdate < minUpdateTime {
            redrawInTimeout()
        } else {
            DispatchQueue.main.async {
                self.cursorLayer.setNeedsDisplay()
            }
        }
    }

    private var lastUpdate = CFAbsoluteTime()
    private let minUpdateTime: Double = 0.4
    private var updateTimerScheduled = false

    private func redrawInTimeout() {
        if updateTimerScheduled == false {
            updateTimerScheduled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: { [weak self] in
                self?.cursorLayer.setNeedsDisplay()
                self?.updateTimerScheduled = false
            })
        }
    }

    func didLoadHistory(historyHolders: [QuoteHolder], historyLoader: HistoryLoader, historyParams: ReloadHistoryParams) {

        if historyParams.requestID == lastRequestID && symbolID != nil {

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.hideEmptyContentView()
                strongSelf.series?.historyHolders = historyHolders
                strongSelf.series?.from = historyParams.fromTime
                strongSelf.series?.to = historyParams.toTime
                strongSelf.series?.recalculateData()
                strongSelf.mainLayer.setNeedsDisplay()
                strongSelf.cursorLayer.setNeedsDisplay()
            }
        }
    }

    override func drawLayer(_ layer: CALayer, in ctx: CGContext) {

        if let value = series, !value.points.isEmpty {
            if layer == self.mainLayer {
                tableRenderer?.draw(layer, in: ctx, window: nil, windowsContainer: nil)
            } else if layer == self.cursorLayer {
                if self.lastCursorPosition != nil && type == .simpleChart {
                    cursorRenderer?.draw(layer, in: ctx, window: nil, windowsContainer: nil)
                } else {
                    headerRenderer?.draw(layer, in: ctx, window: nil, windowsContainer: nil)
                }
            }
        }
        else
        {
            if !emptyContentView.isLoading {
                setNoDataAvailable()
            }
        }
    }

    func requestHistory() {
        guard let symbolID = symbolID else {
            self.setNoDataAvailable();
            return
        }
        guard let symbol = Session.sharedSession.dataCache.symbolsDictionary[symbolID] else {
            self.setNoDataAvailable();
            return
        }
        guard let currentPeriod = currentPeriod else {
            self.setNoDataAvailable();
            return
        }
        let requestData = currentPeriod.getTFI(symbol: symbol)
        self.startLoading()
        self.setNeedsDisplay()
        cursorLayer.setNeedsDisplay()
        let historyParams = ReloadHistoryParams()
        historyParams.accountId = Session.sharedSession.dataCache.mainUsersAccount!.accountID
        historyParams.fromTime = requestData.from
        historyParams.toTime = requestData.to
        historyParams.requestID = Int64(IdGenerator.requestId)
        lastRequestID = historyParams.requestID
        historyParams.symbolID = symbolID
        historyParams.timeFrameInfo = requestData.tfi

        Session.sharedSession.tradeVendor?.requestHistory(forHostoryParams: historyParams, delegate: self, queue: GlobalQueues.instance.tradeQueue)
    }

    override func layoutChart() {
        guard let tableRenderer = tableRenderer else {
            return
        }
        if type == .marketLeader {
            tableRenderer.topChartOffset = 40
        } else {
            tableRenderer.topChartOffset = 65
        }
        series?.changeLayout()
        tableRenderer.rectangle = self.bounds
        headerRenderer?.rectangle = self.bounds
    }

    override func processTap(recognizer: UITapGestureRecognizer, coordinate: CGPoint) {
        for renderer in renderers {
            if renderer.processTap(recognizer: recognizer, coordinate: coordinate) {
                self.mainLayer.setNeedsDisplay()
                break
            }
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1
        {
            let location = touches.first!.location(in: self)
            if tableRenderer != nil && self.tableRenderer!.chartRect.contains(location)
            {
                self.lastCursorPosition = location
            }
            else
            {
                self.lastCursorPosition = nil
            }
        }
        else
        {
            self.lastCursorPosition = nil
        }
        cursorLayer.setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1
        {
            let location = touches.first!.location(in: self)
            if tableRenderer != nil && self.tableRenderer!.chartRect.contains(location)
            {
                self.lastCursorPosition = location
            }
            else
            {
                self.lastCursorPosition = nil
            }
        }
        else
        {
            self.lastCursorPosition = nil
        }
        cursorLayer.setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastCursorPosition = nil
        cursorLayer.setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastCursorPosition = nil
        cursorLayer.setNeedsDisplay()
    }
}
