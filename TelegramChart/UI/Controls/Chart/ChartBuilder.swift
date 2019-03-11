//
//  ChartBuilder.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

final class ChartBuilder {
    
    // MARK: - propertyes
    
    private var parentView: UIView
    private var chartLines = [LineChart.ChartLine]()
    private var xTitle = ""
    private var yTitle = ""
    
    var chartView: LineChart?
    
    // MARK: - life cycle
    
    init(parentView: UIView,
         chartLines: [LineChart.ChartLine],
         xTitle: String = "",
         yTitle: String = "") {
        self.parentView = parentView
        self.chartLines = chartLines
        self.xTitle = xTitle
        self.yTitle = yTitle
    }
    
    func displayChart() {
        let chartConfig = ChartConfigXY(xAxisConfig: ChartAxisConfig(from: 1, to: 12, by: 1),
                                        yAxisConfig: ChartAxisConfig(from: 0, to: 100, by: 10))
        
        chartView = LineChart(frame: parentView.frame,
                                  chartConfig: chartConfig,
                                  xTitle: xTitle,
                                  yTitle: yTitle,
                                  lines: self.chartLines)
    }
}
