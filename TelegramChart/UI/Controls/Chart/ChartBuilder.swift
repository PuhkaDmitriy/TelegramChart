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

    private var frame: CGRect
    private var chartLines = [LineChart.ChartLine]()
    private var xTitle = ""
    private var yTitle = ""

    var chartView: LineChart?

    // MARK: - life cycle

    init(frame: CGRect,
         chartLines: [LineChart.ChartLine],
         xTitle: String = "",
         yTitle: String = "") {
        self.frame = frame
        self.chartLines = chartLines
        self.xTitle = xTitle
        self.yTitle = yTitle

        setupChart()
    }

    func setupChart() {

        // axis
        let xAxis = ChartAxisConfig(from: 1, to: 20, by: 1)
        let yAxis = ChartAxisConfig(from: 0, to: 250, by: 50)

        // guidelines
        let guidelines = GuidelinesConfig(dotted: false, lineWidth: 0.5, lineColor: Constants.chartGuidelineColor ?? .black)

        let chartConfig = ChartConfigXY(xAxisConfig: xAxis, yAxisConfig: yAxis, guidelinesConfig: guidelines)

        chartView = LineChart(frame: frame,
                chartConfig: chartConfig,
                xTitle: xTitle,
                yTitle: yTitle,
                lines: self.chartLines,
                xAxisColor: Constants.chartGuidelineColor ?? .black,
                yAxisColor: .clear)
    }
}
