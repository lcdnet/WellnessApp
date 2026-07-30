//
//  AddWorkoutSheet.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var durationMinutes: String = "30"
    @State private var rpe: Double = 7.0
    @State private var showRPEHelp: Bool = false
    
    var onSave: (String, Int, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Telemetry")) {
                    TextField("Workout Title (e.g., Upper Body Hypertrophy)", text: $title)
                    
                    HStack {
                        Text("Duration (Mins)")
                        Spacer()
                        TextField("30", text: $durationMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header:
                    HStack {
                        Text("Rate of Perceived Exertion (RPE 1–10)")
                        Button(action: { showRPEHelp = true }) {
                            Image(systemName: "questionmark.circle")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                ) {
                    Slider(value: $rpe, in: 1.0...10.0, step: 0.5)
                    
                    HStack {
                        Text("Exertion Index:")
                        Spacer()
                        Text("RPE \(rpe, specifier: "%.1f")")
                            .bold()
                            .foregroundColor(rpe > 7.5 ? .red : .blue)
                    }
                }
            }
            .navigationTitle("Log Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let mins = Int(durationMinutes) ?? 30
                        onSave(title.isEmpty ? "Autoregulated Session" : title, Int(rpe), mins)
                        dismiss()
                    }
                }
            }
            .alert("What is RPE?", isPresented: $showRPEHelp) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text("RPE (Rate of Perceived Exertion) measures workout intensity on a scale of 1 to 10:\n\n• 1–4: Light effort / Easy walk\n• 5–6: Moderate / Conversational pace\n• 7–8: Hard / 1 to 3 repetitions left in the tank\n• 9–10: Maximal effort / Absolute failure\n\nThe app uses this score to adjust neural recovery windows for future recommendations.")
            }
        }
    }
}
