//
//  BlockchainNode.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/7/21.
//

import Foundation
import CryptoKit

class BlockchainNode: ObservableObject {
    
    var id: UUID = UUID()
    var memoryPool: MemoryPool
    
    @Published var blocks: [Block] = [Block]()
    @Published var currentMiningResult: String = ""
    
    var shouldCancelMiningBlock = false
    
    init(memoryPool: MemoryPool, genesisBlock: Block? = nil) {
        self.memoryPool = memoryPool
        memoryPool.join(node: self)
        if let genesisBlock = genesisBlock {
            mine(block: genesisBlock)
        } else {
            checkMemoryPool()
        }
    }
    
    func checkMemoryPool() {
      //  print(#function)
        for (key, node) in memoryPool.nodes {
            var isThereLongerChain = false
            if key != self.id {
                // TODO: check for blockchain validity before assuming their blocks are good
                // TODO: don't take all the blocks, just "download" the ones that are new
                if node.blocks.count >= self.blocks.count {
                    self.blocks = node.blocks
                    isThereLongerChain = true
                }
            }
            if !isThereLongerChain {
                // we mined a new block, so remove our transactions from the mempool transactions
                if let block = self.blocks.last {
                    memoryPool.removeTransactions(block.transactions)
                }
            }
        }
         
       
        if let block = self.blocks.last {
            let newTransactions = memoryPool.getTransactions()
            if !newTransactions.isEmpty {
                let newBlock = Block()
                newBlock.minedBy = self.id
                newBlock.previousHash = block.hash
                newBlock.transactions = newTransactions
                self.mine(block: newBlock)
            } else {
                // no new transactions, check back later
                // random so other nodes more likely to get in on the action.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double.random(in: 1...2)) {
                    self.checkMemoryPool()
                }
            }
        } else {
            print("genesis block...")
            let newBlock = Block()
            // make genesis even if empty
            newBlock.minedBy = self.id
            newBlock.transactions = memoryPool.getTransactions()
            self.mine(block: newBlock)
        }
    }
    
    
    
    func mine(block: Block) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self = self else  { return }
            
            self.mineHashFor(block: block, shouldCancel: &self.shouldCancelMiningBlock) { result in
                switch result {
                case .success(let block):
                    DispatchQueue.main.async {
                        self.blocks.append(block)
                        self.checkMemoryPool()
                    }
                case .failure(let error):
                    switch error {
                    case .outOfHashes:
                        print("out of hashes")
                    case .cancelled:
                        print("mining cancelled")
                    }
                }
            }
        }
       
        
    }
    
    private enum CodingKeys : CodingKey {
        case blocks
    }
    
    
    enum MiningStoppageError: Error {
        case outOfHashes
        case cancelled
    }
    typealias BlockCreationHandler = (Result<Block, MiningStoppageError>) -> Void
    
    func mineHashFor(block: Block, shouldCancel: inout Bool, result: @escaping BlockCreationHandler) {
        shouldCancel = false
    
        block.index = UInt64(self.blocks.count)
        block.timestamp = Current.date().asUInt32
      
        var blockWithNonceData = block.hashableData + block.nonce.data + block.timestamp.data
        
        var hash = SHA256.hash(data: blockWithNonceData)
        //let magic = Data([0x69, 0x04, 0x20])
        let magic = Data([0x69, 0x04])
        while(!hash.starts(with: magic) && shouldCancel == false) {
            if block.nonce != UInt32.max {
                block.nonce += 1
            } else {
                //shuffle transactions or get new transactions
            }
            let tempNonce = block.nonce
            if tempNonce.quotientAndRemainder(dividingBy: 10_000).remainder == 0 {
                DispatchQueue.main.async {
                    self.currentMiningResult = hash.uint256.toHexString() + "-" + "\(tempNonce)"
                }
            }
            block.timestamp = Current.date().asUInt32
            blockWithNonceData = block.hashableData + block.nonce.data + block.timestamp.data
            hash = SHA256.hash(data: blockWithNonceData)
        }
        if shouldCancel == true  {
            result(.failure(.cancelled))
        } else {
            block.hash = hash.uint256
            result(.success(block))
        }
   
    }
 
}
