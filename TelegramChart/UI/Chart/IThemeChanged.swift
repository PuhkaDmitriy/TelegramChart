//
//  IThemeChanged.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

public enum ThemeCode
{
    case dark
    case light
}

public protocol IThemeChanged
{
    
    func themeChanged(_ resetLayout : Bool);
}
