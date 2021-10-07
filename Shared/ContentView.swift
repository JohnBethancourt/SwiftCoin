//
//  ContentView.swift
//  Shared
//
//  Created by John Bethancourt on 10/2/21.
//

import SwiftUI
import CryptoKit

 
struct ContentView: View {
 
    @StateObject var selectedBlockchainNode: BlockchainNode
    @State var colorCount = 1
    @StateObject var simMemoryPool: MemoryPool
    
    
    init() {
        let memoryPool = MemoryPool()
        _simMemoryPool = StateObject(wrappedValue: memoryPool)
      
        let blockchain = BlockchainNode(memoryPool: memoryPool)
        _selectedBlockchainNode =  StateObject(wrappedValue: blockchain)
        
        let _ = BlockchainNode(memoryPool: memoryPool)
        
        let transaction1 = MonetaryTransaction(from: "Mary", to: "John", amount: 10.01)
        let transaction2 = MonetaryTransaction(from: "John", to: "Stan", amount: 20.78)
        let transaction3 = MonetaryTransaction(from: "Dale", to: "Jane", amount: 23.58)
        let transaction4 = MonetaryTransaction(from: "Tron", to: "Dave", amount: 11.12)
        let transaction5 = MonetaryTransaction(from: "Beth", to: "Mark", amount: 22.33)
        memoryPool.addTransactions([transaction1, transaction2, transaction3, transaction4, transaction5])

    }
    
    var body: some View {
        VStack {
            Button {
                let transaction1 = MonetaryTransaction(from: "Bobo", to: "Fran", amount: Double.random(in: 0.001...9999.99))
                simMemoryPool.addTransactions([transaction1])
                
            } label:  {
                Text("Add Transaction")
            }
            .padding()
            VStack {
                List {
                    ForEach(selectedBlockchainNode.blocks.indices, id: \.self) { index in
                       
                        HStack {
                            VStack {
                                Text("Block #: \(selectedBlockchainNode.blocks[index].index)")
                                Text("Mined By: \(String(selectedBlockchainNode.blocks[index].minedBy.uuidString.suffix(2)))")
                                    .foregroundColor(.gray)
                            }
                           
                            VStack {
                                Text(selectedBlockchainNode.blocks[index].previousHash.description.truncatedWith(first: 8, last: 4))
                                    .foregroundColor((index - 1) % 2 == 0 ? Color.blue : Color.yellow)
                                Text(selectedBlockchainNode.blocks[index].hash.description.truncatedWith(first: 8, last: 4))
                                    .foregroundColor(index % 2 == 0 ? Color.blue : Color.yellow)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Timestamp: \(selectedBlockchainNode.blocks[index].timestamp)")
                                Text("Transactions: \(selectedBlockchainNode.blocks[index].transactions.count)")
                                    .help("\(selectedBlockchainNode.blocks[index].textSummary)")
                            }
                            
                            .padding(.leading, 20)
                            
                        }
                     
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                      
                        .font(.system(.body, design: .monospaced))
                        
                        if index != selectedBlockchainNode.blocks.count - 1 {
                            Image(systemName: "link")
                                .padding(.leading, 20)
                                .foregroundColor(index % 2 == 0 ? Color.blue : Color.yellow)
                        }
                        
                    }
                
                }
            }
            VStack {
                Text(selectedBlockchainNode.currentMiningResult)
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
 



 
//uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935
 
