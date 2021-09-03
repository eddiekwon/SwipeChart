//
//  ClubView+Data.swift
//  DrawBar101
//
//  Created by eddie kwon on 2021/09/01.
//

import UIKit
extension ClubView {
    public func convertAxis(chartDatas: [BarDto]) -> [OpenClose] {
  
        let bars = chartDatas
        let mapped = chartDatas.map { "\($0.opening_price)" }
        print("items:\(mapped)")
         
        let maxPrices = bars.map { CGFloat($0.high_price)  }
        let minPrices = bars.map { CGFloat($0.low_price)  }
        let maxY =  maxPrices.max()!
        let minY = minPrices.min()!
        let diff = maxY - minY
         
        let ratio: Double = Double(chartFullHeight / diff)
         
        let dMinY = Double(minY)
        let dDeviceHeight = Double(chartFullHeight)
        let deviceBars = bars.map { OpenClose(openPrice: dDeviceHeight  - ($0.opening_price - dMinY) * ratio,
                                              highPrice: dDeviceHeight - ($0.high_price - dMinY) * ratio,
                                              lowPrice: dDeviceHeight - ($0.low_price - dMinY) * ratio,
                                              closePrice: dDeviceHeight - ($0.trade_price - dMinY) * ratio)}
         
        return deviceBars
    }
}
