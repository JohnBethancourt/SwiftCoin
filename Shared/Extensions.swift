//
//  Extensions.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/3/21.
//
import CryptoKit
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
extension UInt256 {
 
    var data: Data {
        self[0].bigEndian.data + self[1].bigEndian.data + self[2].bigEndian.data + self[3].bigEndian.data
    }
}
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
extension String {
    func truncatedWith(first: Int, last: Int) -> String {
        if self.count > first + last + 3 {
            return String(self.prefix(first)) + "..." + String(self.suffix(last))
        } else  {
            return self
        }
    }
}
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

extension Date {
    var asUInt32: UInt32 {
        let interval = self.timeIntervalSince1970
        return UInt32(interval)
    }
}
