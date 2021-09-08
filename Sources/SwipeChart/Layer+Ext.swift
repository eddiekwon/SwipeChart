//
//  Layer+Ext.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/08/29.
//

import UIKit
extension CALayer {
    public func olog() {
        logChart(#function, "===🚨start======= sublayers cnt :\(String(describing: sublayers?.count))")
        guard let allLayers = sublayers else {
            logChart("allLayers zero")
            return
        }
        for layer in allLayers where layer is CAShapeLayer {
            let shape = layer as! CAShapeLayer
            logChart("namedd:\(shape.name) boundingBox:\(shape.path?.boundingBox)")
        }
        logChart(#function, "===👩🏻‍🔧end===")
    }
}

extension UIColor {
    public class var deepRed: UIColor{
        let org = UIColor(red: 0.5294, green: 0, blue: 0.1765, alpha: 1.0)
       return org
        
    }
    public class var deepBlue: UIColor {
        let org = UIColor(red: 0, green: 0.0078, blue: 0.4863, alpha: 1.0)
        return org
    }
}

extension CGFloat {
    public var precise2: String {
        String(format: "%.2f",  self)
    }
}

