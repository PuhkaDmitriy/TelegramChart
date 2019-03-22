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

    public var themeControls = [ThemeProtocol]()
    private weak var controller: ChartViewController!
    private var simpleChart: Chart?

    var charts = [ChartDataSource]()
    var currentChart: ChartDataSource?

    init(controller: ChartViewController) {
        self.controller = controller
    }

    // MARK: - chart
    //
    func loadChartData() {
        JSONParser(fileName: Constants.JSONFileName, fileExtension: Constants.JSONExtension).parse(withCompletion: {[weak self] charts in

            self?.charts = charts

            self?.currentChart = charts.first // TODO - Сделать возможным переключение

            self?.setupContent()
            self?.addSimpleChartToRangeSelector()
        })
    }

    func setupContent() {

        themeControls = [ controller.followersLabel,
                          controller.mainContainer,
                          controller.chartContainer,
                          controller.joinedChannelView,
                          controller.dividerView,
                          controller.leftChannelView,
                          controller.themeSwitchButton,
                          controller.rangeSelector,
                          controller.mainChart,
                          controller.infoView ]

        if let selfView = controller.view as? TView {
            themeControls.append(selfView)
        }

        // labels
        controller.navigationItem.title = NSLocalizedString("mainScreen.title.statistics", comment: "")
        controller.followersLabel.text = NSLocalizedString("mainScreen.label.followers", comment: "")
        controller.themeSwitchButton.setTitle(getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)



        let y0Lines = currentChart?.lines.filter({$0.name == Constants.y0}).first
        let y1Lines = currentChart?.lines.filter({$0.name == Constants.y1}).first

        // line buttons
        // joined
        controller.joinedChannelView.setupWith(y0Lines?.nameForShow ?? "", y0Lines?.color ?? .black, {[weak self] isVisible in
            self?.simpleChart?.needShowYLayer(lineIndex: 1, needShow: isVisible)
            self?.controller.mainChart.needShowYLayer(lineIndex: 1, needShow: isVisible)
        })

        // left
        controller.leftChannelView.setupWith(y1Lines?.nameForShow ?? "", y1Lines?.color ?? .black, {[weak self] isVisible in
            self?.simpleChart?.needShowYLayer(lineIndex: 2, needShow: isVisible)
            self?.controller.mainChart.needShowYLayer(lineIndex: 2, needShow: isVisible)
        })

        // info view
        controller.infoView.setColors(y0Lines?.color ?? .white, y1Lines?.color ?? .white)
    }

    func getSwitchThemeButtonTitle(_ theme: Theme) -> String {
        switch theme {
        case .day:
            return NSLocalizedString("mainScreen.label.themeSwitchButton.night", comment: "")
        case .night:
            return NSLocalizedString("mainScreen.label.themeSwitchButton.day", comment: "")
        }
    }

    func addSimpleChartToRangeSelector() {

        self.simpleChart = Chart(frame:
        CGRect(x: 0.0,
                y: 0.0,
                width: controller.rangeSelector.bounds.size.width,
                height: controller.rangeSelector.bounds.size.height))

        guard let chartData = currentChart,
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

        simpleChart.area = false
        simpleChart.lineWidth = 0.7


        simpleChart.x.labels = Chart.Labels(visible: false, visibleCount: 0, textColor: .clear, values: [String]())
        simpleChart.y.labels = Chart.Labels(visible: false, visibleCount: 0, textColor: .clear, values: [String]())

        simpleChart.x.grid = Chart.Grid(visible: false, count: 1, color: .clear)
        simpleChart.y.grid = Chart.Grid(visible: false, count: 1, color: .clear)

        simpleChart.x.axis = Chart.Axis(visible: false, color: .clear, inset: 0)
        simpleChart.y.axis = Chart.Axis(visible: false, color: .clear, inset: 10)

        simpleChart.addLine(xAxis)
        simpleChart.addLine(y0Axis)
        simpleChart.addLine(y1Axis)

        simpleChart.colors.append(xColor)
        simpleChart.colors.append(y0Color)
        simpleChart.colors.append(y1Color)

        simpleChart.translatesAutoresizingMaskIntoConstraints = false
        simpleChart.dots.visible = false

        simpleChart.delegate = self

        // insert simple chart
        simpleChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        simpleChart.isUserInteractionEnabled = false

        controller.rangeSelector.insertSubview(simpleChart, at: 0)
        controller.rangeSelector.delegate = self
    }

    func buildMainChart(_ range: Range<Int>? = nil) {
        guard let chartData = currentChart,
              let mainChart = controller.mainChart else { return }

        // если чарт уже построен, просто обновляем range
        if let _ = mainChart.rangeToShow {
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

        var xLabels = [String]()

        chartData.lines.forEach {
            if ($0.name == Constants.x) {
                xAxis.append(contentsOf: $0.data)

                // set title labels
                xLabels = $0.data.map { (timestamp) -> String in
                    return Date(timeIntervalSince1970: Double(timestamp / 1000)).simpleChartFormat()
                }

            } else if ($0.name == Constants.y0) {
                y0Axis.append(contentsOf: $0.data)
                y0Color = $0.color
            } else if ($0.name == Constants.y1) {
                y1Axis.append(contentsOf: $0.data)
                y1Color = $0.color
            }
        }

        let gridAndLabelsCount = 6

        mainChart.area = false
        mainChart.lineWidth = 2.0

        // grid
        mainChart.x.grid = Chart.Grid(visible: true, count: 1, color: .clear)
        mainChart.y.grid = Chart.Grid(visible: true, count: CGFloat(gridAndLabelsCount), color: Constants.chartGridColor)

        // labels
        mainChart.x.labels = Chart.Labels(visible: true, visibleCount: gridAndLabelsCount, textColor: Constants.chartAxisLabelColor, values: xLabels)
        mainChart.y.labels = Chart.Labels(visible: true, visibleCount: gridAndLabelsCount, textColor: Constants.chartAxisLabelColor, values: [String]())

        mainChart.x.axis = Chart.Axis(visible: true, color: Constants.chartAxisColor, inset: 0.0)
        mainChart.y.axis = Chart.Axis(visible: false, color: Constants.chartAxisColor, inset: 10)

        mainChart.addLine(xAxis)
        mainChart.addLine(y0Axis)
        mainChart.addLine(y1Axis)

        mainChart.colors.append(xColor)
        mainChart.colors.append(y0Color)
        mainChart.colors.append(y1Color)

        mainChart.translatesAutoresizingMaskIntoConstraints = false
        mainChart.delegate = self

        mainChart.dots.visible = true
        mainChart.dots.colorDay = Constants.dayNavigationBarColor
        mainChart.dots.colorNight = Constants.nightNavigationBarColor
    }

    // Chart cursor info
    //
    func showInfo(_ xIndex: Int,
                  _ yValues: [String],
                  _ needShow: Bool) {

        guard let xValues = self.currentChart?.lines.filter( { $0.name == Constants.x } ).first?.data,
              !xValues.isEmpty else { return }

        var index = (controller.mainChart.rangeToShow?.lowerBound ?? 0) + xIndex

        // check range
        if (index < 0) { index = 0 }
        if (index > xValues.count - 1) {index = xValues.count - 1}
        let xValue = Date(timeIntervalSince1970: Double(xValues[index] / 1000)).infoViewDateFormat()

        //print("x: " + xValue + "y: \(yValues)")

        // set value
        controller.infoView.setValues(xValue, yValues.first ?? "-", yValues.last ?? "-")

        // show info view
        if needShow {
            if controller.infoView.isHidden {
                self.controller.infoView.isHidden = false
            }
        } else {
            if !controller.infoView.isHidden {
                self.controller.infoView.isHidden = true
            }
        }
    }

    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}

extension ChartViewPresenter: RangeSelectorProtocol {

    func didSelectPointsRange(_ pointsRange: Range<CGFloat>) {
//        print("pointsRange: ")
//        print(pointsRange)
        guard let indexesRange = simpleChart?.getIndexesRangeByPoints(pointsRange) else { return }
        buildMainChart(indexesRange)
    }

}

extension ChartViewPresenter: LineChartDelegate {

    func didSelectDataPoint(_ chart: Chart, _ x: CGFloat, yValues: [CGFloat], _ needShow: Bool) {
        if (chart == controller.mainChart) {
            var stringYValues = [String]()
            yValues.forEach {
                stringYValues.append( $0 < 0 ? "-" : String(Int($0)) ) // значение -1 приходит в случае если линия скрыта
            }
            showInfo(Int(x), stringYValues, needShow)
        }
    }

    func drawIsFinished(_ chart: Chart) {
        if (chart == simpleChart) {
            self.controller.rangeSelector.didChangeRange()
        }
    }

}
