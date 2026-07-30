//
//  AddMealSheet.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI

import SwiftUI

struct AddMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var customMealTitle: String = ""
    @State private var customMealCalories: String = ""
    @State private var customMealProtein: String = ""
    
    let onSave: (String, Int, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Manual Entry (High Friction Alternative)")) {
                    TextField("Meal Title", text: $customMealTitle)
                    TextField("Calories", text: $customMealCalories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $customMealProtein)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let calories = Int(customMealCalories), let protein = Int(customMealProtein) {
                            onSave(customMealTitle, calories, protein)
                        }
                        dismiss()
                    }
                    .disabled(customMealTitle.isEmpty || customMealCalories.isEmpty || customMealProtein.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMealSheet(onSave: { _, _, _ in })
}
