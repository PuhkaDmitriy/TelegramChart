//
//  MainViewPresenter.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

final class ChrtViewPresenter {
    
    // MARK: - propertyes
    
    private weak var controller: ChartViewController!
    private var chartBuilder: ChartBuilder?

    init(controller: ChartViewController) {
        self.controller = controller
    }
    
    // MARK: - chart
    //
    func loadChartData() {
        chartBuilder = ChartBuilder(parentView: controller.chartView, chartLines: getChartLines())
        
        // add chart subview
        guard let chartView = chartBuilder?.chartView?.view else {return}
        controller.chartView.addSubview(chartView)
    }
    
    func getChartLines() -> [LineChart.ChartLine] {
        var lines = [LineChart.ChartLine]()
        
        let lineJoned = LineChart.ChartLine(chartPoints: [(1, 11.6), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1), (2, 15.1)], color: UIColor.green)
        
        let lineLeft = LineChart.ChartLine(chartPoints: [(2, 5.6), (3, 6.1), (4, 7.1), (5, 8.1), (6, 9.1), (7, 10.1), (8, 11.1), (2, 12.1), (2, 13.1), (2, 14.1), (2, 15.1), (2, 15.1)], color: UIColor.red)
        
        lines.append(lineJoned)
        lines.append(lineLeft)
        
        return lines
    }
    
    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}
