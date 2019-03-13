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
    static let dayNavigationBarColor: UIColor? = "#FEFEFE".hexToColor()
    static let nightNavigationBarColor: UIColor? = "222F3F".hexToColor()

    // chart
    static let chartGuidelineColor: UIColor? = "18222D".hexToColor()
    
    // JSON
    static let JSONFileName = "chart_data"
    static let JSONExtension = "json"
    static let x = "x"
    static let y0 = "y0"
    static let y1 = "y1"
}
