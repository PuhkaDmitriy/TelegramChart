//
//  BaseViewController.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/11/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    func setupNavigationBar(_ animate: Bool = true) {
        let currentTheme = Settings.shared.currentTheme
        let backgroundColor = currentTheme == .day ? Constants.dayNavigationBarColor : Constants.nightNavigationBarColor
        let titleColor = currentTheme == .day ? UIColor.black : UIColor.white

        UIApplication.shared.statusBarStyle = currentTheme == .day ? .default : .lightContent

        if(animate) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.navigationController?.navigationBar.barTintColor = backgroundColor
//                self.navigationController?.navigationBar.tintColor = titleColor
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
            }, completion:nil)
        } else {
            self.navigationController?.navigationBar.barTintColor = backgroundColor
            self.navigationController?.navigationBar.tintColor = titleColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
        }

    }
}

extension BaseViewController: ThemeProtocol {

    func themeDidChange(_ animation: Bool = false) {
        setNeedsStatusBarAppearanceUpdate()
        setupNavigationBar()
    }

}