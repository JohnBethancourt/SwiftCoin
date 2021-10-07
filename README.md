# SwiftCoin

A blockchain implementation for macOS and iOS with a SwiftUI representation of one of the mining nodes. 

As is, creates two mining nodes and a mempool.
Transactions are added to the mempool and the mining nodes compete and mine to create the blocks containing the transactions.

Uses https://github.com/hyugit/UInt256 for storage of hash values 

Many tutorials unrealistically use text values for hashes or fake the mining process. This was an quick expirement to see how difficult it would be to implement. 

On iPad...

![ipad version](https://github.com/JohnBethancourt/SwiftCoin/blob/main/Shared/ipadCoin.jpg)

And Mac...

![Macbook screenshot](https://github.com/JohnBethancourt/SwiftCoin/blob/main/Shared/macCoin.png)
