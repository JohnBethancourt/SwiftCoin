//
//  SwiftCoinTestsIOS.swift
//  SwiftCoinTestsIOS
//
//  Created by John Bethancourt on 10/7/21.
//

import XCTest
@testable import SwiftCoin

class SwiftCoinTestsIOS: XCTestCase {

    func testFirstBlockCreation() throws {
 
        let memoryPool = MemoryPool()
        var x = 0
        Current.date =  { Date.init(timeIntervalSince1970: 0) }
        Current.getUUID =  {
            x += 1
            let string = "33041937-05b2-464a-98ad-3910cbe0d09\(x)"
            let uuid = UUID(uuidString: string)
            return uuid!
        }
        let blockchainNode = BlockchainNode(memoryPool: memoryPool)

        let expectation = XCTestExpectation(description: "Mining block with 5 transactions.")
        
        let cancellable = blockchainNode.$blocks.sink { blocks in
            if blocks.count > 1 {
                expectation.fulfill()
            }
        }
        
        let transaction1 = MonetaryTransaction(from: "Mary", to: "John", amount: 10.01)
        let transaction2 = MonetaryTransaction(from: "John", to: "Stan", amount: 20.78)
        let transaction3 = MonetaryTransaction(from: "Dale", to: "Jane", amount: 23.58)
        let transaction4 = MonetaryTransaction(from: "Tron", to: "Dave", amount: 11.12)
        let transaction5 = MonetaryTransaction(from: "Beth", to: "Mark", amount: 22.33)
        memoryPool.addTransactions([transaction1, transaction2, transaction3, transaction4, transaction5])
       
        wait(for: [expectation], timeout: 20)
    
        let block1 = try XCTUnwrap(blockchainNode.blocks.first)
        let block2 = try XCTUnwrap(blockchainNode.blocks.last)
        
        XCTAssertEqual(block1.nonce, 84583)
        XCTAssertEqual(block2.nonce, 35432)
 
        XCTAssertEqual(block1.hash.toHexString(), "69046ae7aa5458f3358ddef4d32e798a090c012fa3f22577f1e80cc5bccdc527")
        XCTAssertEqual(block2.hash.toHexString(), "6904e8d04a36a4d5688d85bee284b063a6c763f75fa2470d3d08faaf3ccc7d2e")
        
        cancellable.cancel()
    }

}
