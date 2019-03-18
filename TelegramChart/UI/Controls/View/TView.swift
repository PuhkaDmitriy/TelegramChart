//
//  TView.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

class TView: UIView {

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

extension TView: ThemeProtocol {

    func themeDidChange(_ animation: Bool = true) {

        let color = Settings.shared.currentTheme == .day ? lightColor : darkColor

        if(animation) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.backgroundColor = color

            }, completion:nil)
        }else {
            self.backgroundColor = color
        }
    }
}
