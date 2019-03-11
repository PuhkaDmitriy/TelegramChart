//
//  Settings.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation

enum Theme: Int {
    case day,
         night
}

final class Settings {
    
    let ThemeKey = "Theme"
    var currentTheme: Theme = .day
    
    static let shared = Settings()
    
    private init() {
        self.currentTheme = getTheme()
    }
    
    // Theme
    
    func getTheme() -> Theme {
        let integerTheme = UserDefaults.standard.integer(forKey: ThemeKey)
        return Theme(rawValue: integerTheme) ?? .night
    }
    
    func setTheme(_ theme: Theme) {
        self.currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: ThemeKey)
    }
    
}
