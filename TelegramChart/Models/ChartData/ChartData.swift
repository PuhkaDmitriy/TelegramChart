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

//    let columns: [[Any]]?
    let types: AxisType?
    var names: AxisNames?
    var colors: AxisColors?

    enum CodingKeys: String, CodingKey {
//        case columns
        case types
        case names
        case colors

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

//        columns = try values.decodeIfPresent([[]].self, forKey: .columns)
        types = try values.decodeIfPresent(AxisType.self, forKey: .types)
        names = try values.decodeIfPresent(AxisNames.self, forKey: .names)
        colors = try values.decodeIfPresent(AxisColors.self, forKey: .colors)
    }

}

struct Columns: Codable {

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
