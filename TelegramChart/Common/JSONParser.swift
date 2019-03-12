//
//  JSONParser.swift
//  TelegramChart
//
//  Created by DmitriyPuchka on 3/12/19.
//  Copyright © 2019 DmitriyPuchka. All rights reserved.
//

import UIKit
import Foundation

class JSONParser {
    
    private var fileName: String
    private var fileExtension: String
    
    init(fileName: String,
         fileExtension: String) {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }

    @discardableResult
    func parse() -> Decodable? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                let data = try Data(contentsOf: url)

                let decodableResult = try JSONDecoder().decode([ChartData].self, from: data)

                return decodableResult

            }catch {
                print("Error: " + error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
}
