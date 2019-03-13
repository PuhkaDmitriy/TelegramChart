//
//  Column.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/12/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

struct PreparingChartData: Codable {

    let columns: [Column]?
    let types: AxisType?
    let names: AxisNames?
    let colors: AxisColors?

}

struct Column: Codable {

    var name: String?
    var values = [Int]()

    init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()
        while !arrayContainer.isAtEnd {
            do {
                let int = try arrayContainer.decode(Int.self)
                values.append(int)
                continue
            } catch {
                if name != nil {
                    print(error.localizedDescription)
                }
            }

            if name == nil {
                do {
                    name = try arrayContainer.decode(String.self)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct AxisType: Codable {
    var y0: String?
    var y1: String?
    var x: String?
}

struct AxisNames: Codable {
    var y0: String?
    var y1: String?
}

class AxisColors: NSObject, Codable {
    var y0: String?
    var y1: String?
}
