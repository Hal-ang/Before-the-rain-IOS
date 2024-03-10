//
//  Item.swift
//  beforeTheRain
//
//  Created by 정하랑 on 3/10/24.
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
