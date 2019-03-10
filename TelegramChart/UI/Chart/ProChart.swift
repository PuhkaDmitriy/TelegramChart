//
//  ProfChart.swift
//  Protrader 3
//
//  Created by Yuriy on 03/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi


class ProChart: ChartBase, UIScrollViewDelegate, CashItemDelegate, UIGestureRecognizerDelegate, AggregationTypeViewDelegate{
    
    var historyFrom : Int64 = Date().msecondsTimeStamp();
    var historyTo : Int64 = Date().msecondsTimeStamp();
//    var contentView:UIView?
    weak var delegate:ProChartDelegate?
    let quoteListenerController = Session.sharedSession.quoteBox;
    var timeScaleRendererSettings : TerceraChartTimeScaleRendererSettings = TerceraChartTimeScaleRendererSettings();
    var windowContainer: WindowContainer?;
    var mainWindow : ChartWindow?;
    var timeFrameInfo : TimeFrameInfo?
    var mainPriceRenderer : MainPriceRenderer?
    
    var paddingHistoryStrategy : PaddingHistoryStrategy?
    var cashItemSeriesSettings : TerceraChartCashItemSeriesSettings?;
    var suspendRefreshChart = false;
    var needSetDefaultDataRange = false;
    var priceScaleLayer = CALayer()
    var toolsLayer = CALayer()
    var preferedPriceScaleWidht:CGFloat = 0
    var pinchGestureRecoginzer:UIPinchGestureRecognizer?
    var longPressGestureRecognizer:UILongPressGestureRecognizer?
    var panGestureRecognizer:UIPanGestureRecognizer?
    var isCrossHairAvailable:Bool = false
    var menu:ChartMenuView?
    var aggregationTypeView:AggregationTypeView?
    var cashItem:CashItem? // Temporary, only for request history
    
//    weak var tradingDelegate:TerceraChartTradingDelegate?

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
   
    func didSelect(aggregationType: AggregationType) {
        DispatchQueue.main.async {[weak self] in
            guard let superSelf = self else {return}
            superSelf.aggregationType = aggregationType
        }
    }
    var aggregationType = Settings.shared.aggregation()    {
        didSet
        {
            generateTimeFrameInfo()
            refreshChart()
        }
    }


    
    override var account: Account?
    {
        didSet
        {
            generateTimeFrameInfo()
            tradingToolRenderer?.populateTools()
        }
    }
    
    override var symbol: SymbolInfo?
    {
        didSet
        {
            generateTimeFrameInfo()
            tradingToolRenderer?.populateTools()
        }
    }
    
    static let DEFAULT_BARSTORIGHT_PERCENT : Double = 5;
    var barsToRight_Percent : Double = ProChart.DEFAULT_BARSTORIGHT_PERCENT
    {
        didSet
        {
            self.barsToRight_Bars = self.calculateBarToRight_Bars(self.barsToRight_Percent);
        }
    }
    var barsToRight_Bars : Int = 0;
    
    
    var mainCashItemSeries : TerceraChartCashItemSeries?
    {
        get
        {
            return self.mainPriceRenderer?.series;
        }
    }
    
    var hasCorrectData: Bool
    {
        get
        {
            return self.mainCashItemSeries != nil && self.mainCashItemSeries!.count >= 1 && !emptyContentView.isLoading;
        }
    }
    
    func calcPreferedPriceScaleWidth()
    {
        guard let symbol = symbol else {
            preferedPriceScaleWidht = 0
            return}
        //
        // Right scale
        //
        var maxW:CGFloat = 0;
        
        for i in  0 ... self.windowContainer!.windows.count - 1
        {
            let curW = self.windowContainer?.windows[i].priceScaleRenderer!.getPreferredWidth(mainCashItemSeries, symbol: symbol) ?? 0
            if (maxW < curW)
            {
                maxW = curW;
            }
        }
        preferedPriceScaleWidht = maxW
    }
    
    override func drawLayer(_ layer: CALayer, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        if (!hasCorrectData)
        {
//            if layer == mainLayer || layer == priceScaleLayer
//            {
//                ctx.setFillColor (self.backgroundColor!.cgColor);
//                ctx.fill (CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height));
//
//            }
            if (emptyContentView.isHidden)
            {
                emptyContentView.isHidden = false
            }
        }
        else
        {
            if (!emptyContentView.isHidden)
            {
                emptyContentView.isHidden = true
            }
            
            if layer == priceScaleLayer
            {
                calcPreferedPriceScaleWidth()
                for window in windowContainer!.windows
                {
                    window.beforeDrawing()
                    window.priceScaleRenderer?.draw(layer, in: ctx, window: window, windowsContainer: windowContainer)
                }
            }
            if layer == toolsLayer
            {
                for window in windowContainer!.windows
                {
                    window.toolsDrawPointers = []
                    window.beforeDrawing()
                    window.tradingToolRenderer?.draw(layer, in: ctx, window: window, windowsContainer: windowContainer)
                    window.drawAllToolsPointers(ctx)
                }
            }
            else if layer == mainLayer
            {
                drawMainLayer(layer, in: ctx)
            }
            else if layer == cursorLayer
            {
                for window in windowContainer!.windows
                {
                    for cursorRenderers in window.cursorRenderers
                    {
                        cursorRenderers.draw(layer, in: ctx, window: window, windowsContainer: windowContainer)
                    }
                }
                windowContainer!.cursorRenderer.draw(layer, in: ctx, window: nil, windowsContainer: windowContainer)
            }
        }
        UIGraphicsPopContext()
    }
    
    func addIndicators(indicators:[BaseIndicator])
    {
        
        for indicator in indicators
        {
            indicator.chart = self
            let renderer = IndicatorRenderer(indicatorModule: indicator, chart: self)
            var cashItem = mainCashItemSeries?.cashItem
            
            if let tfi = timeFrameInfo?.clone(),
                let _ = symbol?.symbolID,
                let newCashItem = Session.sharedSession.dataCache.cashItemListeners[tfi]{
                if cashItem != newCashItem{
                    cashItem = newCashItem //если чарт еще не загрузился, а мы добавляем индикаторы
                }
            }
            
            cashItem?.cashItemQueue.sync {
                indicator.setupDataSource(cashItem: cashItem!)
            }
            
            renderer.series = mainPriceRenderer?.series
            mainWindow?.indicatorStorageRenderer?.indicators.append(renderer)
        }
        
        correctIndicatorWindows()
    }
    
    func getAllActiveIndicators() -> [BaseIndicator]
    {
        var baseIndicators = [BaseIndicator]()
        for renderer in indicatorRenderers
        {
            baseIndicators.append( renderer.indicator)
        }
        return baseIndicators
    }
    
    func removeIndicator(indicator:BaseIndicator?)
    {
        var indicatorRendererTemp:IndicatorRenderer?
        for renderer in indicatorRenderers
        {
            if renderer.indicator === indicator
            {
                indicatorRendererTemp = renderer
            }
        }
        
        guard let indicatorRenderer = indicatorRendererTemp  else {
            return
        }
        indicatorRenderer.indicator.dataSource?.removeFromCashItem()
        if indicatorRenderer.windowsNumber < (windowContainer?.windows.count ?? 0)
        {
            let indicatorStorageRenederer = windowContainer?.windows[indicatorRenderer.windowsNumber].indicatorStorageRenderer
            if let index = indicatorStorageRenederer?.indicators.index(of: indicatorRenderer)
            {
                indicatorStorageRenederer?.indicators.remove(at: index)
            }
         
        }
        
        correctIndicatorWindows()
    }
    
    func correctIndicatorWindows()
    {}
    
    var indicatorRenderers:[IndicatorRenderer]
    {
        get{
            var res = [IndicatorRenderer]()
            
            if windowContainer == nil
            {
                return res
            }
            
            for window in windowContainer!.windows
            {
                if window.indicatorStorageRenderer != nil
                {
                    res += window.indicatorStorageRenderer!.indicators
                }
            }
            return res
        }
    }
    
    public func historyResponse(cashItem:CashItem)
    {
        if self.cashItem == cashItem
        {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {return}
                if cashItem.lastRequestedFromTime > 0 && strongSelf.paddingHistoryStrategy?.availableDragging == true
                {
                    strongSelf.historyFrom = cashItem.lastRequestedFromTime
                }
                let loadHistoryResult = strongSelf.replaceCashItem(cashItem)
                
                
                if(strongSelf.hasCorrectData && strongSelf.needSetDefaultDataRange)
                {
                    for r in strongSelf.mainWindow!.getAllRenderers
                    {
                        if let renderer = r as? ISetDefaultRange
                        {
                            renderer.setDefaultRange(strongSelf.mainWindow!);
                        }
                        
                        strongSelf.needSetDefaultDataRange = false;
                    }
                }
                if(loadHistoryResult == .finish || cashItem.nonEmptyCashArray.count > 0 )
                {
                    
                    strongSelf.mainCashItemSeries?.recalcIndices()
                   
                    if strongSelf.emptyContentView.isLoading
                    {
                        strongSelf.toBegin();
                        if(strongSelf.mainWindow != nil && !strongSelf.mainWindow!.autoScale)
                        {
                            strongSelf.mainWindow!.autoFit();
                        }
                    }
                    
                    strongSelf.emptyContentView.isLoading = false
                    if cashItem.nonEmptyCashArray.count == 0
                    {
                        strongSelf.setNoDataAvailable()
                    }
                }
                
                strongSelf.redrawBuffer(forceRedrawPriceScale: true);
                if loadHistoryResult == .partial
                {
                    strongSelf.paddingHistoryStrategy?.startLoading(context: .weekend, startingReason: .dragging)
                }
            }
        }
    }
    
    
    override func enableGestureRecognizers(isEnabled:Bool)
    {
        super.enableGestureRecognizers(isEnabled:isEnabled)
        pinchGestureRecoginzer?.isEnabled = isEnabled
        longPressGestureRecognizer?.isEnabled = isEnabled
       
    }
 
    
    override func initialization() {
        self.autoresizesSubviews = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ProChart.handlePan(recognizer:)))
        panGestureRecognizer?.delegate = self
       
        self.addGestureRecognizer(panGestureRecognizer!)
        pinchGestureRecoginzer = UIPinchGestureRecognizer(target: self, action: #selector(ProChart.handlePinch(recognizer:)))
        self.addGestureRecognizer(pinchGestureRecoginzer!)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ProChart.handleLongPress(recognizer:)))
        self.addGestureRecognizer(longPressGestureRecognizer!)
        self.priceScaleLayer.frame = self.layer.frame
        self.toolsLayer.frame = self.layer.frame
        self.layer.addSublayer(priceScaleLayer)
        
        self.priceScaleLayer.contentsScale = UIScreen.main.scale
        self.toolsLayer.contentsScale = UIScreen.main.scale
        super.initialization()
        self.layer.addSublayer(toolsLayer)
        self.priceScaleLayer.delegate = listener
        self.toolsLayer.delegate = listener
        self.cashItemSeriesSettings = TerceraChartCashItemSeriesSettings()
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.scrollView.clipsToBounds = true
        self.addSubview(scrollView)
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: 10, height: 1)
        self.paddingHistoryStrategy = PaddingHistoryStrategy(chart: self)
        
        let menuWidth:CGFloat = 70
        
        let menuFrame = CGRect(x: self.frame.maxX, y: self.frame.origin.y, width: menuWidth, height: self.frame.height)
        
        
        self.initMainWindow();
        
        aggregationTypeView = AggregationTypeView(frame: CGRect(x: 0, y: mainWindow?.headerRenderer?.height ?? 30, width: self.frame.width, height: 20))
        self.addSubview(aggregationTypeView!)
        self.aggregationTypeView?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleBottomMargin]
        self.aggregationTypeView?.aggregationTypeViewDelegate = self
        self.aggregationTypeView?.setSelected(type: aggregationType)
        
        self.menu = ChartMenuView(frame: menuFrame,chart:self )
        self.menu?.isHidden = true
        self.addSubview(self.menu!)
        self.menu?.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleLeftMargin]
        layoutWindowContainers()
    }
    
    func showMainMenu()
    {
        if menu?.isHidden == false
        {
            hideMenu()
        }else
        {
//            showMenu(menuType: .mainMenu)
            showMenu(menuType: .chartStyleMenu)
        }
    }
    
  
    
    func showMenu(menuType:ChartMenuType)
    {
        enableGestureRecognizers(isEnabled: false)
        self.menu?.isHidden = false
        UIView.animate(withDuration: 0.4) {
            let menuRect:CGRect = self.menu?.frame ?? .zero
            self.menu?.chartMenuType = menuType
            let newWidth = self.menu?.calculatePreferedWidth() ?? 70
            self.menu?.table.reloadData()
            self.menu?.frame = CGRect(x: self.frame.maxX - newWidth, y: menuRect.minY,
                                      width: newWidth, height: menuRect.height)
        }
    }
    
    func hideMenu()
    {
        enableGestureRecognizers(isEnabled: true)
        UIView.animate(withDuration: 0.4, animations: {
            let menuRect:CGRect = self.menu?.frame ?? .zero
            self.menu?.chartMenuType = .mainMenu
            self.menu?.table.reloadData()
            self.menu?.frame = CGRect(x: self.frame.maxX, y: menuRect.minY,
                                      width: menuRect.width, height: menuRect.height)
        }, completion: { (res) in
            self.menu?.isHidden = true
        })
    }
    
//    var beginControlSize:CGFloat = 0
//    var beginScale  = 0
//    var zoomSize:CGFloat = 20
    var beginScale:CGFloat = 0
    var currentRealXScale:CGFloat = 0
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {return}

            if recognizer.state == .began
            {
                strongSelf.beginScale = CGFloat(strongSelf.mainWindow?.xScale ?? 4)
            }
            if recognizer.state != .ended && recognizer.state != .began && recognizer.scale != 1
            {
                strongSelf.mainWindow?.checkAndSetXscale(new: Int(strongSelf.beginScale * recognizer.scale))
                strongSelf.redrawBuffer()
                
            }
        }
    }
    
    var beganShowMenu = false
    var beganPoint:CGPoint = .zero
    var startOfGesture = true
    
    var beganHideMenu = false
    @objc func handlePan(recognizer: UISwipeGestureRecognizer) {
        let currentPoint = recognizer.location(in: self)
        if recognizer.state == .ended
        {
            startOfGesture = true
            beganHideMenu = false
            beganShowMenu = false
        }
        else
        {
            if recognizer.state == .began && startOfGesture && menu!.frame.contains(currentPoint)
            {
                beganHideMenu = true
                beganPoint = currentPoint
            }
            if startOfGesture
            {
                beganShowMenu = false
                beganPoint = currentPoint
                if abs(self.frame.width - beganPoint.x) < 70
                {
                    beganShowMenu = true
                }
                startOfGesture = false
            }
            else
            {
                let xDifs = abs(beganPoint.x - currentPoint.x)
                let yDifs = abs(beganPoint.y - currentPoint.y)
                if xDifs > yDifs
                {
                    if menu?.isHidden == true && beganShowMenu && (beganPoint.x - currentPoint.x) > 30
                    {
                        showMenu(menuType: .mainMenu)
                    }
                    if menu?.isHidden == false && beganHideMenu && (beganPoint.x - currentPoint.x) < 40
                    {
                        hideMenu()
                    }
                }
            }
        }
    }
    
    @objc func handleLongPress(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .began
        {
            isCrossHairAvailable = true
        }
        else if recognizer.state == .ended
        {
            isCrossHairAvailable = false
        }
        lastCursorPosition = recognizer.location(in: self)
        cursorLayer.setNeedsDisplay()
    }
    
    override func layoutChart() {
        super.layoutChart()
        priceScaleLayer.frame = self.bounds
        toolsLayer.frame = self.bounds
    }
    
    override func redrawAll() {
        redrawBuffer(forceRedrawPriceScale:true, forceRedrawToolsLayer: true)
    }
    
    func redrawBuffer(forceRedrawPriceScale:Bool = false, forceRedrawToolsLayer:Bool = false)
    {
        super.redrawAll()

        redrawToolsLayer(forceRedraw: forceRedrawToolsLayer)
        
        if needRedrawPriceScale() || forceRedrawPriceScale
        {
            self.priceScaleLayer.setNeedsDisplay()
        }
    }
    
    func redrawToolsLayer(forceRedraw:Bool = false)
    {
        guard let windows = windowContainer?.windows else {return}
        let hasTools = false
        var hasTradingTools = false
        
        let hasCurrentTool = false
        for window in windows
        {
//            if (window.toolsRenderer?.tools.count ?? 0) > 0
//            {
//                hasTools = true
//                break
//            }
            if (window.tradingToolRenderer?.tradingTools.count ?? 0) > 0
            {
                hasTradingTools = true
                break
            }
//            if window.newToolRenderer?.newToolStrategy.currentTool != nil
//            {
//                hasCurrentTool = true
//                break
//            }
        }
        
        if forceRedraw || hasCurrentTool || hasTools || hasTradingTools
        {
            calculateMinMax()
            self.toolsLayer.setNeedsDisplay()
        }
    }
    
    func needRedrawPriceScale() -> Bool
    {
        return windowContainer?.needRedrawPriceScale() ?? false
    }
    
    func initMainWindow()
    {
        let priceScaleRenderer = PriceScaleRenderer(chartBase:self);
        
        //mainWindow
        self.mainWindow = ChartWindow(chart: self, priceScaleRenderer:priceScaleRenderer)
        self.mainWindow!.isMainWindow = true;
        self.mainWindow!.pointConverter = CashItemSeriesPointConverter(window: mainWindow!, series: nil);
        priceScaleRenderer.window = self.mainWindow;
        //        leftPriceScaleRenderer.mainWindow = self.mainWindow;
        
        self.mainPriceRenderer = MainPriceRenderer(chartBase: self);
        //PreviewRenderer
        
        self.windowContainer = WindowContainer(chart: self);
        //AfterResizeWindows +
        windowContainer!.rectangle = CGRect(x: 0, y: 0, width: 100, height: 100);//?
        windowContainer!.windows.append(mainWindow!);
        
        //Добавление рендереров в правильном порядке (некоторые кладем 2 раза до и после мэйнпрайс рендерера)
        //overlayStorageRenderer
        
        self.mainWindow!.indicatorStorageRenderer = IndicatorStorageRenderer(chartBase:self, mainWindow: true);
        self.mainWindow?.renderers.append(self.mainWindow!.indicatorStorageRenderer!)
        
        self.mainWindow?.headerRenderer = ProHeaderRenderer(chartBase: self)
        
        self.mainWindow?.cursorRenderers.append(self.mainWindow!.headerRenderer!)
        
        
        //CustomDrawingRenderer 1
        let volumeBarsRenderer = VolumeBarsRenderer(chartBase: self)
        self.mainWindow?.renderers.append(volumeBarsRenderer)
      
        mainWindow!.renderers.append(self.mainPriceRenderer!);
 
        
//        mainWindow?.renderers.append(self.mainWindow!.indicatorStorageRenderer!)
        tradingToolRenderer = TradingToolsRenderer(chartBase: self)
        mainWindow?.tradingToolRenderer = tradingToolRenderer
        mainWindow?.tradingToolRenderer?.populateTools()
  
//        indicativeLinesRenderer = TerceraChartIndicativeLinesRenderer(chart: self)
//        mainWindow?.renderers.append(indicativeLinesRenderer!)
       
        let spreadRenderer = SpreadRenderer(chartBase: self)
        mainWindow?.renderers.append(spreadRenderer)
        
  
        self.mainWindow!.windowContainer = self.windowContainer
        
        
        //SelectedToolsListChanged
    
    }
    
    func generateTimeFrameInfo()
    {
        guard let symbolID = symbolID else {
            self.timeFrameInfo = nil
            return
        }
        guard let symbol = Session.sharedSession.dataCache.symbolsDictionary[self.symbolID!] else{
            self.timeFrameInfo = nil
            return
        }
        guard  let account = Session.sharedSession.dataCache.accountsDictionary[accountID] else {
            self.timeFrameInfo = nil
            return
        }
        let tfi = TimeFrameInfo(tfPeriod: aggregationType.period, hType: symbol.getInstrument().chartBarType, spreadPlanID: account.accountID)
        tfi.symbolId = symbolID
        self.timeFrameInfo = tfi
    }
    
    func getHistoryParams() -> ReloadHistoryParams?
    {
        if self.timeFrameInfo == nil
        {
            return nil
        }
        let historyParams = ReloadHistoryParams();
        historyParams.accountId = self.accountID
        historyParams.symbolID = self.symbolID
        historyParams.timeFrameInfo = self.timeFrameInfo?.clone();
    
        historyParams.useDefaultInstrumentHistoryType = true
        
        let periods = RequestTimeHolder.getTimesByPeriod(timeFrameInfo?.period ?? Periods.MIN)
        historyParams.fromTime = periods.fromDate;
        historyParams.toTime = periods.toDate;
        
        //Корректируем date-интервал, проверяем чтобы были корректные даты
        //Utils.ProcessDateInterval
        //        ReloadHistoryParams.processDateInterval(&historyParams.fromTime, &historyParams.toTime, self.instrument?.instrument.name, mainCashItemSeries?.cashItem, nil, false, false);
        
        return historyParams;
    }
    

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        paddingHistoryStrategy?.endOfScrolling()
    }
    
    
    var setContentOffset = false
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if !setContentOffset 
        {
            if let count = mainPriceRenderer?.series?.count
            {
                let i1 = scrollView.contentOffset.x * CGFloat(count + barsToRight_Bars - 1) / (scrollView.contentSize.width - scrollView.frame.width)
                self.checkAndSetI1(Double(i1), allowAddNewBars: true, isScrollView: true)
                self.redrawBuffer()
            }
        }
    }
    func setContentSize()
    {
        if let xScale = mainWindow?.xScale, let seriesCount = mainPriceRenderer?.series?.count
        {
            scrollView.contentSize = CGSize(width: Double(seriesCount + barsToRight_Bars - 1) * xScale, height: 1)
        }
    }
    
    func setPositionOfScroll()
    {
        setContentOffset = true
        if let i1 = mainWindow?.i1, let xScale = mainWindow?.xScale
        {
            let offset = CGFloat(i1) * CGFloat(xScale) - self.frame.width
            if offset >= 0
            {
                self.scrollView.contentOffset = CGPoint(x: offset, y: 0)
            }
        }
        setContentOffset = false
    }
    
    @discardableResult
    fileprivate func replaceCashItem(_ newCashItem : CashItem) -> LoadingHistoryMode
    {
        var result = LoadingHistoryMode.finish;
        
        let oldSeries : TerceraChartCashItemSeries? = self.mainPriceRenderer?.series
        
        let cashItemSeries =  TerceraChartCashItemSeries(chart: self, newCashItem: newCashItem, fromDate: historyFrom, toDate: historyTo, seriesSetting: self.cashItemSeriesSettings!);
        
        
        //Идет процесс подгрузки истории. Если данных не достаточно, чтобы заполнить участок, выбранный юзером, начинаем качать следующий.
        //Текущие данные не применяем
        if(self.paddingHistoryStrategy != nil && paddingHistoryStrategy!.availableDragging)
        {
            result = self.paddingHistoryStrategy!.checkResults(cashItemSeries);
        }
//        // Выставляем положение скроллера
//        if let xScale = mainWindow?.xScale
//        {
//            self.scrollView.contentSize = CGSize(width: Double(cashItemSeries.count) * xScale, height: 1)
//        }
        
        
        //Антиморгание, пока закешируются новые данные, будем использовать старые
        var difference = 0
        
        if oldSeries != nil && oldSeries!.count < cashItemSeries.count
        {
            difference = cashItemSeries.count - oldSeries!.count
        }
        mainWindow!.i1 = mainWindow!.i1 + difference
        
        mainPriceRenderer?.series = cashItemSeries;

        self.windowContainer?.timeScaleRenderer.series = cashItemSeries;
        for indicatorRenderer in indicatorRenderers
        {
            indicatorRenderer.series = cashItemSeries
        }
        
        for window in self.windowContainer!.windows
        {
            window.pointConverter = CashItemSeriesPointConverter(window: window, series: cashItemSeries);
        }
        
        
        if(oldSeries != nil)
        {
            oldSeries?.finalize();
        }
//        setPositionOfScroll()
        return result;
    }
    
    func calculateBarToRight_Bars(_ barsPercent : Double) -> Int
    {
        return mainWindow != nil && mainWindow!.xScale != 0 ? Int(round(Double(mainWindow!.clientRectangle.width) / mainWindow!.xScale * barsPercent / 100)) : 0;
    }
    
    static func correctI1(_ window : ChartWindow, series : TerceraChartCashItemSeries, barsToRight : Int)
    {
        let maxI1Value = series.count - 1 + barsToRight;
        if(window.i1 > maxI1Value)
        {
            window.i1 = maxI1Value;
        }
        if(Double(window.i1) < window.im)
        {
            window.i1 = Int(window.im) - 1;
        }
        
        if(window.stickToEnd)
        {
            window.i1 = maxI1Value;
        }
    }
    
    private func getCashItem(_ symbolId: PFSymbolId, timeFrame: TimeFrameInfo, chartId: Int64) -> CashItem? {
        
        timeFrame.symbolId = symbolId
        timeFrame.chartId = Int(chartId)
        
        let cashItem = BaseAggregationCashItem.getAggregationCashItem(timeFrameInfo: timeFrame, symbolID: symbolId)//CashItem(timeFrameInfo: timeFrame);
        
        return cashItem;
    }
    
    open func refreshChart(_ reload : Bool = false)
    {
        if(self.timeFrameInfo == nil)
        {
            Swift.print("Try load chart on unknown time frame");
            DispatchQueue.main.async(execute: { [weak self] in
                self?.setNoDataAvailable()
            })
            return;
        }
        
        if(self.symbol != nil)
        {
            if(Session.sharedSession.sessionStatus != SessionStatus.ready)
            {
                return;
            }
            
            //Выключаем слежение за евентами кешитема для основной серии
            //чтобы избежать лишних пересчетов
            self.mainPriceRenderer?.series?.disableCashItemEvents()
            
            self.startLoading()
            
            //1. Определяем параметры запроса истории
            let historyParams = getHistoryParams();
            self.historyFrom = historyParams!.fromTime
            self.historyTo = historyParams!.toTime
            if historyParams == nil || account == nil
            {
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.setNoDataAvailable()
                })
                return
            }
            
            historyParams!.forceReload = reload;
      
            //2. Запрашиваем историю
            // let cashItem = quoteListenerController.getDataNew(symbol!.symbolID, historyParams: historyParams!, listener: self);
            self.cashItem = getCashItem(symbol!.symbolID, timeFrame: (historyParams?.timeFrameInfo!.clone())!, chartId: -1)!;
//            for indicatorRenderer in indicatorRenderers
//            {
//                if indicatorRenderer.indicator.dataSource == nil
//                {
//                    indicatorRenderer.indicator.setupDataSource(cashItem: cashItem)
//                }
//                indicatorRenderer.indicator.dataSource?.changeCashItem(cashItem: cashItem)
//            }
//
//            if cashItem != self.mainCashItemSeries?.cashItem
//            {
//                self.mainCashItemSeries?.cashItem?.removeDelegate(self)
//                self.paddingHistoryStrategy?.refresh()
//            }
//
            self.cashItem?.addDelegate(self)
            self.cashItem?.reload(historyParams!);
        }
        
    }
    
    var isRightOffSet : Bool
    {
        get
        {
            if(self.mainCashItemSeries == nil)
            {
                return true;
            }
            
            return mainWindow!.i1 > (mainCashItemSeries!.count - 1 + self.calculateBarToRight_Bars(ProChart.DEFAULT_BARSTORIGHT_PERCENT));
        }
    }
    
    var isAtTheBegin : Bool
    {
        get
        {
            if(mainCashItemSeries == nil)
            {
                return true;
            }
            
            return mainWindow!.i1 == (mainCashItemSeries!.count - 1 + self.calculateBarToRight_Bars(ProChart.DEFAULT_BARSTORIGHT_PERCENT)) && self.barsToRight_Percent == ProChart.DEFAULT_BARSTORIGHT_PERCENT;
        }
    }
    
    func toBegin()
    {
        if(mainCashItemSeries == nil)
        {
            return;
        }
        
        //reset BarsToRight
        barsToRight_Percent = ProChart.DEFAULT_BARSTORIGHT_PERCENT;
        
        self.checkAndSetI1(Double(self.mainCashItemSeries!.count - 1 + barsToRight_Bars));
        
        self.redrawBuffer();
    }
    
    @discardableResult
    func checkAndSetI1(_ i1 : Double, allowChangeBarsToRight : Bool = false, window : ChartWindow? = nil, series : TerceraChartCashItemSeries? = nil, allowAddNewBars :  Bool = false, isScrollView:Bool = false) -> Bool
    {
        let chartWindow : ChartWindow = (window ?? mainWindow)!;
        let mainSeries : TerceraChartCashItemSeries? = (series ?? self.mainCashItemSeries);
        
        if(mainSeries == nil)
        {
            return false;
        }
        
        var newI1 = i1;
        
        //При тягании чарта влево будет включаться механизм докачки истории
        if(allowAddNewBars && Double(newI1) < chartWindow.im)// && paddingHistoryStrategy != nil)
        {
            paddingHistoryStrategy?.processDraggingLeft(newI1: newI1);
        }
        
        //Пытаемся установить праую границу в будущее - разрешаем, только если allowChangeBarsToRight
        if(newI1 > Double(mainSeries!.count - 1 + self.barsToRight_Bars) && allowAddNewBars)
        {
            //Calculate BarRoRightPercent
            let newBarToRightPercent : Double = (newI1 - Double(mainSeries!.count - 1)) / chartWindow.im * 100;
            if(newBarToRightPercent > 5)
            {
                //Limit newBarsPercent to 90%
                barsToRight_Percent = 5;
                newI1 = Double(mainSeries!.count - 1 + barsToRight_Bars);
            }
            else
            {
                barsToRight_Percent = newBarToRightPercent;
            }
        }
        else
        {
            if(newI1 > Double(mainSeries!.count - 1 + barsToRight_Bars))
            {
                newI1 = Double(mainSeries!.count - 1 + barsToRight_Bars);
            }
        }
        
        if(newI1 < chartWindow.im && Double(mainSeries!.count - 1 + barsToRight_Bars) > chartWindow.im)
        {
            newI1 = chartWindow.im - 1;
        }
        
        //Total history count less then im. i1 should be sticked to right side
        if(Double(mainSeries!.count - 1 + barsToRight_Bars) < chartWindow.im)
        {
            newI1 = Double(mainSeries!.count - 1 + barsToRight_Bars);
        }
        
        if(Double(chartWindow.i1) != newI1)
        {
            chartWindow.stickToEnd = newI1 == Double(mainSeries!.count - 1 + barsToRight_Bars);
            chartWindow.i1 = Int(newI1);
            if isScrollView == false
            {
                setPositionOfScroll()
            }
            return true;
        }
        else
        {      
            return false;
        }
        
    }
    
    func drawMainLayer(_ layer: CALayer, in ctx: CGContext) {
        
        if(self.mainPriceRenderer == nil)
        {
            return;
        }
        let mainPriceRend = self.mainPriceRenderer!;
        
        
        if let mainCashItemSeries = mainPriceRend.series
        {
            //calculate barsToRight
            self.barsToRight_Bars = self.calculateBarToRight_Bars(self.barsToRight_Percent);
            
            //Check i1
            ProChart.correctI1(self.mainWindow!, series: mainCashItemSeries, barsToRight: self.barsToRight_Bars);
            
            //Synhronize i1, XScale between windows
//            for window in self.windowContainer!.windows
//            {
//                
//                window.i1 = self.mainWindow!.i1;
//                window.xScale = self.mainWindow!.xScale;
//            }
            
            //баг с автомасштабом учитывается 1 бар за экраном
            let firstBarOnTheScreenIndex = self.mainWindow!.i1 - Int(mainWindow!.im) + 1;
            
            if(firstBarOnTheScreenIndex > self.mainWindow!.i1)
            {
                return;
            }
            
            // Cache cashItem data to array for quick acces
            mainCashItemSeries.cacheScreenData(firstBarOnTheScreenIndex, end: self.mainWindow!.i1, ins: self.symbol);
            
            //Overlays
        }
        //Set correct min/max for windows
        calculateMinMax();
        
        windowContainer?.draw(layer, in: ctx)
    }
    
    func calculateMinMax() {
        windowContainer?.calculateMinMax()
    }
    
    override func resizeView() {
        super.resizeView()
        self.layoutWindowContainers()
    }
    
    func layoutWindowContainers() {
        windowContainer?.rectangle.size = self.frame.size
        windowContainer?.layoutWindows()
        
    }
    
    override func processTap(recognizer: UITapGestureRecognizer, coordinate: CGPoint) {
        
        for renderer in mainWindow!.getAllRenderers {
            if renderer.processTap(recognizer: recognizer, coordinate: coordinate) {
                self.redrawAll()
                break
            }
        }
    }
}
