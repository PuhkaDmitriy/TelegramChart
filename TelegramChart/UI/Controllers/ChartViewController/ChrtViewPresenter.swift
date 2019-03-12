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
    private var chartBuilder: ChartBuilder?

    init(controller: ChartViewController) {
        self.controller = controller
    }

    // MARK: - chart
    //
    func loadChartData() {


        // TODO - удалить
        JSONParser(fileName: Constants.JSONFileName, fileExtension: Constants.JSONExtension).parse()
        // TODO - удалить



        chartBuilder = ChartBuilder(frame: CGRect(x: 0, y: 0, width: controller.chartView.frame.width, height: controller.chartView.frame.height), chartLines: getChartLines())

        // add chart subview
        guard let chartView = chartBuilder?.chartView?.view else {return}
        controller.chartView.addSubview(chartView)
    }

    func getChartLines() -> [LineChart.ChartLine] {
        var lines = [LineChart.ChartLine]()

        let lineJoined = LineChart.ChartLine(chartPoints: [
            (0, 30),
            (1, 40),
            (2, 55),
            (3, 49),
            (4, 175),
            (5, 70),
            (6, 90),
            (7, 200),
            (8, 250),
            (9, 260),
            (10, 130),
            (11, 120),
            (12, 90),
            (13, 80),
            (14, 70),
            (15, 70)
        ], color: UIColor.green)

        let lineLeft = LineChart.ChartLine(chartPoints: [
            (0, 40),
            (1, 36),
            (2, 49),
            (3, 55),
            (4, 60),
            (5, 61),
            (6, 55),
            (7, 30),
            (8, 45),
            (9, 55),
            (10, 55),
            (11, 50),
            (12, 49),
            (13, 60),
            (14, 55),
            (15, 30)
        ], color: UIColor.red)

        lines.append(lineJoined)
        lines.append(lineLeft)

        return lines
    }

    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}
