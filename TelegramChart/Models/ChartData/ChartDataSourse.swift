//
//  ChartDataSourse.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/13/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

final class ChartDataSource {

    var lines = [LineChart.ChartLine]()
    var xValues = [Date]()

    init(_ preparingData: PreparingChartData) {
        self.lines = buildLines(preparingData)
    }

    private func buildLines(_ preparingData: PreparingChartData) -> [LineChart.ChartLine] {

        guard let columns = preparingData.columns else {
            return [LineChart.ChartLine]()
        }

        // line points
        var lines = [LineChart.ChartLine]()

        let xColumn = columns.filter { $0.name == Constants.x }.first?.values ?? [Int]()
        let y0Column = columns.filter { $0.name == Constants.y0 }.first?.values ?? [Int]()
        let y1Column = columns.filter { $0.name == Constants.y1 }.first?.values ?? [Int]()

        var lineJoinedPoints = [(Double, Double)]()
        var lineLeftPoints = [(Double, Double)]()

        for (index, xValue) in xColumn.enumerated() {

            let date = Date(timeIntervalSince1970: Double(xValue / 1000))
            xValues.append(date)

            let x = Double(index)
            let y0 = Double(y0Column[index])
            let y1 = Double(y1Column[index])

            lineJoinedPoints.append((x, y0))
            lineLeftPoints.append((x, y1))
        }

        // line colors
        let joinedColor = preparingData.colors?.y0?.hexToColor() ?? .white
        let leftColor = preparingData.colors?.y1?.hexToColor() ?? .white


        lines.append(LineChart.ChartLine(chartPoints: lineJoinedPoints, color: joinedColor, name: ""))
        lines.append(LineChart.ChartLine(chartPoints: lineLeftPoints, color: leftColor, name: ""))

        return lines
    }
}