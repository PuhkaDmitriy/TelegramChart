//
//  TimeHolder.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit


class TimeHolder{
    init(_ time:Int64) {
        self.time = time
    }
    
    
    private func fillTimes()
    {
        _dateTime = Date(msecondsTimeStamp: time)
        let dateComponents = Calendar.current.dateComponents([.year , .month , .day, .hour, .minute, .second, .weekday, .weekOfYear, .weekOfYear], from: _dateTime!)
        
        self._year = dateComponents.year!
        self._month = dateComponents.month!
        self._day = dateComponents.day!
        self._hour = dateComponents.hour!
        self._minute = dateComponents.minute!
        self._second = dateComponents.second!
        self._weakday = dateComponents.weekday!
        self._weekOfYear = dateComponents.weekOfYear!
    }
    
    private var _dateTime:Date?
    var dateTime:Date
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _dateTime!
        }
    }
    var time : Int64 = 0;
    
    private var _weakday : Int = 0
    var weakday : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _weakday
        }
    }
    
    private var _second = 0
    var second : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _second
        }
    }
    
    private var _minute = 0
    var minute : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _minute
        }
    }
    
    private var _hour = 0
    var hour : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _hour
        }
    }
    
    private var _day = 0
    var day : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _day
        }
    }
    
    private var _month = 0
    var month : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _month
        }
    }
    
    private var _year = 0
    var year : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _year
        }
    }
    
    private var _weekOfYear = 0
    var weekOfYear : Int
    {
        get
        {
            if _dateTime == nil
            {
                fillTimes()
            }
            return _weekOfYear
        }
    }
    
}

