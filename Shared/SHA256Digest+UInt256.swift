//
//  SHA256Digest+UInt256.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/3/21.
//

import Foundation
import CryptoKit

struct UInt256Holder {
    var a: UInt64
    var b: UInt64
    var c: UInt64
    var d: UInt64
}
extension SHA256.Digest {

    var uint256: UInt256 {
        let data = self.withUnsafeBytes { Data($0) }
       
        let value = data.withUnsafeBytes {
            $0.load(as: UInt256Holder.self)
        }
        return UInt256([value.a.bigEndian, value.b.bigEndian, value.c.bigEndian, value.d.bigEndian])
    }
}
