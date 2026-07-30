//
//  LoggedWorkout.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import Foundation
import SwiftData

@Model
final class LoggedWorkout {
    var id: UUID
    var title: String
    var rpe: Int // Rating of Perceived Exertion (1-10) [1]
    var durationMinutes: Int
    var timestamp: Date
    
    init(title: String, rpe: Int, durationMinutes: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.rpe = rpe
        self.durationMinutes = durationMinutes
        self.timestamp = timestamp
    }
}
