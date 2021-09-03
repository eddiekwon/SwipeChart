//
//  BarDto.swift
//  DrawBar101
//
//  Created by eddie kwon on 2021/09/02.
//

import UIKit

public struct BarDto: Codable {
    public let candle_date_time_utc: String
    public let candle_date_time_local: String
    public let opening_price: Double
    public let high_price: Double
    public let low_price: Double
    public let trade_price: Double
    public let timestamp: TimeInterval?
    public let candle_acc_trade_price: Double
    public let candle_acc_trade_volume: Double
    public let unit: Int?
    
    public var openVal: CGFloat {
        CGFloat(opening_price)
    }
    public var closeVal: CGFloat {
        CGFloat(trade_price)
    }
    public var highVal: CGFloat {
        CGFloat(high_price)
    }
    public var lowVal: CGFloat {
        CGFloat(low_price)
    }
}

