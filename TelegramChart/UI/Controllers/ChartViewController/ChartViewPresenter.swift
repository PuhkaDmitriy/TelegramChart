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
    var charts = [ChartDataSource]()

    init(controller: ChartViewController) {
        self.controller = controller
    }

    // MARK: - chart
    //
    func loadChartData() {
        JSONParser(fileName: Constants.JSONFileName, fileExtension: Constants.JSONExtension).parse(withCompletion: {[weak self] charts in
            self?.charts = charts

            self?.buildRangeSelector()
        })
    }

    func buildRangeSelector() {
       
        guard let lineChart = controller.rangeSelectorChart,
              let chartData = self.charts.first else { return }

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

        lineChart.animation.enabled = false // animate line drawing
        lineChart.area = false
        lineChart.lineWidth = 0.6


        lineChart.x.labels.visible = false

        lineChart.x.grid.count = 1
        lineChart.y.grid.count = 1

        lineChart.x.grid.visible = false
        lineChart.y.grid.visible = false

        lineChart.x.labels.values = xLabels
        lineChart.y.labels.values = yLabels

        lineChart.x.labels.visible = false
        lineChart.y.labels.visible = false

        lineChart.x.axis.visible = false
        lineChart.y.axis.visible = false

        lineChart.x.axis.inset = 0
        lineChart.y.axis.inset = 10

        lineChart.addLine(xAxis)
        lineChart.addLine(y0Axis)
        lineChart.addLine(y1Axis)

        lineChart.colors.append(xColor)
        lineChart.colors.append(y0Color)
        lineChart.colors.append(y1Color)

        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self

        lineChart.dots.visible = false
    }

    // Input
    //
    func setVisibleJoinedChannel(_ isVisible: Bool) {
        controller.rangeSelectorChart.needShowYLayer(lineIndex: 1, needShow: isVisible)
    }

    func setVisibleLeftChannel(_ isVisible: Bool) {
        controller.rangeSelectorChart.needShowYLayer(lineIndex: 2, needShow: isVisible)
    }

    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}

extension ChartViewPresenter: LineChartDelegate {

    func didSelectDataPoint(_ chart: LineChart, _ x: CGFloat, yValues: [CGFloat]) {
        print("x: \(x)     y: \(yValues)")
    }

}
