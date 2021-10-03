//
//  ContentView.swift
//  Shared
//
//  Created by John Bethancourt on 10/2/21.
//

import SwiftUI
import CryptoKit
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                let inputString = "Hello, world!"
                var inputData = Data(inputString.utf8)
                 
                 let zeroes = [UInt8](repeating: 0,  count: 256 / 8)
                inputData = withUnsafeBytes(of: zeroes) { Data($0) }
                let hashed = SHA256.hash(data: inputData)
                let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
                print(hashString)
                
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}



struct Block {
    var index: Int
    var previousHash: UInt256
    var hash: UInt256 = 0
    var nonce: Int
    var nonceeee: UUID
    let digest = SHA256.hash(data: Data())

}

struct Transaction {
    var from: String
    var to: String
    var amount: Double
}

struct Blockchain {
    
}

extension SHA256.Digest {
    
}
//uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935


