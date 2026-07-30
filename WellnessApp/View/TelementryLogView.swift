//
//  TelementryLogView.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI
import SwiftData

struct TelemetryLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LoggedMeal.timestamp, order: .reverse) private var loggedMeals: [LoggedMeal]
    @Query(sort: \LoggedWorkout.timestamp, order: .reverse) private var loggedWorkouts: [LoggedWorkout]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Logged Meals")) {
                    if loggedMeals.isEmpty {
                        ContentUnavailableView(
                            "No Meals Recorded",
                            systemImage: "fork.knife",
                            description: Text("Confirm a predictive action card or log a meal manually.")
                        )
                    } else {
                        ForEach(loggedMeals) { meal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meal.title).font(.headline)
                                    Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(meal.calories) kcal").bold()
                                    Text("\(meal.proteinGrams)g protein").font(.caption).foregroundColor(.green)
                                }
                            }
                        }
                        .onDelete(perform: deleteMeal)
                    }
                }
                
                Section(header: Text("Logged Workouts")) {
                    if loggedWorkouts.isEmpty {
                        ContentUnavailableView(
                            "No Workouts Recorded",
                            systemImage: "figure.run",
                            description: Text("Completed workouts will appear here.")
                        )
                    } else {
                        ForEach(loggedWorkouts) { workout in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(workout.title).font(.headline)
                                    Text(workout.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(workout.durationMinutes) min").bold()
                                    Text("RPE \(workout.rpe)").font(.caption).foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                }
            }
            .navigationTitle("Telemetry Log")
        }
    }
    
    private func deleteMeal(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(loggedMeals[index])
        }
    }
    
    private func deleteWorkout(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(loggedWorkouts[index])
        }
    }
}

#Preview {
    TelemetryLogView()
        .modelContainer(for: [LoggedMeal.self, LoggedWorkout.self], inMemory: true)
}
