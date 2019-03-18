//
//  ChartDataSourse.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/13/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

struct Line {

    var name = ""
    var data = [CGFloat]()
    var color = UIColor.black

}

final class ChartDataSource {

    var lines = [Line]()
    var xValues = [Date]()

    init(_ preparingData: PreparingChartData) {
        self.lines = buildLines(preparingData)
    }

    private func buildLines(_ preparingData: PreparingChartData) -> [Line] {

        guard let columns = preparingData.columns else {
            return [Line]()
        }

        // line points
        var lines = [Line]()

        let xColumn = columns.filter { $0.name == Constants.x }.first?.values ?? [Int]()
        let y0Column = columns.filter { $0.name == Constants.y0 }.first?.values ?? [Int]()
        let y1Column = columns.filter { $0.name == Constants.y1 }.first?.values ?? [Int]()

        if (!xColumn.isEmpty) {
            let xLine = Line(name: Constants.x,
                    data: xColumn.map({CGFloat($0)}),
                    color: .black)
            lines.append(xLine)
        }

        if (!y0Column.isEmpty) {
            let y0line = Line(name: Constants.y0,
                    data: y0Column.map({CGFloat($0)}),
                    color: preparingData.colors?.y0?.hexToColor() ?? .white)
            lines.append(y0line)
        }

        if (!y1Column.isEmpty) {
            let y1line = Line(name: Constants.y1,
                    data: y1Column.map({CGFloat($0)}),
                    color: preparingData.colors?.y1?.hexToColor() ?? .white)
            lines.append(y1line)
        }

        return lines
    }
}
