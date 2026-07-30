//
//  Dashboard.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \LoggedMeal.timestamp, order: .reverse) private var loggedMeals: [LoggedMeal]
    @Query(sort: \LoggedWorkout.timestamp, order: .reverse) private var loggedWorkouts: [LoggedWorkout]
    
    @ObservedObject var metabolicEngine: MetabolicEngine
    
    private enum ActiveSheet: Identifiable {
        case meal
        case workout
        var id: Int { hashValue }
    }
    
    @State private var activeSheet: ActiveSheet? = nil
    @State private var showPaperCredits: Bool = false
    
    var activeProfile: UserProfile? {
        userProfiles.first
    }
    
    private var isLateEvening: Bool {
        Calendar.current.component(.hour, from: Date()) >= 20
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Biological Energetics Card
                    MetabolicHeaderCard(profile: activeProfile, mealsToday: loggedMeals)
                    
                    // Action Line Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Predictive Action Cards")
                            .font(.title3)
                            .bold()
                        
                        Text("Auto-determined based on recent activity.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if metabolicEngine.isLoadingRecommendations {
                            HStack {
                                Spacer()
                                ProgressView("Evaluating Latent User Vector...")
                                Spacer()
                            }
                            .padding(.vertical, 30)
                        } else if activeProfile == nil {
                            ContentUnavailableView(
                                "Profile Required",
                                systemImage: "person.badge.plus",
                                description: Text("Setup your profile details so the system can build baseline predictions.")
                            )
                        } else if metabolicEngine.predictiveCards.isEmpty {
                            if isLateEvening {
                                ContentUnavailableView(
                                    "Day Complete!",
                                    systemImage: "moon.stars.fill",
                                    description: Text("You've completed your recommendations for today. Great job keeping your cognitive load low!")
                                )
                            } else {
                                ContentUnavailableView(
                                    "Keep it up today!",
                                    systemImage: "sparkles",
                                    description: Text("You've completed your current recommendation. Check back later in the day for your next action card!")
                                )
                            }
                        } else {
                            ForEach(metabolicEngine.predictiveCards) { card in
                                OneTapActionCard(recommendation: card) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        executeOneTapConfirmation(card)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    
                    // Habit Formation Progress Widget (Counts combined meal and workout logs)
                    HabitTrackerWidget(
                        currentLogsCount: loggedMeals.count + loggedWorkouts.count,
                        targetThreshold: 66
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showPaperCredits = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { activeSheet = .meal }) {
                            Label("Log Meal", systemImage: "fork.knife")
                        }
                        
                        Button(action: { activeSheet = .workout }) {
                            Label("Log Workout", systemImage: "figure.run")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                let engine = metabolicEngine
                let meals = Array(loggedMeals)
                let workouts = Array(loggedWorkouts)
                let profile = activeProfile
                
                if engine.predictiveCards.isEmpty && engine.confirmedIDs.isEmpty {
                    engine.generateContextualRecommendations(
                        profile: profile,
                        recentMeals: meals,
                        recentWorkouts: workouts
                    )
                }
            }
            .sheet(item: $activeSheet) { item in
                switch item {
                case .meal:
                    AddMealSheet { title, calories, protein in
                        let meal = LoggedMeal(title: title, calories: calories, proteinGrams: protein)
                        modelContext.insert(meal)
                    }
                case .workout:
                    AddWorkoutSheet { title, rpe, durationMinutes in
                        let workout = LoggedWorkout(title: title, rpe: rpe, durationMinutes: durationMinutes)
                        modelContext.insert(workout)
                    }
                }
            }
            .sheet(isPresented: $showPaperCredits) {
                NavigationView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theoretical Framework")
                            .font(.title2)
                            .bold()
                        
                        Text("This app implements autoregulated metabolic modeling and cognitive load reduction principles based on published empirical research.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Repository & Documentation:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Levi Daniel, \"Autoregulated Energetics and Action-Line Friction Reduction in Mobile Health Systems.\" Open Source GitHub Documentation, 2026.")
                                .font(.callout)
                                .italic()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        if let githubURL = URL(string: "https://github.com/lcdnet/WellnessApp") {
                            Link(destination: githubURL) {
                                HStack {
                                    Spacer()
                                    Label("View on GitHub & Read Paper", systemImage: "arrow.up.right.square")
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .navigationTitle("Research & Source Code")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showPaperCredits = false }
                        }
                    }
                }
            }
        }
    }
    
    private func executeOneTapConfirmation(_ card: PredictiveRecommendation) {
        if card.category == .meal || card.category == .plateauRefeed {
            let newMeal = LoggedMeal(title: card.title, calories: card.estimatedCalories, proteinGrams: card.proteinGrams)
            modelContext.insert(newMeal)
        } else if card.category == .workout {
            let newWorkout = LoggedWorkout(title: card.title, rpe: 7, durationMinutes: 20)
            modelContext.insert(newWorkout)
        }
        
        metabolicEngine.confirmRecommendation(card)
    }
}
