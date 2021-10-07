//
//  MemoryPool.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/7/21.
//

import Foundation
class MemoryPool: ObservableObject {
    
    @Published var transactions: [UUID: Transaction] = [:]
    @Published var nodes: [UUID: BlockchainNode] = [:]
    
    func addTransactions(_ transactions: [Transaction]) {
        for transaction in transactions {
            self.transactions[transaction.id] = transaction
        }
    }
    func removeTransactions(_ transactionsToRemove: [Transaction]) {
        for transaction in transactionsToRemove {
            self.transactions.removeValue(forKey: transaction.id)
        }
    }
    func getTransactions() -> [Transaction] {
        self.transactions.map { $1 }.sorted { $0.id.uuidString > $1.id.uuidString }
    }
    func join(node: BlockchainNode) {
        self.nodes[node.id] = node
    }
    func leave(node: BlockchainNode) {
        self.nodes.removeValue(forKey: node.id)
    }
}
