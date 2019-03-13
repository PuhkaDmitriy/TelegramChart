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
    @IBOutlet weak var mainView: TView!
    @IBOutlet weak var chartView: TView!
    @IBOutlet weak var themeSwitchButton: TButton!

    // MARK: - properties

    private var presenter: ChartViewPresenter?
    private var themeControls = [ThemeProtocol]()

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.loadChartData()
    }

    func setupContent() {

        themeControls = [followersLabel, mainView, chartView, themeSwitchButton]
        if let selfView = self.view as? TView {
            themeControls.append(selfView)
        }

        presenter = ChartViewPresenter(controller: self)

        // labels
        navigationItem.title = NSLocalizedString("mainScreen.title.statistics", comment: "")
        followersLabel.text = NSLocalizedString("mainScreen.label.followers", comment: "")
        themeSwitchButton.setTitle(getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)

    }

    func getSwitchThemeButtonTitle(_ theme: Theme) -> String {
        switch theme {
        case .day:
            return NSLocalizedString("mainScreen.label.themeSwitchButton.night", comment: "")
        case .night:
            return NSLocalizedString("mainScreen.label.themeSwitchButton.day", comment: "")
        }
    }

    // MARK: - actions

    @IBAction func ThemeSwitchButtonAction(_ sender: Any) {
        presenter?.changeTheme()

        themeSwitchButton.titleLabel?.text = getSwitchThemeButtonTitle(Settings.shared.currentTheme)
        themeDidChange()
    }
}

// MARK: - theme

extension ChartViewController {

    override func themeDidChange(_ animation: Bool = true) {

        super.themeDidChange(false)

        themeSwitchButton.setTitle(getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)
        setupNavigationBar(false)
        themeControls.forEach {
            $0.themeDidChange(false)
        }

    }
}
