//
//  ViewController.swift
//  TelegramChart
//
//  Created by Dmitriy Puchka on 3/10/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

final class ChartViewController: BaseViewController {

    // MARK: - outlets

    @IBOutlet weak var followersLabel: TLabel!
    @IBOutlet weak var mainContainer: TView!
    @IBOutlet weak var chartContainer: TView!
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var joinedChannelView: ChannelView!
    @IBOutlet weak var dividerView: TView!
    @IBOutlet weak var leftChannelView: ChannelView!
    @IBOutlet weak var themeSwitchButton: TButton!
    @IBOutlet weak var mainChart: Chart!
    @IBOutlet weak var rangeSelector: RangeSelectorView!

    // MARK: - properties

    private var presenter: ChartViewPresenter?


    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ChartViewPresenter(controller: self)
        presenter?.loadChartData()
    }


    // MARK: - actions

    @IBAction func ThemeSwitchButtonAction(_ sender: Any) {
        presenter?.changeTheme()
        themeSwitchButton.titleLabel?.text = presenter?.getSwitchThemeButtonTitle(Settings.shared.currentTheme)
        themeDidChange()
    }
}

// MARK: - theme

extension ChartViewController {

    override func themeDidChange(_ animation: Bool = true) {
        super.themeDidChange(false)

        themeSwitchButton.setTitle(presenter?.getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)
        setupNavigationBar(false)
        presenter?.themeControls.forEach {
            $0.themeDidChange(false)
        }

    }
}
