//
//  WellnessAppApp.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI
import SwiftData

@main
struct WellnessAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, LoggedMeal.self, LoggedWorkout.self])
    }
}
