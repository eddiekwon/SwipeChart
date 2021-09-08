//
//  OpenClose.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/09/02.
//

import SwiftUI

public struct OpenClose {
    let openPrice: Double
    let highPrice: Double
    let lowPrice: Double
    let closePrice: Double   
    
    var openVal: CGFloat {
        CGFloat(openPrice)
    }
    var closeVal: CGFloat {
        CGFloat(closePrice)
    }
    var highVal: CGFloat {
        CGFloat(highPrice)
    }
    var lowVal: CGFloat {
        CGFloat(lowPrice)
    }
}
