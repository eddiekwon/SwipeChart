//
//  ChartLogView+Debug.swift
//  
//
//  Created by sgm1 on 2021/09/05.
//

import UIKit


extension ChartLogView {
    func fireTimer() {
        
        guard useRandommizedLastTick else {
            return
        }
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    
                    guard self.bars.count > 1 else {
                        return
                    }
                    self.makeRandomizeDto()
                    let xToMove = self.barAndPad * CGFloat(self.bars.count) - self.frame.width
                    let minMax = self.currentIndexOfBars(xToMove)
                    logChart("-- minMax:\(minMax), x:[\(xToMove)], y:\(self.bars.last?.closeVal)")
                    
                    self.barView.removeShapeNTextLayers()
                    self.barView.prepare(paddingSize: self.pad10,
                                         newScrollOffset: xToMove,
                                         viewHeight: self.chartContentHeight)
                    self.barView.feed(datas: self.bars)
                    self.asyncDrawInPeriod(bars: self.bars, range: minMax, startOffset: 0)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public func scrollToCurrentTick() {
        let xToMove = barAndPad * CGFloat(bars.count) - frame.width
        let point = CGPoint(x: xToMove, y: 0)
        setContentOffset(point, animated: true)
    }
    
    func makeRandomizeDto() {
        guard let last = bars.last else { return }
        logChart("last item: \(last.closeVal), bar cnt: \(bars.count)")
        
        guard let lastOpenPrice = bars.last?.openVal else { return }
         
        func randomPercentageNums() -> Double {
            let multipliers: [CGFloat] = [1.10, 1.11, 1.12, 1.13, 1.14, 1.15, 1.20, 1.30, 1.40, 1.01, 1.02]
            let choices = lastOpenPrice * multipliers.randomElement()!
            return Double(choices)
        }
        let newLast = BarDto(candle_date_time_utc: last.candle_date_time_utc,
                             candle_date_time_local: last.candle_date_time_utc,
                             opening_price: last.opening_price,
                             high_price: last.high_price,
                             low_price: last.low_price,
                             trade_price: randomPercentageNums(),
                             timestamp: last.timestamp,
                             candle_acc_trade_price: last.candle_acc_trade_price,
                             candle_acc_trade_volume: last.candle_acc_trade_volume,
                             unit: last.unit)
        bars.removeLast()
        bars.append(newLast)
      
    }
}
