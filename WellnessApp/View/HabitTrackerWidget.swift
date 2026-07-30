//
//  HabitTrackerWidget.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI

struct HabitTrackerWidget: View {
    let currentLogsCount: Int
    let targetThreshold: Int
    
    init(currentLogsCount: Int = 0, targetThreshold: Int = 66) {
        self.currentLogsCount = currentLogsCount
        self.targetThreshold = targetThreshold
    }
    
    var percentage: Int {
        guard targetThreshold > 0 else { return 0 }
        return min(100, Int((Double(currentLogsCount) / Double(targetThreshold)) * 100))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.green)
                Text("Habit Formation Progress")
                    .font(.headline)
            }
            
            ProgressView(value: Double(currentLogsCount), total: Double(targetThreshold))
                .tint(.green)
            
            HStack {
                Text("\(currentLogsCount) of \(targetThreshold) Actions Recorded")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(percentage)% Complete")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    HabitTrackerWidget(currentLogsCount: 5, targetThreshold: 66)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}
