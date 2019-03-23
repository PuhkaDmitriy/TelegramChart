//
//  InfoView.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/22/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

final class InfoView: UIView {

    @IBInspectable var lightColor: UIColor = UIColor.white {
        didSet{ themeDidChange(false) }
    }
    @IBInspectable var darkColor: UIColor = UIColor.black {
        didSet{ themeDidChange(false) }
    }

    // MARK: - outlets
    
    @IBOutlet var contentView: TView!
    @IBOutlet weak var dateLabel: TLabel!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    
    // MARK: - life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setColors(_ joinedColor: UIColor, _ leftColor: UIColor) {
        self.joinedLabel.textColor = joinedColor
        self.leftLabel.textColor = leftColor
    }

    func setValues(_ dateString: String,
                   _ joinedString: String,
                   _ leftString: String ) {
        self.dateLabel.text = dateString
        self.joinedLabel.text = joinedString
        self.leftLabel.text = leftString
    }
}

extension InfoView: ThemeProtocol {
    
    func themeDidChange(_ animation: Bool) {
        self.backgroundColor = Settings.shared.currentTheme == .day ? lightColor : darkColor
        self.dateLabel.themeDidChange()
    }
    
}
