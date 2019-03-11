//
//  TLabel.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

final class TLabel: UILabel {

    // MARK: - properties

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

extension TLabel: ThemeProtocol {

    func themeDidChange(_ animation: Bool = true) {

        let textColor = Settings.shared.currentTheme == .day ? lightTxtColor : darkTxtColor

        if(animation) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.textColor = textColor

            }, completion:nil)
        }else {
            self.textColor = textColor
        }
    }
}