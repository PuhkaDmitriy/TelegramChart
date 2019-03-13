//
//  Column.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/12/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import Foundation
import UIKit

struct ChartData: Codable {

    let columns: [Column]?
    let types: AxisType?
    var names: AxisNames?
    var colors: AxisColors?

    enum CodingKeys: String, CodingKey {
        case columns
        case types
        case names
        case colors

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        columns = try values.decodeIfPresent([Column].self, forKey: .columns)
        types = try values.decodeIfPresent(AxisType.self, forKey: .types)
        names = try values.decodeIfPresent(AxisNames.self, forKey: .names)
        colors = try values.decodeIfPresent(AxisColors.self, forKey: .colors)
    }

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

struct AxisColors: Codable {
    var y0: String?
    var y1: String?
}
