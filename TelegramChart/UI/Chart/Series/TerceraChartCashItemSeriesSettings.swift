//
//  CashItemSeriesSettings.swift
//  Protrader 3
//
//  Created by Yuriy on 06/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit
import ProFinanceApi

class TerceraChartCashItemSeriesSettings: Any {
    static var allowNewVolumeBars : Bool = false;
    
    var showVolume : Bool = true;
    var volumeMode:VolumeMode = VolumeMode.totalVolume
    var customAmount:Double = 0;
    var showEmptyBars : Bool = false;
    
    var useRealTicksData : Bool = false;
    /// <summary>
    /// Откуда брать значения для расчета относительных шкал
    /// </summary>
    var basisType = TerceraChartCashItemSeriesDataTypeBasisType.beginOfScreen;
    var relativeDataConverter:TerceraChartSeriesRelativeDataConverter
    /// <summary>
    /// Тип данных: абсолютные/относительные/логарифмические
    /// </summary>
    var dataType = TerceraChartCashItemSeriesDataType.absolute;
    let logDataConverter : TerceraChartSeriesLogDataConverter;
    
    
    var clusterEnabled : Bool
    {
        get
        {
            let modes = self.clusterModes;
            return modes != nil && modes!.count > 0;
        }
    }
    
    var clusterModes : Array<VolumeMode>?
    {
        get
        {
            return nil //(chartMVCModel?.timeFrameInfo?.aggregationMode as? TFAgregationModeCluster)?.dataTypes   always nil
        }
    }
    
    var activeConverter : TerceraChartSeriesDataConverter?
    {
        get
        {
            if(self.dataType == TerceraChartCashItemSeriesDataType.log)
            {
                return self.logDataConverter;
            }
            else if(self.dataType == TerceraChartCashItemSeriesDataType.relative)
            {
                return self.relativeDataConverter;
            }
            else
            {
                return nil;
            }
        }
    }
    
    
    init()
    {
        logDataConverter = TerceraChartSeriesLogDataConverter()
        relativeDataConverter = TerceraChartSeriesRelativeDataConverter()
    }
    
}
