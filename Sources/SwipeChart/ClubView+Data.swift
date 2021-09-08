//
//  ClubView+Data.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/09/01.
//

import UIKit
extension ClubView {
    public func convertAxis(chartDatas bars: [BarDto]) -> [OpenClose] {
        let maxPrices = bars.map { CGFloat($0.high_price)  }
        let minPrices = bars.map { CGFloat($0.low_price)  }
        let maxY =  maxPrices.max()!
        let minY = minPrices.min()!
        let diff = maxY - minY
        
        let ratio: Double = Double(chartPortionHeight / diff)
        let dMinY = Double(minY)
         
        let dDeviceHeight = Double(chartPortionHeight)
        let deviceBars = bars.map { OpenClose(openPrice: dDeviceHeight  - ($0.opening_price - dMinY) * ratio,
                                              highPrice: dDeviceHeight - ($0.high_price - dMinY) * ratio,
                                              lowPrice: dDeviceHeight - ($0.low_price - dMinY) * ratio,
                                              closePrice: dDeviceHeight - ($0.trade_price - dMinY) * ratio)}
        return deviceBars
    }
    
    func convertVolumes(chartDatas bars: [BarDto]) -> [(CGFloat, Bool)] {
        let allActualVolumes = bars.map { CGFloat($0.candle_acc_trade_volume)  }
        let maxVolume =  allActualVolumes.max()!
        let ratio = (volumePortionHeight / maxVolume)
        let dDeviceHeight = chartFullHeight
        let volumes = bars.map { (dDeviceHeight - (CGFloat($0.candle_acc_trade_volume) * ratio), $0.change_price > 0 )  }
        return volumes
    }
}
