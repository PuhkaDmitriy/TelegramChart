//
//  RangeSelectorView.swift
//  ResizeRectangle
//
//  Created by DmitriyPuchka on 3/18/19.
//  Copyright © 2019 Peter Pohlmann. All rights reserved.
//

import UIKit

class RangeSelectorView: UIView {

    @IBInspectable var dayColor: UIColor = UIColor.white
    @IBInspectable var nightColor: UIColor = UIColor.black
    
    // MARK: - outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftBorder: UIView!
    @IBOutlet weak var rightBorder: UIView!
    
    @IBOutlet weak var rect: UIView!


    // MARK: - properties

    struct ResizeRect{
        var topTouch = false
        var leftTouch = false
        var rightTouch = false
        var bottomTouch = false
        var middleTouch = false
    }

    var touchStart = CGPoint.zero
    var proxyFactor = CGFloat(10)
    var resizeRect = ResizeRect()
    var minimumRange: CGFloat = 0

    weak var parentView: UIView?

    // MARK: - life cycle

/// This method is used when creating an `ApexView` with code.
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

/// This method is called when instantiated from a XIB.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }

    private func initView() {
        Bundle.main.loadNibNamed("RangeSelectorView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = self.bounds

        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        minimumRange = rect.frame.size.width

        themeDidChange(false)
    }

    // MARK: - methods

    func setParentView(_ parentView: UIView) {
        self.parentView = parentView
    }

    // MARK: - touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
           let parentView = self.parentView {

            let touchInParentStart = touch.location(in: parentView)
            print(touchInParentStart)

            let touchStart = touch.location(in: self)

            resizeRect.topTouch = false
            resizeRect.leftTouch = false
            resizeRect.rightTouch = false
            resizeRect.bottomTouch = false
            resizeRect.middleTouch = false

            if  touchStart.y > rect.frame.minY + (proxyFactor*2) &&
                        touchStart.y < rect.frame.maxY - (proxyFactor*2) &&
                        touchStart.x > rect.frame.minX + (proxyFactor*2) &&
                        touchStart.x < rect.frame.maxX - (proxyFactor*2) {
                resizeRect.middleTouch = true
                print("middle")
                return
            }

            if touchStart.x > rect.frame.maxX - proxyFactor &&
                       touchStart.x < rect.frame.maxX + proxyFactor {
                resizeRect.rightTouch = true
                print("right")
            }

            if touchStart.x > rect.frame.minX - proxyFactor &&
                       touchStart.x < rect.frame.minX + proxyFactor {
                resizeRect.leftTouch = true
                print("left")
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            let currentTouchPoint = touch.location(in: self)
            let previousTouchPoint = touch.previousLocation(in: self)

            let deltaX = currentTouchPoint.x - previousTouchPoint.x

            if resizeRect.middleTouch {
                if (deltaX < 0){
                    if (leftConstraint.constant + deltaX >= 0) {
                        leftConstraint.constant += deltaX
                        rightConstraint.constant -= deltaX
                    }

                } else if (deltaX > 0){
                    if(rightConstraint.constant - deltaX >= 0) {
                        rightConstraint.constant -= deltaX
                        leftConstraint.constant += deltaX
                    }
                }
            }

            if resizeRect.leftTouch {
                if(widthConstraint.constant - deltaX >= minimumRange) {
                    leftConstraint.constant += deltaX
                    widthConstraint.constant -= deltaX
                }
            }

            if resizeRect.rightTouch {
                if(widthConstraint.constant + deltaX >= minimumRange) {
                    rightConstraint.constant -= deltaX
                    widthConstraint.constant += deltaX
                }
            }

            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                self.layoutIfNeeded()
            }, completion: { (ended) in

            })
        }
    }
}

// MARK: - theme

extension RangeSelectorView: ThemeProtocol {
    
    func themeDidChange(_ animation: Bool = true) {
        
        let borderColor = Settings.shared.currentTheme == .day ? dayColor : nightColor
        
        if(animation) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.rect.layer.borderColor = borderColor.cgColor
                self.leftBorder.backgroundColor = borderColor
                self.rightBorder.backgroundColor = borderColor
            }, completion:nil)
        }else {
            self.rect.layer.borderColor = borderColor.cgColor
            self.leftBorder.backgroundColor = borderColor
            self.rightBorder.backgroundColor = borderColor
        }
    }
}
