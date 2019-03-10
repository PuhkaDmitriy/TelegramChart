//
//  Interfaces.swift
//  Protrader 3
//
//  Created by Yuriy on 08/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import Foundation
import ProFinanceApi

protocol IInstrumentRenderer
{
    var symbol : SymbolInfo? { get set };
}

protocol IAccountRenderer
{
    var account : Account? { get set };
}

protocol ISetDefaultRange
{
    func setDefaultRange(_ ww : ChartWindow);
}

