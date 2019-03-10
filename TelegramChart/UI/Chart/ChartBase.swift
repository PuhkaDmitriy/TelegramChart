//
//  ChartBase.swift
//  Protrader 3
//
//  Created by Yuriy on 24/10/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

enum ChartType {
    case marketLeader
    case simpleChart
    case proChartMobile
    case proChartTablet
}

class ChartBase: UIView, IQuoteListener {

    override open var frame: CGRect {
        didSet {
            resizeView()
        }
    }

    class LayerListener: NSObject, CALayerDelegate {
        weak var chartBase: ChartBase?

        init(chartBase: ChartBase) {
            super.init()
            self.chartBase = chartBase
        }

        public func draw(_ layer: CALayer, in ctx: CGContext) {
            chartBase?.drawLayer(layer, in: ctx)
        }
        
        public func action(for layer: CALayer, forKey event: String) -> CAAction? {
            return NSNull()
        }
    }

    var tapGestureRecognizer: UITapGestureRecognizer?
    var cursorLayer = CALayer()
    var mainLayer = CALayer()
    var lastFrame: CGRect = .zero
    var emptyContentView: EmptyContentView!
    var scrollView: UIScrollView!
    var lastCursorPosition: CGPoint?
    var type: ChartType = .marketLeader
    var tradingToolRenderer:TradingToolsRenderer?

    var listener: LayerListener?
    
    func enableGestureRecognizers(isEnabled:Bool)
    {
        tapGestureRecognizer?.isEnabled = isEnabled
    }

//    var centerXConstraint:NSLayoutConstraint
//    var centerYConstraint:NSLayoutConstraint

    var symbolID: PFSymbolId? {
        didSet {
            if symbolID != oldValue {

                symbolChanged()
                if oldValue != nil {
                    unsubscribeSymbolId(oldValue!)
                }
                if symbolID != nil {
                    self.symbol = Session.sharedSession.dataCache.symbolsDictionary[symbolID!]
                    subscribeSymbol(symbolID!)
                }
            }
        }
    }

    var symbol: SymbolInfo?


    func redrawAll() {
        self.mainLayer.setNeedsDisplay()
        self.cursorLayer.setNeedsDisplay()
    }

    var accountID: Int = -1 {
        didSet {
            account = Session.sharedSession.dataCache.accountsDictionary[accountID]
            
        }
    }
    var account: Account?

    deinit {
        Session.sharedSession.quoteBox.checkSubscriptionsByTimer()
    }

    func symbolChanged() {
        //for override
    }

    //MARK: - IQuoteListener
    func newQuote(_ quote: Quote) {
        //for Override
    }

    func newQuoteLevel3(_ quote: Quote, message: Level3QuoteMessage) {
        //for Override
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialization()
    }

    //MARK: - Subscribe && Unsubscribe
    func subscribeSymbol(_ symbolID: PFSymbolId) {
        Session.sharedSession.quoteBox.subscribeLevel1(symbolID, listener: self)
        Session.sharedSession.quoteBox.subscribeTrades(symbolID, listener: self)
    }

    func unsubscribeSymbolId(_ symbolID: PFSymbolId) {
        Session.sharedSession.quoteBox.unsubscribeLevel1(symbolID, listener: self)
        Session.sharedSession.quoteBox.unsubscribeTrades(symbolID, listener: self)
    }

    func initialization() {
        self.isUserInteractionEnabled = true
        
        self.mainLayer.frame = self.layer.frame
        self.layer.addSublayer(mainLayer)
        
//        self.mainLayer.actions = ["onOrderIn":NSNull(), "onOrderOut":NSNull(), "sublayers":NSNull(), "contents":NSNull(), "bounds":NSNull()]
        self.cursorLayer.frame = self.layer.frame
        self.layer.addSublayer(cursorLayer)


        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChartBase.handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer!)
        layoutChart()
        self.mainLayer.contentsScale = UIScreen.main.scale
        self.cursorLayer.contentsScale = UIScreen.main.scale
        emptyContentView = EmptyContentView(frame: self.bounds)

        self.addSubview(emptyContentView)
        emptyContentView.isUserInteractionEnabled = true
        emptyContentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        emptyContentView.clipsToBounds = true
        setNoDataAvailable()


        listener = LayerListener(chartBase: self)
        self.cursorLayer.delegate = listener
        self.mainLayer.delegate = listener
    }

    func setNoDataAvailable() {
        emptyContentView.isHidden = false
        emptyContentView.emptyLabel.text = NSLocalizedString("simpleChart.noDataAvailable", comment: "")
        emptyContentView.isLoading = false
        emptyContentView.activityIndicator.isHidden = true

    }

    func hideEmptyContentView() {
        emptyContentView.isHidden = true
        emptyContentView.isLoading = false
    }

    func startLoading() {
        emptyContentView.isHidden = false
        emptyContentView.emptyLabel.text = NSLocalizedString("simpleChart.loading", comment: "")
        emptyContentView.isLoading = true
    }

    func drawLayer(_ layer: CALayer, in ctx: CGContext) {

        if lastFrame != frame {
            lastFrame = frame
            layoutChart()
        }
    }

    func layoutChart() {
        // For override
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let translation = recognizer.location(in: self)
        processTap(recognizer: recognizer, coordinate: translation)
    }

    func processTap(recognizer: UITapGestureRecognizer, coordinate: CGPoint) {
        /*for override*/
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // For override
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // For override
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // For override
    }

    open func resizeView() {
        if (self.frame.width > 0 && self.frame.height > 0) {
            cursorLayer.frame = self.bounds
            mainLayer.frame = self.bounds
            self.layoutChart()
        }
    }
}