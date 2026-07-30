//
//  PredictiveRecommendation.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import Foundation

struct PredictiveRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: RecommendationCategory
    let estimatedCalories: Int
    let proteinGrams: Int
    let confidenceScore: Double
    
    enum RecommendationCategory {
        case meal
        case workout
        case plateauRefeed
    }
}
