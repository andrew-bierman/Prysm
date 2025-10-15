//
//  Item.swift
//  prism
//
//  Created by Andrew Bierman on 10/15/25.
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
