//
//  Item.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 06/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var journal: String
    var mood: String
    var value: Int
    var summerize: String
    var data: Date
    
    init(journal: String, mood: String, value: Int, summerize: String, data: Date) {
        self.journal = journal
        self.mood = mood
        self.value = value
        self.summerize = summerize
        self.data = data
    }}
