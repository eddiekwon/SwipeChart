//
//  BarDto.swift
//  DrawBar101
//
//  Created by eddie kwon on 2021/09/02.
//

import UIKit

public struct BarDto: Codable {
    let candle_date_time_utc: String
    let candle_date_time_local: String
    let opening_price: Double
    let high_price: Double
    let low_price: Double
    let trade_price: Double
    let timestamp: TimeInterval?
    let candle_acc_trade_price: Double
    let candle_acc_trade_volume: Double
    let unit: Int?
    
    var openVal: CGFloat {
        CGFloat(opening_price)
    }
    var closeVal: CGFloat {
        CGFloat(trade_price)
    }
    var highVal: CGFloat {
        CGFloat(high_price)
    }
    var lowVal: CGFloat {
        CGFloat(low_price)
    }
}

