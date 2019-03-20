//
//  MainViewPresenter.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

final class ChartViewPresenter {

    // MARK: - properties

    private weak var controller: ChartViewController!
    private var simpleChart: LineChart?
    var charts = [ChartDataSource]()

    init(controller: ChartViewController) {
        self.controller = controller
    }

    // MARK: - chart
    //
    func loadChartData() {
        JSONParser(fileName: Constants.JSONFileName, fileExtension: Constants.JSONExtension).parse(withCompletion: {[weak self] charts in
            self?.charts = charts
            self?.addSimpleChartToRangeSelector()
        })
    }

    func addSimpleChartToRangeSelector() {

        self.simpleChart = LineChart(frame:
        CGRect(x: 0.0,
                y: 0.0,
                width: controller.rangeSelector.bounds.size.width,
                height: controller.rangeSelector.bounds.size.height))

        guard let chartData = self.charts.first,
              let simpleChart = self.simpleChart else { return }

        var xAxis = [CGFloat]()
        var y0Axis = [CGFloat]()
        var y1Axis = [CGFloat]()

        let xColor: UIColor = .clear
        var y0Color: UIColor = .clear
        var y1Color: UIColor = .clear

        chartData.lines.forEach {
            if ($0.name == Constants.x) {
                xAxis.append(contentsOf: $0.data)
            } else if ($0.name == Constants.y0) {
                y0Axis.append(contentsOf: $0.data)
                y0Color = $0.color
            } else if ($0.name == Constants.y1) {
                y1Axis.append(contentsOf: $0.data)
                y1Color = $0.color
            }
        }

        let xLabels = [String]()
        let yLabels = [String]()

        // simple line with custom x axis labels // TODO - for example
        //        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

        simpleChart.animation.enabled = false // animate line drawing
        simpleChart.area = false
        simpleChart.lineWidth = 0.7


        simpleChart.x.labels.visible = false

        simpleChart.x.grid.count = 1
        simpleChart.y.grid.count = 1

        simpleChart.x.grid.visible = false
        simpleChart.y.grid.visible = false

        simpleChart.x.labels.values = xLabels
        simpleChart.y.labels.values = yLabels

        simpleChart.x.labels.visible = false
        simpleChart.y.labels.visible = false

        simpleChart.x.axis.visible = false
        simpleChart.y.axis.visible = false

        simpleChart.x.axis.inset = 0
        simpleChart.y.axis.inset = 10

        simpleChart.addLine(xAxis)
        simpleChart.addLine(y0Axis)
        simpleChart.addLine(y1Axis)

        simpleChart.colors.append(xColor)
        simpleChart.colors.append(y0Color)
        simpleChart.colors.append(y1Color)

        simpleChart.translatesAutoresizingMaskIntoConstraints = false
        simpleChart.delegate = self

        simpleChart.dots.visible = false

        // insert simple chart
        simpleChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        simpleChart.isUserInteractionEnabled = false

        controller.rangeSelector.insertSubview(simpleChart, at: 0)
        controller.rangeSelector.delegate = self
    }

    func buildMainChart(_ range: Range<Int>? = nil) {
        guard let chartData = self.charts.first,
              let mainChart = controller.mainChart else { return }

        // если чарт уже построен, просто обновляем range
        if let rangeToShow = mainChart.rangeToShow {
            mainChart.rangeToShow = range
            return
        }

        mainChart.rangeToShow = range

        var xAxis = [CGFloat]()
        var y0Axis = [CGFloat]()
        var y1Axis = [CGFloat]()

        let xColor: UIColor = .clear
        var y0Color: UIColor = .clear
        var y1Color: UIColor = .clear

        chartData.lines.forEach {
            if ($0.name == Constants.x) {
                xAxis.append(contentsOf: $0.data)
            } else if ($0.name == Constants.y0) {
                y0Axis.append(contentsOf: $0.data)
                y0Color = $0.color
            } else if ($0.name == Constants.y1) {
                y1Axis.append(contentsOf: $0.data)
                y1Color = $0.color
            }
        }

        let xLabels = [String]()
        let yLabels = [String]()

        // simple line with custom x axis labels // TODO - for example
        //        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

        mainChart.animation.enabled = false // animate line drawing
        mainChart.area = false
        mainChart.lineWidth = 2.0

        mainChart.x.labels.visible = false

        mainChart.x.grid.count = 1
        mainChart.y.grid.count = 1

        mainChart.x.grid.visible = false
        mainChart.y.grid.visible = false

        mainChart.x.labels.values = xLabels
        mainChart.y.labels.values = yLabels

        mainChart.x.labels.visible = false
        mainChart.y.labels.visible = false

        mainChart.x.axis.visible = false
        mainChart.y.axis.visible = false

        mainChart.x.axis.inset = 0
        mainChart.y.axis.inset = 10

        mainChart.addLine(xAxis)
        mainChart.addLine(y0Axis)
        mainChart.addLine(y1Axis)

        mainChart.colors.append(xColor)
        mainChart.colors.append(y0Color)
        mainChart.colors.append(y1Color)

        mainChart.translatesAutoresizingMaskIntoConstraints = false
        mainChart.delegate = self

        mainChart.dots.visible = false
    }

    // Input
    //
    func setVisibleJoinedChannel(_ isVisible: Bool) {
        simpleChart?.needShowYLayer(lineIndex: 1, needShow: isVisible)
        controller.mainChart.needShowYLayer(lineIndex: 1, needShow: isVisible)
    }

    func setVisibleLeftChannel(_ isVisible: Bool) {
        simpleChart?.needShowYLayer(lineIndex: 2, needShow: isVisible)
        controller.mainChart.needShowYLayer(lineIndex: 1, needShow: isVisible)
    }

    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}

extension ChartViewPresenter: RangeSelectorProtocol {

    func didSelectPointsRange(_ pointsRange: Range<CGFloat>) {
        print("pointsRange: ")
        print(pointsRange)
        guard let indexesRange = simpleChart?.getIndexesRangeByPoints(pointsRange) else { return }
        buildMainChart(indexesRange)
    }

}

extension ChartViewPresenter: LineChartDelegate {

    func didSelectDataPoint(_ chart: LineChart, _ x: CGFloat, yValues: [CGFloat]) {
        if (chart == controller.mainChart) {

            print("x: \(x)     y: \(yValues)")
        }
    }

    func drawIsFinished(_ chart: LineChart) {
        if (chart == simpleChart) {
            self.controller.rangeSelector.didChangeRange()
        }
    }

}
