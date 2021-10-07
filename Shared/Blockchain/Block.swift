//
//  Block.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/5/21.
//

import Foundation

class Block {
    var index: UInt64 = 0
    var previousHash: UInt256 = UInt256.init([0,0,0,0])
    var hash: UInt256 = UInt256.init([0,0,0,0])
    var nonce: UInt32 = 0
    var timestamp: UInt32 = 0
    var hashableDataWithNonceData: Data {
        var data = Data()
        data += hashableData
        data += nonce.data
        return data
    }
    var hashableData: Data {
        var data = Data()
        data += previousHash.data
        data += hash.data
        for transaction in self.transactions {
            data += transaction.dataToHash
        }
        return data
    }
    var transactions :[Transaction] = [Transaction]()
    
    var textSummary: String {
        var summary = ""
        for transaction in transactions {
            summary += transaction.description
            if transaction.description != transactions.last?.description {
                summary += "\n"
            }
        }
        return summary
    }
}
