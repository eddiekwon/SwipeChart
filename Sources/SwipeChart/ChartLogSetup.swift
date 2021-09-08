//
//  SwipeChart
//  
//
//  Created by eddie kwon on 2021/09/05.
//

import Foundation

public class SwipeChartSetup {
    public static let shared = SwipeChartSetup()
    public var useLog: Bool = false
    private init() {}
}
 
func logChart(_ items: Any..., separator: String = " -> ", terminator: String = "\n", function: String = #function) {
    guard SwipeChartSetup.shared.useLog else {
        return
    }
    let output = "\(function): " + items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
}
