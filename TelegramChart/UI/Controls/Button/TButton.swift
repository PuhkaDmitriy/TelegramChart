//
//  TButton.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

final class TButton: UIButton {

    // MARK: - properties

    @IBInspectable var lightColor: UIColor = UIColor.white {
        didSet {
            setup()
        }
    }

    @IBInspectable var darkColor: UIColor = UIColor.black {
        didSet {
            setup()
        }
    }

    @IBInspectable var lightTxtColor: UIColor = UIColor.black {
        didSet {
            setup()
        }
    }

    @IBInspectable var darkTxtColor: UIColor = UIColor.white {
        didSet {
            setup()
        }
    }

    // MARK: - life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    private func setup() {
        themeDidChange(false)
    }
}

// MARK: - theme

extension TButton: ThemeProtocol {

    func themeDidChange(_ animation: Bool = true) {
        let backgroundColor = Settings.shared.currentTheme == .day ? lightColor : darkColor
        let titleColor = Settings.shared.currentTheme == .day ? lightTxtColor : darkTxtColor

        if(animation) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.backgroundColor = backgroundColor
                self.setTitleColor(titleColor, for: .normal)
            }, completion:nil)
        }else {
            self.backgroundColor = backgroundColor
            self.setTitleColor(titleColor, for: .normal)
        }
    }

}
