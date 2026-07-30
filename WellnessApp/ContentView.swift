//
//  ContentView.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var metabolicEngine = MetabolicEngine()
    
    // Check if user has completed profile setup before; default to Profile tab (2) if false
    @AppStorage("hasCompletedProfileSetup") private var hasCompletedProfileSetup: Bool = false
    @State private var selectedTab: Int
    
    init() {
        // Reads initial state directly to set default tab
        let isSetup = UserDefaults.standard.bool(forKey: "hasCompletedProfileSetup")
        _selectedTab = State(initialValue: isSetup ? 0 : 2)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(metabolicEngine: metabolicEngine)
                .tabItem {
                    Label("Today", systemImage: "sparkles")
                }
                .tag(0)
            
            TelemetryLogView()
                .tabItem {
                    Label("History", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            ProfileSetupView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, LoggedMeal.self, LoggedWorkout.self], inMemory: true)
}
