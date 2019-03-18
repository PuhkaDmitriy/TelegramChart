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

    @IBOutlet weak var rangeSelectorChart: LineChart!
    
    @IBOutlet weak var joinedChannelView: ChannelView!
    @IBOutlet weak var dividerView: TView!
    @IBOutlet weak var leftChannelView: ChannelView!

    @IBOutlet weak var themeSwitchButton: TButton!

    @IBOutlet weak var demoChartImageView: UIImageView! // TODO - удалить
    
    // MARK: - properties

    private var presenter: ChartViewPresenter?
    private var themeControls = [ThemeProtocol]()

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ChartViewPresenter(controller: self)
        presenter?.loadChartData()

        setupContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func setupContent() {

        themeControls = [followersLabel, mainView, chartView, joinedChannelView, dividerView, leftChannelView, themeSwitchButton]
        if let selfView = self.view as? TView {
            themeControls.append(selfView)
        }

        // labels
        navigationItem.title = NSLocalizedString("mainScreen.title.statistics", comment: "")
        followersLabel.text = NSLocalizedString("mainScreen.label.followers", comment: "")
        themeSwitchButton.setTitle(getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)

        // line buttons
        // joined
        joinedChannelView.setupWith(NSLocalizedString("mainScreen.label.joinedChannel", comment: ""),
                presenter?.charts.first?.lines.filter({$0.name == Constants.y0}).first?.color ?? .black, {[weak self] isVisible in
            self?.presenter?.setVisibleJoinedChannel(isVisible)
        })

        // left
        leftChannelView.setupWith(NSLocalizedString("mainScreen.label.leftChannel", comment: ""),
                presenter?.charts.first?.lines.filter({$0.name == Constants.y1}).first?.color ?? .black, {[weak self] isVisible in
            self?.presenter?.setVisibleLeftChannel(isVisible)
        })

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

        demoChartImageView.image =  UIImage(named: Settings.shared.currentTheme == .day ? "chartDemoDay" : "chartDemoNight") // TODO - удалить

        themeSwitchButton.setTitle(getSwitchThemeButtonTitle(Settings.shared.currentTheme), for: .normal)
        setupNavigationBar(false)
        themeControls.forEach {
            $0.themeDidChange(false)
        }

    }
}
