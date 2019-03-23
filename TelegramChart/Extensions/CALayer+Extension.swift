//
//  Animation.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/23/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import QuartzCore

enum AnimationType {
    case currentToDown,
         upToCurrent
}

enum AnimKeyPath: String {
    case position = "position"
}

extension CALayer {

    func addSublayer(_ layer: CALayer, withAnimation: AnimationType) {
        addSublayer(layer)
        layer.addAnimation(withAnimation)
        layer.removeAllAnimations()
    }

    func removeFromSuperlayer(withAnimation: AnimationType) {
        addAnimation(withAnimation)
        removeFromSuperlayer()
        removeAllAnimations()

    }

    func addAnimation(_ type: AnimationType,
                      _ animationDidEnd: (() -> Void)? = nil) {
        let path = AnimKeyPath.position.rawValue
        let animation = CABasicAnimation(keyPath: path);
        animation.fromValue = NSValue(cgPoint: getFrom(type))
        animation.toValue = NSValue(cgPoint: getTo(type))
        animation.duration = 0.2;

        // Callback function
        CATransaction.setCompletionBlock(animationDidEnd)

        add(animation, forKey: path);
    }

    private func getFrom(_ type: AnimationType) -> CGPoint {
        switch type {
        case .currentToDown:
            return CGPoint(x: position.x, y: position.y)
        case .upToCurrent:
            return CGPoint(x: position.x, y: position.y * 0.4)
        }
    }

    private func getTo(_ type: AnimationType) -> CGPoint {
        switch type {
        case .currentToDown:
            return CGPoint(x: position.x, y: position.y / 0.4)
        case .upToCurrent:
            return CGPoint(x: position.x, y: position.y)
        }
    }
}
