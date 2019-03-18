//
//  ChannelView.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/13/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

@IBDesignable
final class ChannelView: UIView {

    // MARK: - outlets

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorIndicatorView: UIView!
    @IBOutlet weak var lineLabel: TLabel!
    @IBOutlet weak var lineButton: UIButton!

    private var didSelect: ((Bool) -> Void)?

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
        Bundle.main.loadNibNamed("ChannelView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupButtonImage()
    }

    func setupButtonImage() {
        if let imageView = lineButton.imageView {
            
            lineButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: (bounds.width - 60), bottom: 14, right: 5)
            lineButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageView.frame.width)
        }
    }

    func setupWith(_ title: String,
                   _ color: UIColor,
                   _ didSelect: ((Bool) -> Void)?) {
        self.lineLabel.text = title
        self.colorIndicatorView.backgroundColor = color
        self.didSelect = didSelect
    }

    // MARK: - actions

    @IBAction func lineButtonAction(_ sender: Any) {
        lineButton.isSelected.toggle()
        didSelect?(lineButton.isSelected)
    }

}

extension ChannelView: ThemeProtocol {

    func themeDidChange(_ animation: Bool) {
        self.lineLabel.themeDidChange()
    }

}
