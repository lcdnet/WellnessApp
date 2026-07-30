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
    
    @State private var showTDEEHelp: Bool = false
    
    var consumedCalories: Int {
        mealsToday.reduce(0) { $0 + $1.calories }
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
                    
                    HStack(spacing: 4) {
                        Text("TDEE Target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showTDEEHelp = true }) {
                            Image(systemName: "questionmark.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
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
        .alert("What is TDEE?", isPresented: $showTDEEHelp) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("TDEE (Total Daily Energy Expenditure) is an estimate of how many calories your body burns in a 24-hour period.\n\nIt combines your Basal Metabolic Rate (BMR) with your physical activity level. The engine uses this baseline target to calculate your daily energy budget and detect metabolic deficit trends.")
        }
    }
}

#Preview {
    MetabolicHeaderCard(profile: nil, mealsToday: [])
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}
