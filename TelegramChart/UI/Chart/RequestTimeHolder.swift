//
//  RequestTimeHolder.swift
//  Protrader 3
//
//  Created by Yuriy on 14/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class RequestTimeHolder: Any {

    
    static func getTimesByPeriod(_ period:Int) -> (fromDate:Int64, toDate:Int64)
    {
        let toDate = Date().msecondsTimeStamp()
        var fromDate:Int64 = 0
        let oneDay:Int64 = 24 * 60 * 60 * 1000
        let oneMonth:Int64 = oneDay * 30
        let oneYear = 365 * oneDay
        
        switch period {
        case Periods.MIN:
            fromDate = toDate - oneDay * 5
        case Periods.MIN5:
            fromDate = toDate - oneDay * 5
        case Periods.MIN15:
            fromDate = toDate - oneDay * 10
        case Periods.MIN30:
            fromDate = toDate - oneDay * 30
        case Periods.HOUR:
            fromDate = toDate - oneMonth
        case Periods.HOUR4:
            fromDate = toDate - oneMonth * 3
        case Periods.DAY:
            fromDate = toDate - oneMonth * 6
        case Periods.WEEK:
            fromDate = toDate - oneYear * 2
        case Periods.MONTH:
            fromDate = toDate - oneYear * 10
        case Periods.YEAR:
            fromDate = toDate - oneYear * 20
        default:
            fromDate = toDate - oneDay * 5
        }
        
        return (fromDate:fromDate, toDate:toDate + 60 * 60 * 1000)
    }
}
