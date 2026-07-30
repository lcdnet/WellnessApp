//
//  MetabolicHeaderCard.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI

struct MetabolicHeaderCard: View {
    
    let profile: UserProfile?
    let mealsToday: [LoggedMeal]
    
    var consumedCalories: Int {
        mealsToday.reduce(0) {$0 + $1.calories}
    }
    
    var tdeeTarget: Int {
        Int(profile?.tdee ?? 0.0)
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("METABOLIC ENERGETICS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(tdeeTarget)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("Reach This Many Calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(consumedCalories)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(tdeeTarget > 0 && consumedCalories > tdeeTarget ? .orange : .primary)
                        Text("Logged Today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
}

#Preview {
    MetabolicHeaderCard(profile: nil, mealsToday: [])
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}
