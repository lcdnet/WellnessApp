//
//  OneTapActionCard.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI

struct OneTapActionCard: View {
    let recommendation: PredictiveRecommendation
    let onConfirm: () -> Void
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(
                        recommendation.category == .workout ? "Autoregulated Training" : "Predictive Meal",
                        systemImage: recommendation.category == .workout ? "bolt.fill" : "sparkles"
                    )
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(recommendation.category == .plateauRefeed ? Color.orange.opacity(0.2) : Color.blue.opacity(0.15))
                    .foregroundColor(recommendation.category == .plateauRefeed ? .orange : .blue)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(Int(recommendation.confidenceScore * 100))% Match")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(recommendation.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if recommendation.category != .workout {
                        Label("~\(recommendation.estimatedCalories) kcal", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Label("~\(recommendation.proteinGrams)g Protein", systemImage: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Button(action: onConfirm) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Confirm")
                        }
                        .font(.footnote)
                        .fontWeight(.bold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
}

#Preview {
    OneTapActionCard(
        recommendation: PredictiveRecommendation(
            title: "Predictive Lunch Card",
            subtitle: "Auto-picked to reduce hassle on your end.",
            category: .meal,
            estimatedCalories: 500,
            proteinGrams: 35,
            confidenceScore: 0.92
        ),
        onConfirm: {}
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
