//
//  BarDto.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/09/02.
//

import UIKit

public struct BarDto {
    let candle_date_time_utc: String
    let candle_date_time_local: String
    
    let opening_price: Double
    let high_price: Double
    let low_price: Double
    let trade_price: Double
    
    let timestamp: TimeInterval?
    let candle_acc_trade_price: Double
    let candle_acc_trade_volume: Double
    let change_price: Double
    
    let unit: Int?
    
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
     
    public init(candle_date_time_utc: String, candle_date_time_local: String,
                opening_price: Double, high_price: Double, low_price: Double, trade_price: Double,
                timestamp: TimeInterval?, candle_acc_trade_price: Double, candle_acc_trade_volume: Double,
                change_price: Double,
                unit: Int?) {
        
        self.candle_date_time_utc    = candle_date_time_utc
        self.candle_date_time_local  = candle_date_time_local
        self.opening_price           = opening_price
        self.high_price              = high_price
        self.low_price               = low_price
        self.trade_price             = trade_price
        self.timestamp               = timestamp
        self.candle_acc_trade_price  = candle_acc_trade_price
        self.candle_acc_trade_volume = candle_acc_trade_volume
        self.change_price = change_price
        self.unit                    = unit
         
    }
}
