//
//  MetabolicEngine.swift
//  WellnessApp
//
//  Created by Levi Daniel on 7/30/26.
//

import Foundation
import Combine

@MainActor
class MetabolicEngine: ObservableObject {
    @Published var isLoadingRecommendations: Bool = false
    @Published var predictiveCards: [PredictiveRecommendation] = []
    @Published var detectedPlateau: Bool = false
    @Published var errorMessage: String? = nil
    
    // Persist confirmed IDs in UserDefaults across app restarts
    @Published private(set) var confirmedIDs: Set<String> = [] {
        didSet {
            UserDefaults.standard.set(Array(confirmedIDs), forKey: "ConfirmedRecommendationIDs")
        }
    }
    
    init() {
        if let savedIDs = UserDefaults.standard.stringArray(forKey: "ConfirmedRecommendationIDs") {
            self.confirmedIDs = Set(savedIDs)
        }
    }
    
    func confirmRecommendation(_ card: PredictiveRecommendation) {
        confirmedIDs.insert(card.id.uuidString)
        predictiveCards.removeAll { $0.id == card.id }
    }
    
    func generateContextualRecommendations(
        profile: UserProfile?,
        recentMeals: [LoggedMeal],
        recentWorkouts: [LoggedWorkout] = []
    ) {
        guard let profile = profile else {
            self.predictiveCards = []
            return
        }
        
        isLoadingRecommendations = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isLoadingRecommendations = false
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: Date())
            var items: [PredictiveRecommendation] = []
            
            // Calculate Today's Macro & Energy Totals
            let mealsToday = recentMeals.filter { calendar.isDateInToday($0.timestamp) }
            let loggedTodayCalories = mealsToday.reduce(0) { $0 + $1.calories }
            let remainingCalories = max(0, Int(profile.tdee) - loggedTodayCalories)
            
            // Evaluate Dynamic Thermodynamic Plateau / Refeed Card
            if loggedTodayCalories < Int(profile.tdee * 0.4) && hour > 18 {
                self.detectedPlateau = true
                items.append(PredictiveRecommendation(
                    title: "Metabolic Refeed Protocol",
                    subtitle: "Thermodynamic model detected steep deficit (>60%). Tap to confirm carbohydrate refeed.",
                    category: .plateauRefeed,
                    estimatedCalories: min(remainingCalories, 450),
                    proteinGrams: 25,
                    confidenceScore: 0.96
                ))
            } else {
                self.detectedPlateau = false
            }
            
            // Predictive Meal Synthesis Engine
            if let predictedMeal = self.predictNextMeal(
                history: recentMeals,
                mealsToday: mealsToday,
                currentHour: hour,
                remainingCalories: remainingCalories
            ) {
                items.append(predictedMeal)
            }
            
            // Autoregulated Workout Synthesis Engine
            if let predictedWorkout = self.predictNextWorkout(
                history: recentWorkouts,
                workoutsToday: recentWorkouts.filter({ calendar.isDateInToday($0.timestamp) })
            ) {
                items.append(predictedWorkout)
            }
            
            // Filter out confirmed items or meals logged in today's history
            let todayMealTitles = Set(mealsToday.map { $0.title })
            self.predictiveCards = items.filter { card in
                !todayMealTitles.contains(card.title) && !self.confirmedIDs.contains(card.id.uuidString)
            }
        }
    }
    
    // MARK: - Prediction Logic Methods
    
    private func predictNextMeal(
        history: [LoggedMeal],
        mealsToday: [LoggedMeal],
        currentHour: Int,
        remainingCalories: Int
    ) -> PredictiveRecommendation? {
        
        let mealSlot: String = {
            if currentHour < 11 { return "Breakfast" }
            if currentHour < 16 { return "Lunch" }
            return "Dinner"
        }()
        
        // Cold-start fallback pool when user has no past logs
        let fallbackPool: [(title: String, kcal: Int, protein: Int)] = [
            ("Oatmeal & Whey Protein", 380, 28),
            ("Grilled Chicken Bowl", 520, 42),
            ("Salmon, Quinoa & Greens", 610, 45),
            ("Greek Yogurt Parfait", 300, 24),
            ("Turkey & Avocado Wrap", 450, 32)
        ]
        
        let uniqueHistoricalMeals = Dictionary(grouping: history, by: { $0.title })
            .compactMap { (title, occurrences) -> (title: String, avgKcal: Int, avgProtein: Int, count: Int)? in
                guard !title.isEmpty else { return nil }
                let avgKcal = occurrences.reduce(0) { $0 + $1.calories } / occurrences.count
                let avgProt = occurrences.reduce(0) { $0 + $1.proteinGrams } / occurrences.count
                return (title: title, avgKcal: avgKcal, avgProtein: avgProt, count: occurrences.count)
            }
        
        let todayTitles = Set(mealsToday.map { $0.title })
        let candidates = uniqueHistoricalMeals.filter { !todayTitles.contains($0.title) }
        
        var selectedTitle: String
        var estimatedKcal: Int
        var estimatedProtein: Int
        var confidenceScore: Double
        var subtitleText: String
        
        if let topCandidate = candidates.max(by: { $0.count < $1.count }) {
            // Personalized prediction based on user logs
            selectedTitle = topCandidate.title
            estimatedKcal = topCandidate.avgKcal
            estimatedProtein = topCandidate.avgProtein
            confidenceScore = min(0.95, 0.75 + (Double(topCandidate.count) * 0.04))
            subtitleText = "Based on past logs & remaining TDEE"
        } else if let fallback = fallbackPool.filter({ !todayTitles.contains($0.title) }).randomElement() {
            // Cold-start baseline for new users
            selectedTitle = fallback.title
            estimatedKcal = fallback.kcal
            estimatedProtein = fallback.protein
            confidenceScore = 0.70
            subtitleText = "Initial baseline recommendation • Log meals to refine predictions"
        } else {
            return nil
        }
        
        if remainingCalories > 0 && estimatedKcal > remainingCalories {
            estimatedKcal = remainingCalories
            estimatedProtein = max(10, Int(Double(estimatedProtein) * (Double(remainingCalories) / Double(estimatedKcal))))
        }
        
        return PredictiveRecommendation(
            title: "Predictive \(mealSlot): \(selectedTitle)",
            subtitle: subtitleText,
            category: .meal,
            estimatedCalories: estimatedKcal,
            proteinGrams: estimatedProtein,
            confidenceScore: confidenceScore
        )
    }
    
    private func predictNextWorkout(
        history: [LoggedWorkout],
        workoutsToday: [LoggedWorkout]
    ) -> PredictiveRecommendation? {
        
        if !workoutsToday.isEmpty {
            return PredictiveRecommendation(
                title: "Active Recovery & Mobility Work",
                subtitle: "Autoregulated • Prevents CNS overtraining after today's session",
                category: .workout,
                estimatedCalories: 100,
                proteinGrams: 0,
                confidenceScore: 0.90
            )
        }
        
        let avgRPE: Double = {
            guard !history.isEmpty else { return 5.0 }
            let recent = history.prefix(5)
            return Double(recent.reduce(0) { $0 + Int($1.rpe) }) / Double(recent.count)
        }()
        
        if avgRPE >= 8.0 {
            return PredictiveRecommendation(
                title: "Autoregulated Session: 20-Min LISS Cardio",
                subtitle: "High recent RPE detected • Adapted to reduce neural fatigue",
                category: .workout,
                estimatedCalories: 160,
                proteinGrams: 0,
                confidenceScore: 0.88
            )
        } else {
            let subtitle = history.isEmpty
                ? "Initial baseline session • Adjusts as you log exertion RPE"
                : "Optimal recovery window • Based on past workout volume"
            
            return PredictiveRecommendation(
                title: "Autoregulated Session: Hypertrophy Resistance",
                subtitle: subtitle,
                category: .workout,
                estimatedCalories: 280,
                proteinGrams: 0,
                confidenceScore: 0.86
            )
        }
    }
    
    // MARK: - Activity Level Split Helper
    
    func recommendedSplit(forActivityLevel level: Int) -> (splitTitle: String, description: String) {
        switch level {
        case 1:
            return ("2-Day Full Body Circuit", "Focus on fundamental mobility and low-threshold motor activation.")
        case 2:
            return ("3-Day Full Body A/B", "Alternating light resistance and zone 2 steady-state cardio.")
        case 3:
            return ("3-Day Push / Pull / Legs", "Standard 3-day split allowing 48 hours recovery between sessions.")
        case 4:
            return ("4-Day Upper / Lower Split", "4-day structure (Mon/Tue/Thu/Fri) optimizing volume distribution.")
        case 5:
            return ("4-Day Push / Pull / Legs / Upper", "Balanced hypertrophy split scaled for active energy expenditure.")
        case 6:
            return ("5-Day Push / Pull / Legs / Upper / Lower", "Elevated weekly frequency with strict intrasession volume caps.")
        case 7:
            return ("5-Day PPL + HIIT Conditioning", "High metabolic demand requiring proactive nutritional refeeds.")
        case 8:
            return ("6-Day Push / Pull / Legs (2x)", "Athletic volume cycle managed via 5-session rolling RPE averages.")
        case 9:
            return ("6-Day Functional Hypertrophy", "Advanced high-frequency training with mandatory mobility days.")
        case 10:
            return ("3-Day Strength + 3-Day Active Recovery", "Resistance volume is reduced to prevent CNS fatigue under extreme daily expenditure.")
        default:
            return ("3-Day Full Body", "Balanced entry-level training cadence.")
        }
    }
}
