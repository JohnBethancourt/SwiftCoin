//
//  ContentView.swift
//  Shared
//
//  Created by John Bethancourt on 10/2/21.
//

import SwiftUI
import CryptoKit
struct ContentView: View {
    
    @StateObject var blockchain: BlockchainNode
    @State var colorCount = 1
    @StateObject var simMemoryPool: MemoryPool
    
    
    init() {
        let memoryPool = MemoryPool()
        _simMemoryPool = StateObject(wrappedValue: memoryPool)
        let genesisBlock = Block()
        let blockchain1 = BlockchainNode(memoryPool: memoryPool, genesisBlock: genesisBlock)
        let transaction1 = MonetaryTransaction(from: "Mary", to: "John", amount: 10.01)
        let transaction2 = MonetaryTransaction(from: "John", to: "Stan", amount: 20.78)
        let transaction3 = MonetaryTransaction(from: "Dale", to: "Jane", amount: 23.58)
        print("----------------------------------------------")
        //let block1 = blockchain1.getNextBlock(transactions: [transaction1, transaction2, transaction3])
        let block1 = Block()
        block1.transactions =  [transaction1, transaction2, transaction3]
        blockchain1.mine(block: block1)

        let transaction4 = MonetaryTransaction(from: "Tron", to: "Dave", amount: 11.12)
        let transaction5 = MonetaryTransaction(from: "Beth", to: "Mark", amount: 22.33)
        //let block2 = blockchain1.getNextBlock(transactions: [transaction4, transaction5])
        let block2 = Block()
        block2.transactions = [transaction4, transaction5]
        blockchain1.mine(block: block2)
  
        print(blockchain1.blocks)
        _blockchain =  StateObject(wrappedValue: blockchain1)
    }
    
    var body: some View {
        VStack {
            Button {
                let transaction1 = MonetaryTransaction(from: "Bobo", to: "Fran", amount: 11.12)
                let block = Block()
                block.transactions = [transaction1]
                blockchain.mine(block: block)
            } label:  {
                Text("Add Transaction")
            }
            .padding()
            VStack {
                List {
                    ForEach(blockchain.blocks.indices, id: \.self) { index in
                       
                        HStack {
                            Text("\(blockchain.blocks[index].index)")
                            
                            VStack {
                                Text(blockchain.blocks[index].previousHash.description.truncatedWith(first: 8, last: 4))
                                    .foregroundColor((index - 1) % 2 == 0 ? Color.blue : Color.yellow)
                                Text(blockchain.blocks[index].hash.description.truncatedWith(first: 8, last: 4))
                                    .foregroundColor(index % 2 == 0 ? Color.blue : Color.yellow)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Timestamp: \(blockchain.blocks[index].timestamp)")
                                Text("Transactions: \(blockchain.blocks[index].transactions.count)")
                                    .help("\(blockchain.blocks[index].textSummary)")
                            }
                            
                            .padding(.leading, 20)
                            
                        }
                     
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                      
                        .font(.system(.body, design: .monospaced))
                        
                        if index != blockchain.blocks.count - 1 {
                            Image(systemName: "link")
                                .padding(.leading, 20)
                                .foregroundColor(index % 2 == 0 ? Color.blue : Color.yellow)
                        }
                        
                    }
                
                }
            }
            VStack {
                Text(blockchain.currentMiningResult)
            }
        }
            .padding()
             
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
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
    let id = UUID()
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
    let id = UUID()
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
        self.transactions.map { $1 }
    }
    func join(node: BlockchainNode) {
        self.nodes[node.id] = node
    }
    func leave(node: BlockchainNode) {
        self.nodes.removeValue(forKey: node.id)
    }
}

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
    
    func getNextBlock(transactions :[Transaction]) -> Block {
        
        let block = Block()
        block.transactions = transactions
        
        let previousBlock = getPreviousBlock()
        block.index = UInt64(self.blocks.count)
        block.previousHash = previousBlock.hash
        block.timestamp = Current.date().asUInt32
        block.hash = generateHash(for: block)
        return block
        
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    func generateHash(for block: Block) -> UInt256 {
        let blockData = block.hashableData
        
        var blockWithNonceData = blockData + block.nonce.data
        
        var hash = SHA256.hash(data: blockWithNonceData)
        //let magic = Data([0x69, 0x04, 0x20])
        let magic = Data([0x69, 0x04])
        while(!hash.starts(with: magic)) {
            if block.nonce != UInt32.max {
                block.nonce += 1
            } else {
                //shuffle transactions or get new transactions
            }
          
            block.timestamp = Current.date().asUInt32
            blockWithNonceData = blockData + block.nonce.data + block.timestamp.data
            hash = SHA256.hash(data: blockWithNonceData)
        }
        return hash.uint256
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

 
//uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935
 
