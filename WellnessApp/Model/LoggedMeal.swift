//
//  File.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import Foundation
import SwiftData

@Model
final class LoggedMeal {
    var id: UUID
    var title: String
    var calories: Int
    var proteinGrams: Int
    var timestamp: Date
    
    init(title: String, calories: Int, proteinGrams: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.timestamp = timestamp
    }
}
