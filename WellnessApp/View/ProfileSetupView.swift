//
//  ProfileSetupView.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @AppStorage("hasCompletedProfileSetup") private var hasCompletedProfileSetup: Bool = false
    
    enum Field { case name, age, height, weight }
    @FocusState private var focusedField: Field?
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var heightCm: String = ""
    @State private var weightKg: String = ""
    @State private var isMale: Bool = true
    @State private var activityLevel: Double = 5.0 // Scaled 1 to 10
    
    var existingProfile: UserProfile? {
        userProfiles.first
    }
    
    var recommendedSplit: String {
        switch Int(activityLevel) {
        case 1...2:
            return "2-Day Full Body Movement / Active Recovery"
        case 3...4:
            return "3-Day Full Body Strength & Mobility"
        case 5...6:
            return "4-Day Upper / Lower Split"
        case 7...8:
            return "5-Day Push / Pull / Legs + Upper / Lower"
        case 9...10:
            return "6-Day Push / Pull / Legs (High Volume)"
        default:
            return "Custom Adaptive Split"
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Biometric Data")) {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .age)
                        .submitLabel(.next)
                    
                    TextField("Height (cm)", text: $heightCm)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .height)
                        .submitLabel(.next)
                    
                    TextField("Weight (kg)", text: $weightKg)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .submitLabel(.done)
                    
                    Picker("Biological Sex", selection: $isMale) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Activity Scale (1 to 10)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Level: \(Int(activityLevel)) / 10")
                                .bold()
                            Spacer()
                        }
                        
                        Slider(value: $activityLevel, in: 1...10, step: 1)
                        
                        Text("Recommended Split:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(recommendedSplit)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text(existingProfile == nil ? "Create Profile" : "Update Profile")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onSubmit {
                switch focusedField {
                case .name: focusedField = .age
                case .age: focusedField = .height
                case .height: focusedField = .weight
                default: focusedField = nil
                }
            }
            .navigationTitle("User Profile")
            .onAppear(perform: loadExistingData)
        }
    }
    
    private func loadExistingData() {
        if let profile = existingProfile {
            name = profile.name
            age = String(profile.age)
            heightCm = String(profile.heightCm)
            weightKg = String(profile.weightKg)
            isMale = profile.isMale
            activityLevel = profile.activityLevel
        }
    }
    
    private func saveProfile() {
        focusedField = nil
        
        let ageInt = Int(age) ?? 18
        let heightDbl = Double(heightCm) ?? 170.0
        let weightDbl = Double(weightKg) ?? 70.0
        
        if let profile = existingProfile {
            profile.name = name
            profile.age = ageInt
            profile.heightCm = heightDbl
            profile.weightKg = weightDbl
            profile.isMale = isMale
            profile.activityLevel = activityLevel
        } else {
            let newProfile = UserProfile(
                name: name,
                age: ageInt,
                heightCm: heightDbl,
                weightKg: weightDbl,
                isMale: isMale,
                activityLevel: activityLevel
            )
            modelContext.insert(newProfile)
        }
        
        hasCompletedProfileSetup = true
    }
}
