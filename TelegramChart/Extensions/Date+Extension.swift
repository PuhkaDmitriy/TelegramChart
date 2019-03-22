//
//  Date+Extension.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/13/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation

extension Date {
    
    func simpleChartFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: self)
    }

    func infoViewDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "MMM dd \n yyyy"
        return formatter.string(from: self)
    }
    
}
