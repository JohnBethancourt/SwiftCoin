//
//  Date+Ext.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/4/21.
//

import Foundation

extension Date {
    var asUInt32: UInt32 {
        let interval = self.timeIntervalSince1970
        return UInt32(interval)
    }
}
