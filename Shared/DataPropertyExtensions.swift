//
//  DataPropertyExtensions.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/3/21.
//

import Foundation
extension FixedWidthInteger {
    var data: Data {
        var _self = self
        return Data(bytes: &_self, count: MemoryLayout.size(ofValue: _self))
    }
}
extension String {
    var data: Data {
        self.data(using: .utf8)!
    }
}
extension FloatingPoint {
    var data: Data {
        var _self = self
        return Data(bytes: &_self, count: MemoryLayout.size(ofValue: _self))
    }
}
