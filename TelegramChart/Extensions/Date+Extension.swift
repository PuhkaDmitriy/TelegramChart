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
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
    
}
