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
    // Full journal text
    var journal: String = ""
    
    // Mood (emoji or short descriptor)
    var mood: String = ""
    
    // Numeric mood value (0...2 used across the app)
    var value: Double = 0.0
    
    // Short summary of the entry (kept as 'summerize' to match existing code)
    var summerize: String = ""
    
    // Creation date
    var data: Date = Date.now
    
    init(journal: String, mood: String, value: Double, summerize: String, data: Date) {
        self.journal = journal
        self.mood = mood
        self.value = value
        self.summerize = summerize
        self.data = data
    }
}
