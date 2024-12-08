//
//  Item.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 12/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
