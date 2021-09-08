//
//  ClubView+Grid.swift
//  SwipeChart
//
//  Created by eddie kwon on 2021/09/08.
//

import UIKit

extension ClubView {
    func drawGrids(viewSize: CGSize) {
        
        let staticSize = viewSize.width / gridDevider
        
        let gridHeightSize = staticSize
        let gridWidthSize = staticSize
        
        var xCurrentPos: CGFloat = 0
        while xCurrentPos <= viewSize.width {
            addVerticalGrid(xCurrentPos)
            xCurrentPos += gridWidthSize
        }
        
        var yCurrentPos: CGFloat = 0
        while yCurrentPos <= viewSize.height {
            addHorizontalGrid(yCurrentPos)
            yCurrentPos += gridHeightSize
        }
    }
    
    func addVerticalGrid(_ xf: CGFloat) {
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: xf, y: 0))
        Path.addLine(to: CGPoint(x: xf, y: frame.height))
        Path.close()
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = Path.cgPath
        shapeLayer1.strokeColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        layer.addSublayer(shapeLayer1)
    }
    
    func addHorizontalGrid(_ yf: CGFloat) {
        let Path = UIBezierPath()
        Path.move(to: CGPoint(x: 0, y: yf))
        Path.addLine(to: CGPoint(x: frame.width, y: yf))
        Path.close()
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = Path.cgPath
        shapeLayer2.strokeColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        layer.addSublayer(shapeLayer2)
    }
}
