//
//  Constants.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

final class Constants {

    // navigation bar
    static let dayNavigationBarColor: UIColor = "#FEFEFE".hexToColor()
    static let nightNavigationBarColor: UIColor = "222F3F".hexToColor()


    // chart
    static let chartGuidelineColor: UIColor? = "18222D".hexToColor()

    // chart.axis
    static let chartAxisLabelColor: UIColor = "8F969B".hexToColor()
    static let chartAxisColor: UIColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)

    // chart.grid
    static let chartGridColor = UIColor.lightGray

    // JSON
    static let JSONFileName = "chart_data"
    static let JSONExtension = "json"
    static let x = "x"
    static let y0 = "y0"
    static let y1 = "y1"
}
