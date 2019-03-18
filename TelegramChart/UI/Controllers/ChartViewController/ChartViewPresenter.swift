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

        let xAxis: [CGFloat] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112]
        let yAxis: [CGFloat] = [6706,7579,7798,8307,7866, 7736,7816,7630,7536,7105,7178,7619,7917,7483,5772,5700,5435,4837,4716,4890,4753,4820,4538,12162,39444,25765,18012,14421,13249,11310,10377,9399,8917,8259,7902,9442,47596,36160,23866,18500,15488,13722,12270,13413,10574,7092,7159,7880,8821,8306,7780,7963,7837,7611,7334,7413,7015,6742,6557,6593,6680,6725,6345,5988,6365,9911,28833,19694,14873,11911,10498,9708,8893,8365,7960,7694,45529,42858,31508,23289,19147,15874,14551,13124,11778,10809,10522,9918,9436,8617,8765,8194,8035,7865,7573,7422,7047,7147,6861,6669,6363,12073,32381,21390,15311,12819,11655,10696,9678,9143,8296,7852]
        let yAxis2: [CGFloat] = [3522,4088,4146,4477,4202,4157,4177,4203,4223,3948,3946,3898,3979,4052,3279,3229,3302,3040,3054,2982,3077,2965,2973,5148,22485,13077,9055,7446,6824,5995,5787,5367,4997,4689,4630,4785,22365,15244,10626,8666,7681,6929,6219,6367,5402,4932,4844,5146,5265,4887,4714,4722,4718,4693,4746,4819,4455,4419,4323,4407,4277,11589,6100,5076,4769,8929,14002,9756,7520,6343,5633,5415,5052,4850,4624,4480,14102,24005,14263,10845,9028,7755,7197,7001,6737,6254,6150,5922,5603,5048,5423,5003,5035,4747,4814,4661,4462,4516,4221,4111,4053,12515,15781,10499,8175,6831,6287,5990,5590,5148,4760,4809]




        let xColor = UIColor.clear
        let y0Color = "#3DC23F".hexToColor()
        let y1Color = "#F34C44".hexToColor()

        let xLabels = [String]()
        let yLabels = [String]()

        // simple line with custom x axis labels
        //        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

        lineChart.animation.enabled = false // animate line drawing
        lineChart.area = false

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

        lineChart.addLine(xAxis)
        lineChart.addLine(yAxis)
        lineChart.addLine(yAxis2)

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
         // TODO -
    }

    func setVisibleLeftChannel(_ isVisible: Bool) {
        // TODO -
    }

    // MARK: - theme
    //
    func changeTheme() {
        Settings.shared.setTheme(Settings.shared.currentTheme == .day ? .night : .day)
    }
}

extension ChartViewPresenter: LineChartDelegate {

    func didSelectDataPoint(_ chart: LineChart, _ x: CGFloat, yValues: [CGFloat]) {

    }

}
