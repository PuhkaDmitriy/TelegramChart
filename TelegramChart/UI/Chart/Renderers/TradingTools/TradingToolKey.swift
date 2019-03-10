//
//  TradingToolKey.swift
//  Protrader 3
//
//  Created by Yuriy on 18/02/2018.
//  Copyright © 2018 PFSoft. All rights reserved.
//

import UIKit

public func == (lhs: TradingToolKey, rhs: TradingToolKey) -> Bool {
    return lhs.id == rhs.id && lhs.isPosition == rhs.isPosition
}

    
public class TradingToolKey:Hashable{
    let id:Int64
    let isPosition:Bool
    
    init(id:Int64, isPosition:Bool) {
        self.id = id
        self.isPosition = isPosition
    }
    
    public var hashValue: Int
    {
        get
        {
            return  isPosition ? Int(id) : Int(id >> 1)
        }
    }
}
