//
//  UserProfile.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var age: Int
    var heightCm: Double
    var weightKg: Double
    var isMale: Bool
    var activityLevel: Double // PAL Multiplier, 1.2-1.9
    
    init(
        name: String = "",
        age: Int = 18,
        heightCm: Double = 170.0,
        weightKg: Double = 70.0,
        isMale: Bool = true,
        activityLevel: Double = 1.2
    ) {
        self.name = name
        self.age = age
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.isMale = isMale
        self.activityLevel = activityLevel
    }
    
    // MIFFLIN-ST JEOR BASAL METABOLIC RATE EQUATION [1]
    var bmr: Double {
        let genderOffset: Double = isMale ? 5.0 : -161.0
        return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age)) + genderOffset
    }
    
    // TOTAL DAILY ENERGY EXPENDITURE (TDEE) [1]
    var tdee: Double {
        return bmr * activityLevel
    }
}
