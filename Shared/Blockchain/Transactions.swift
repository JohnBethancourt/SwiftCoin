//
//  Transactions.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/7/21.
//

import Foundation
enum TransactionType: UInt8 {
    case monetary
    case message
    case image
    case video
}

protocol Transaction {
    var id: UUID { get }
    var description: String  { get }
    var dataToHash: Data { get }
    var from: String { get }
    var to: String { get }
    var transactionType: TransactionType  { get }
}

struct MessageTransaction: Transaction, Hashable {
    let id = Current.getUUID()
    var from: String
    var to: String
    var message: String
    let transactionType: TransactionType = .message
    var dataToHash: Data  {
        var data = Data()
        data += from.data
        data += to.data
        data += message.data
        data += transactionType.rawValue.data
        return data
    }
    var description: String {
        "From: \(from) To: \(to) Message: \(message)  "
    }
}

struct MonetaryTransaction: Transaction, Hashable {
    let id = Current.getUUID()
    var from: String
    var to: String
    var amount: Double
    var fees: Double = 0.0
    let transactionType: TransactionType = .monetary
    var dataToHash: Data  {
        var data = Data()
        data += from.data
        data += to.data
        data += amount.data
        data += fees.data
        data += transactionType.rawValue.data
        return data
    }
    var description: String {
        "From: \(from) To: \(to) Amount: \(amount) Fees: \(fees)"
    }
}
