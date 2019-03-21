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
    private var completion: ((PreparingChartData?, Error?) -> Void)?
    
    init(fileName: String,
         fileExtension: String) {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }

    func parse(withCompletion: (([ChartDataSource]) -> Void)? = nil) {

        var chartPreparingData: [PreparingChartData]?

        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                let data = try Data(contentsOf: url)
                chartPreparingData = try JSONDecoder().decode([PreparingChartData].self, from: data)
            } catch {
                print("Error: " + error.localizedDescription)
            }
        } else {
            print("Error: incorrect JSON url")
        }

        guard let preparingData = chartPreparingData else { return }

        var charts = [ChartDataSource]()
        preparingData.forEach {
            charts.append(ChartDataSource($0))
        }
        withCompletion?(charts)
    }
}
