//
//  TerceraChartNumberScaleRenderer.swift
//  Protrader 3
//
//  Created by Yuriy on 10/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class TerceraChartNumberScaleRenderer: BaseRenderer {
    
    let settings:TerceraChartNumberScaleRendererSettings
    
    override init(chartBase : ChartBase)
    {
        settings = (chartBase as! ProChart).timeScaleRendererSettings;
        super.init(chartBase: chartBase)
    }
    
    static let hpiTrue:[Double] = [10000000000, 5000000000, 1000000000, 500000000, 100000000, 50000000, 10000000,5000000, 1000000, 500000, 100000, 50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 7.5, 5, 2.5, 1, 0.5,
                                   0.2, 0.1, 0.05, 0.02, 0.01, 0.005, 0.002, 0.001, 0.0005, 0.0002, 0.0001,0.00005, 0.00002, 0.00001,0.000005, 0.000002, 0.000001,0.0000005, 0.0000002, 0.0000001,0.00000005, 0.00000002, 0.00000001,0.000000005, 0.000000002, 0.000000001];
    
    
    func calcStep(maxV:Double, minV:Double, maxC:CGFloat, minC:CGFloat, itemheight:CGFloat = 38) -> Double
    {
        var step:Double = 10;
        let inter = TerceraChartNumberScaleRenderer.hpiTrue;
        
        // +++ почему 38?
        // - А почему бы и нет?
        let nstep:Double = (Double(itemheight) * (maxV - minV)) / Double(maxC - minC);
        
        if (nstep > inter[0])
        {
            step = inter[0];
        }
        else
        {
            for i in 1...(inter.count - 1)
            {
                if ((nstep >= inter[i]) && (nstep < inter[i - 1]))
                {
                    if ((nstep - inter[i]) > (inter[i - 1] - nstep))
                    {
                        step = inter[i - 1];
                    }
                    else
                    {
                        step = inter[i];
                    }
                }
            }
        }
        return step
    }
    
    func calcStart(step:Double,minV:Double) -> Double
    {
        let stepsInMin = round(minV / step)
        var resMin = stepsInMin * step
        if resMin < minV
        {
            resMin = resMin + step
        }
        return resMin;
    }
}
