//
//  Item.swift
//  HH
//
//  Created by ooo on 2025/7/5.
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
