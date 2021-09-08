//
//  ChartLogView.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/09/01.
//

import UIKit

public class ChartLogView: UIScrollView {
    typealias ActionHandler = () -> Void
    public private (set) var barView = ClubView(frame: .zero)
    var bars: [BarDto] = []
    
    private var lastSavedBarWidth_onlyForPinch: CGFloat = 0
    private var selfLastUpdateBarWidth: CGFloat = 0
    
    public private (set) var chartContentHeight: CGFloat = 0
    public private (set) var chartContentWidth: CGFloat = 0
    
    private var barIndexBasedOnScrollOffset: Int = 0
    private var chartFillPercent: CGFloat = 1 //0.90 // max: 1

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
  
    public func willBeHidden() {
        timer?.invalidate()
        timer = nil
    }
}

extension ChartLogView {
    public override func willMove(toWindow newWindow: UIWindow?) {
        timer?.invalidate()
        timer = nil
    }
}

extension ChartLogView {
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
 
    public func changeFillingPercent(_ chartFillingAreaRatio: CGFloat) {
        assert(chartFillingAreaRatio <= 1, "ratio should be 0.1 ~ 0.90")
        barView.chartPercentVersusVolumeArea = chartFillingAreaRatio
    }
     
    func scrollToCurrentTick_then_drawLastPage() {
        
        let xToMove = barAndPad * CGFloat(bars.count) - frame.width
        let plusBarOffset = xToMove + barAndPad
        let point = CGPoint(x: plusBarOffset, y: 0)
        setContentOffset(point, animated: false)
         
        barView.xCurBarPos = xToMove
         
        let minMax = self.currentIndexOfBars(plusBarOffset)
        self.asyncDrawInPeriod(bars: self.bars, range: minMax)
    }
    
    public func feed(datas: [BarDto]) {
        
        bars = datas
        barView.feed(datas: datas)
        DispatchQueue.main.async {
            self.scrollToCurrentTick_then_drawLastPage()
            self.delegate = self
            self.fireTimer()
        }
    }
    
    func asyncDrawInPeriod(bars rawData: [BarDto], range: CountableClosedRange<Int>, firstActionHandler: ActionHandler? = nil) {
        
        logChart("selected range:\(range)")
        DispatchQueue.main.async {
            self.barView.redraw(barWidth: self.selfLastUpdateBarWidth, range: range, handler: firstActionHandler)
            self.barView.setNeedsDisplay()
        }
    }
    
    func currentIndexOfBars(_ offset: CGFloat) -> CountableClosedRange<Int> {
        let numOfBar = barNumberOfThisScale()
      
        let beginAtOffset = Int(offset / CGFloat(barAndPad))
        let end = beginAtOffset + numOfBar - 1
        return beginAtOffset...end
    }
     
    func currentXContentOffset(of barIndex: Int) -> CGFloat{
        barAndPad * CGFloat(barIndex)
    }
    
    /// how may bars in current scale
    func barNumberOfThisScale() -> Int {
        let howManyBars = chartContentWidth / barAndPad
        logChart("num Of bars:\(howManyBars) = chartContentWidth: \(chartContentWidth), barAndPad:\(barAndPad) ")
        return Int(floor(howManyBars))
    }
}

extension ChartLogView {
    func prepare(on parentView: UIView, useDebug: Bool = false) {
        attachScrollView(on: parentView, scrollView: self,
                         contentView: barView,
                         maxWidth: 4000,
                         useDebugColor: useDebug)
        self.bounces = false
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
        logChart("offsetX:\(offsetX)")
        if offsetX <= 0 {
            return
        }
        let minMax = self.currentIndexOfBars(offsetX)
        
        logChart("minMax:\(minMax), x:[\(offsetX)]")
        if minMax.lowerBound == self.barIndexBasedOnScrollOffset {
          
            return
        }
       
        if !minMax.contains(bars.count-1) && minMax.upperBound > bars.count {
            timer?.invalidate()
            self.timer = nil
            return
        }
          
        if minMax.contains(bars.count-1) || minMax.upperBound >= bars.count{
          
            logChart("inclusive : \(minMax), cnt\(bars.count-1)")
            if self.timer == nil {
                fireTimer()
            }
            return
        }
        logChart("inclusive x :\(minMax), cnt\(bars.count-1)")
        timer?.invalidate()
        self.timer = nil
         
        self.barView.removeShapeNTextLayers()
        self.barView.prepare(paddingSize: self.pad10,
                             newScrollOffset: offsetX,
                             viewHeight: self.chartContentHeight)
        
        self.asyncDrawInPeriod(bars: bars, range: minMax)
        self.barIndexBasedOnScrollOffset = minMax.lowerBound
    }
}
 
extension ChartLogView {
    
    public func prepareAllValues() {
      
        lastSavedBarWidth_onlyForPinch = tenBarWidth
        selfLastUpdateBarWidth = tenBarWidth
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
        
        if gesture.state == .ended {
            lastSavedBarWidth_onlyForPinch = selfLastUpdateBarWidth
            return
        }
       
        let scaledWidth = lastSavedBarWidth_onlyForPinch * orgScale
        
        logChart("newVal: \(scaledWidth.precise2) \t =  curBarWidth:\(lastSavedBarWidth_onlyForPinch.precise2) * scale:\(orgScale.precise2)")
        
        selfLastUpdateBarWidth = scaledWidth
        barView.removeShapeNTextLayers()
        redrawIfPinches()
    }
    
    func redrawIfPinches() {
        let minMax = self.currentIndexOfBars(0)
        self.asyncDrawInPeriod(bars: self.bars, range: minMax)
    }
}
