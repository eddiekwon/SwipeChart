//
//  ChartLogView.swift
//  DrawBar101
//
//  Created by eddie kwon on 2021/09/01.
//

import UIKit

public class ChartLogView: UIScrollView {
  
    var barView = ClubView(frame: .zero) 
    var bars: [BarDto] = []
    
    private var lastSavedBarWidth_onlyForPinch: CGFloat = 0
    private var selfLastUpdateBarWidth: CGFloat = 0
    
    public private (set) var chartContentHeight: CGFloat = 0
    public private (set) var chartContentWidth: CGFloat = 0
    private var barIndexBasedOnScrollOffset: Int = 0
  
    var maxBarWidth: CGFloat = 0
    var fixedBarWidth: CGFloat = 20
    var tenBarWidth: CGFloat = 10
    var minBarWidth: CGFloat = 3
    var minBarPadWidth: CGFloat = 1
    public private (set) var pad10: CGFloat = 0  
   
    var isFirstVisit = true
    
    public var useRandommizedLastTick: Bool = false
    public var defaultBarWidth: CGFloat = 10  
    public var gridDevider: CGFloat = 32

    var timer: Timer?
}

public extension ChartLogView {
    var barAndPad: CGFloat {
        (selfLastUpdateBarWidth + pad10)
    }
}

extension ChartLogView {
    
    public func setupColors(rise: UIColor, down: UIColor, text: UIColor, textBack: UIColor, xGrid: UIColor, yGrid: UIColor) {
        barView.setupColors(rise: rise, down: down, text: text, textBack: textBack, xGrid: xGrid, yGrid: yGrid)
    }
    public func setupChartBackgroud(_ color: UIColor) {
        barView.backgroundColor = color
    }

    public func feed(datas: [BarDto]) {
        bars = datas
        barView.feed(datas: datas)
        let minMax = self.currentIndexOfBars(0)
        asyncDrawInPeriod(bars: datas, range: minMax, startOffset: 0) {
            self.scrollToCurrentTick()
            self.fireTimer()
        }
    }
     
    func asyncDrawInPeriod(bars rawData: [BarDto], range: CountableClosedRange<Int>, startOffset: CGFloat, firstActionHandler: (()->Void)? = nil) {
        
        logChart("selfLastUpdateBarWidth:\(selfLastUpdateBarWidth)")
        DispatchQueue.main.async {
            self.barView.redraw(barWidth: self.selfLastUpdateBarWidth, range: range, handler: firstActionHandler)
//            self.scaleLabel.text = self.selfLastUpdateBarWidth.precise2 + "num: [\(String(describing: self.barNumberOfThisScale()))]"
            self.barView.setNeedsDisplay()
        }
    }
    
    func currentIndexOfBars(_ offset: CGFloat) -> CountableClosedRange<Int> {
        let numOfBar = barNumberOfThisScale()
        // 시작 시점의 bar index구함 = 현 offset / (bar+padding 총 width)
        let beginAtOffset = Int(offset / CGFloat(barAndPad))
        let end = beginAtOffset + numOfBar
        return beginAtOffset...end
         
    }
    
    /// how may bars in current scale
    public func barNumberOfThisScale() -> Int {
        let howManyBars = chartContentWidth / barAndPad
        logChart("num Of bars:\(howManyBars) = chartContentWidth: \(chartContentWidth), barAndPad:\(barAndPad) ")
        return Int(floor(howManyBars))
    }
}

extension ChartLogView {
    public func prepare(on parentView: UIView, useDebug: Bool = false) {
        attachScrollView(on: parentView, scrollView: self,
                         contentView: barView,
                         maxWidth: 4000,
                         useDebugColor: useDebug)
        self.bounces = false
        self.delegate = self
        addPinches()
    }
     
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        chartContentHeight = frame.height
        chartContentWidth = frame.width
        maxBarWidth = chartContentHeight / CGFloat(20.0)
        
        guard isFirstVisit else {
            return
        }
        prepareAllValues()
        barView.gridDevider = gridDevider
        isFirstVisit = false
    }
}

extension ChartLogView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        if offsetX < 0 {
            return
        }
        let minMax = self.currentIndexOfBars(offsetX)
        
        logChart("minMax:\(minMax), x:[\(offsetX)]")
        if minMax.lowerBound == self.barIndexBasedOnScrollOffset {
            return
        }
         
        // case 1
        if !minMax.contains(bars.count-1) && minMax.upperBound > bars.count {
            timer?.invalidate()
            self.timer = nil
            return
        }
          
        // case 2
        if minMax.contains(bars.count-1) || minMax.upperBound >= bars.count{
            // 최종 ticker가 보이는 상황이라면 timer에서 화면 갱신하도록함.
            logChart("inclusive : \(minMax), cnt\(bars.count-1)")
            if self.timer == nil {
                fireTimer()
            }
            return
        }
          
        // other cases
        logChart("inclusive x :\(minMax), cnt\(bars.count-1)")
        timer?.invalidate()
        self.timer = nil
        
        self.barView.removeShapeNTextLayers()
        self.barView.prepare(paddingSize: self.pad10,
                             newScrollOffset: offsetX,
                             viewHeight: self.chartContentHeight)
        
        self.asyncDrawInPeriod(bars: bars, range: minMax, startOffset: offsetX)
        self.barIndexBasedOnScrollOffset = minMax.lowerBound
    }
}
 
extension ChartLogView {
    
    public func prepareAllValues() {
        // must be called ONCE since related to pinch gesture
        lastSavedBarWidth_onlyForPinch = defaultBarWidth
        selfLastUpdateBarWidth = defaultBarWidth
 
        pad10 = minBarPadWidth
        barView.prepareFirstTime(barWidth: lastSavedBarWidth_onlyForPinch,
                                 paddingSize: pad10,
                                 viewHeight: chartContentHeight)
    }
    
    public func attachScrollView(on attachingSuperView: UIView, scrollView: UIScrollView, contentView: UIView ,maxWidth: CGFloat = 4000, useDebugColor: Bool = false) {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentView)
        if #available(iOS 11.0, *) {
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
            
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
            contentView.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
        }
        
        
        attachingSuperView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 0
        if #available(iOS 11.0, *) {
            scrollView.leadingAnchor.constraint(equalTo: attachingSuperView.leadingAnchor, constant: padding).isActive = true
            scrollView.topAnchor.constraint(equalTo: attachingSuperView.topAnchor, constant: padding).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: attachingSuperView.trailingAnchor, constant: -padding).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: attachingSuperView.bottomAnchor, constant: -padding).isActive = true
        }
        if useDebugColor {
            contentView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
            scrollView.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        }
    }
}

extension ChartLogView {
    // allow another pinch gesture
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UIPinchGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

extension ChartLogView: UIGestureRecognizerDelegate {
    
    // another gesture on scrollView
    public func addPinches() {
        let pinchRecog = UIPinchGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        pinchRecog.delegate = self
        self.addGestureRecognizer(pinchRecog)
    }
    
    @objc func handleGesture(gesture: UIPinchGestureRecognizer) {
        let orgScale = gesture.scale
        // must store the last width
        if gesture.state == .ended {
            lastSavedBarWidth_onlyForPinch = selfLastUpdateBarWidth
            return
        }
        let scaledWidth = lastSavedBarWidth_onlyForPinch * orgScale
        
        logChart("newVal: \(scaledWidth.precise2) \t =  curBarWidth:\(lastSavedBarWidth_onlyForPinch.precise2) * scale:\(orgScale.precise2)")
        
        selfLastUpdateBarWidth = scaledWidth
        barView.removeShapeNTextLayers()
        redraw()
    }
    
    func redraw() {
        let minMax = self.currentIndexOfBars(0)
        self.asyncDrawInPeriod(bars: self.bars, range: minMax, startOffset: 0)
    }
}
