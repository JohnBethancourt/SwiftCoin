//
//  World.swift
//  SwiftCoin
//
//  Created by John Bethancourt on 10/4/21.
//

import Foundation

#if DEBUG
var Current = World()
#else
let Current = World()
#endif

struct World {
  var date = { Date() }
}
