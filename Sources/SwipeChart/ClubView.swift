//
//  OStickView.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/08/29.
//

import UIKit

private let errorValue: CGFloat = -99

public class ClubView: UIView {
    public var chartFullHeight: CGFloat = 0
    public var chartPercentVersusVolumeArea: CGFloat = 0.9
    public var chartDatas: [BarDto] = []
     
    public var chartPortionHeight: CGFloat {
        chartFullHeight * chartPercentVersusVolumeArea
    }
    
    public var volumePortionHeight: CGFloat {
        chartFullHeight * (1-chartPercentVersusVolumeArea)
    }
    
    public var xCurBarPos: CGFloat = 0
    public var paddingBar: CGFloat = errorValue
  
    private var xGridColor: CGColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    private var yGridColor: CGColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    private var upColor: CGColor = UIColor.red.cgColor
    private var downColor: CGColor = UIColor.blue.cgColor
    private var textColor: CGColor = UIColor.black.cgColor
    private var textBackColor: CGColor = UIColor.white.withAlphaComponent(0.2).cgColor
    
    private var xGridDarkColor: CGColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    private var yGridDarkColor: CGColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    private var upDarkColor: CGColor = UIColor.red.cgColor
    private var downDarkColor: CGColor = UIColor.blue.cgColor
    private var textDarkColor: CGColor = UIColor.black.cgColor
    private var textBackDarkColor: CGColor = UIColor.white.withAlphaComponent(0.2).cgColor
    
    private var useTextPrice: Bool = false
    public var gridDevider: CGFloat = 32
}

extension ClubView {
    
    public func setupColors(rise: UIColor, down: UIColor, text: UIColor, textBack: UIColor, xGrid: UIColor, yGrid: UIColor) {
        upColor = rise.cgColor
        downColor = down.cgColor
        textColor = text.cgColor
        textBackColor = textBack.cgColor
        xGridColor = xGrid.cgColor
        yGridColor = yGrid.cgColor
    }
 
    public func prepareFirstTime(barWidth: CGFloat, paddingSize: CGFloat, viewHeight: CGFloat) {
        paddingBar = paddingSize
        xCurBarPos = 0
        chartFullHeight = viewHeight
    }
    
    public func feed(datas: [BarDto]) {
        chartDatas = datas
    }
     
    public  func prepare(paddingSize: CGFloat, newScrollOffset: CGFloat, viewHeight: CGFloat) {
        paddingBar = paddingSize
        xCurBarPos = newScrollOffset
        chartFullHeight = viewHeight
    }
}

public extension ClubView {
    typealias ActionHandler = () -> Void
    func redraw(barWidth: CGFloat, range: CountableClosedRange<Int>, handler: ActionHandler? = nil) {
        assert(chartFullHeight > 0, "should call prepare")
        let cutBars = Array<BarDto>(self.chartDatas[range])
        let dataCut = convertAxis(chartDatas: cutBars)
        let volumeAndUpDownCut: [(CGFloat, Bool)] = convertVolumes(chartDatas: cutBars)

        var idx = 0
        for data in dataCut {
            let eachVolume = volumeAndUpDownCut[idx]
            self.drawSingleBar(width: barWidth, prices: data, vol: eachVolume.0, isRise: eachVolume.1)
            idx += 1
        }
        let pri = "xCurBarPos: \(self.xCurBarPos)"
        logChart("pri__cc:\(pri)")
        drawGrids(viewSize: self.frame.size)
        handler?()
    }
}

private extension ClubView {
    func drawSingleBar(width: CGFloat, prices: OpenClose, vol: CGFloat, isRise: Bool) {

        guard paddingBar >= 0 else {
            assert(false, "should call prepare()")
            return
        }
        let halfSizeOfBar_calayerLeftOffset: CGFloat = width / 2
        let barLayer = makeBar(xCurBarPos + halfSizeOfBar_calayerLeftOffset, startY: prices.openVal, endY: prices.closeVal, barwidth: width)
        let lowHighLayer = makeBar(xCurBarPos + halfSizeOfBar_calayerLeftOffset, startY: prices.highVal, endY: prices.lowVal, barwidth: width, isLowHigh: true)
        
        let volLayer = makeVolumeBar(xCurBarPos + halfSizeOfBar_calayerLeftOffset, startY: vol, barwidth: width, isRise: isRise)

        let textLayer = makeTextLayer(currentIndex: xCurBarPos, startPrice: prices.openVal, endPrice: prices.closeVal)
         
        xCurBarPos = xCurBarPos + width + paddingBar
        
        layer.addSublayer(lowHighLayer)
        layer.addSublayer(barLayer)
        layer.addSublayer(volLayer)
        
        if let randomNumbers = [1, 2, 3, 4, 5].randomElement(), randomNumbers == 1 {
            layer.addSublayer(textLayer)
        } 
    }
     
    func makeBar(_ xf: CGFloat , startY: CGFloat, endY: CGFloat, barwidth: CGFloat, isLowHigh:Bool = false) -> CAShapeLayer {
        let freshLayer = CAShapeLayer()
        let bzPath = UIBezierPath()
        
        // draw 1 point if startY == endY
        let modifiedEndY = startY == endY ? endY + 1.0 : endY
        // xf position is the same, only y-axis matters.
        bzPath.move(to: CGPoint(x: xf, y: startY))           // ex) x 0, y 30
        bzPath.addLine(to: CGPoint(x: xf, y: modifiedEndY))  // ex) x 0, y 7.22
 
        let strokeColor: CGColor
        if startY > endY{
            strokeColor = upColor
           
        } else if startY < endY {
            strokeColor = downColor
            
        } else {
            strokeColor = UIColor.black.cgColor
        }
        logChart("startY,\(startY) - end:\(endY)")
        freshLayer.path = bzPath.cgPath
        freshLayer.strokeColor = isLowHigh ? UIColor.black.cgColor : strokeColor
        freshLayer.lineWidth = isLowHigh ? 0.5 : barwidth
        freshLayer.strokeEnd = 1
        return freshLayer
    }
    
    func makeVolumeBar(_ xf: CGFloat , startY: CGFloat, barwidth: CGFloat, isRise: Bool = false) -> CAShapeLayer {
        let freshLayer = CAShapeLayer()
        let bzPath = UIBezierPath()
        
        // draw 1 point if startY == endY
        //let modifiedEndY = startY == endY ? endY + 1.0 : endY
        // xf position is the same, only y-axis matters.
        let max = chartFullHeight
        bzPath.move(to: CGPoint(x: xf, y: startY))           // ex) x 0, y 30
        bzPath.addLine(to: CGPoint(x: xf, y: max))  // ex) x 0, y 7.22
 
        let strokeColor: CGColor
        if isRise {
            strokeColor = UIColor.deepRed.cgColor
           
        } else {
            strokeColor = UIColor.deepBlue.cgColor
        }
         
        freshLayer.path = bzPath.cgPath
        freshLayer.strokeColor = strokeColor
        freshLayer.lineWidth = barwidth
        freshLayer.strokeEnd = 1
        return freshLayer
    }
    
    func makeTextLayer(currentIndex: CGFloat, startPrice: CGFloat, endPrice: CGFloat) -> CATextLayer {
        let textLayer = CATextLayer()
        let yAdjustedText = startPrice - 50
         
        textLayer.frame = CGRect(x: currentIndex, y: yAdjustedText, width: 60, height: 40)
        textLayer.fontSize = 9
        let curText = String(describing: endPrice) + String(describing: "\n[\(currentIndex)]")
         
        textLayer.string = curText
        textLayer.foregroundColor = textColor  
        textLayer.backgroundColor = textBackColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
}
 
extension ClubView {
    public func removeShapeNTextLayers() {
        xCurBarPos = 0
        layer.olog()
        
        self.layer.sublayers?
            .filter { $0 is CAShapeLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        self.layer.sublayers?
            .filter { $0 is CATextLayer }
            .forEach { $0.removeFromSuperlayer() }
        
        #if DEBUG
        logChart("rrrr &&&& - \(layerCount), caShapre cnt:\(shapeCount)")
        layer.olog()
        #endif
    }
}

extension ClubView {
    public var layerCount: String {
        "all layer cnt:\(self.layer.sublayers?.count ?? 0)"
    }
    
    public var shapeCount: String {
        let shapes = layer.sublayers?.compactMap { $0 is CAShapeLayer }.count ?? 0
        return  "shape cnt: [\(shapes)]"
    }
}
