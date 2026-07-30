# Wellness App (iOS)

An iOS application built with SwiftUI and SwiftData implementing autoregulated metabolic modeling, energy expenditure tracking, and dynamic decision-friction reduction.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://apple.com/ios)
[![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-purple.svg)](https://developer.apple.com/documentation/swiftdata)

---

## Framework Based On Research Paper

This application serves as the reference implementation for empirical research on autoregulated energetics and cognitive load minimization in mobile health systems:

* **Paper Title:** *Autoregulated Energetics and Action-Line Friction Reduction in Mobile Health Systems*
* **Author:** Levi Daniel (2026)
* **Documentation & PDF:** Located in the [`/docs`](./WellnessApp/docs/904359059-Wellness_Application_Abandonment_Mitigation_Research_Paper.pdf) folder.

---

## Features

- **Energetics Engine:** Dynamically computes Total Daily Energy Expenditure (TDEE) via the Mifflin-St Jeor equation scaled across physical activity levels ($PAL \in [1, 10]$).
- **Predictive Action Cards:** One-tap contextual recommendations for meals and workouts designed to minimize decision-line friction ($L_{\text{extraneous}}$).
- **Autoregulated Workout Synthesis:** Tracks Rate of Perceived Exertion (RPE 1–10) to automatically suggest active recovery sessions and prevent central nervous system (CNS) overtraining.
- **Thermodynamic Plateau & Refeed Detection:** Flags severe late-day calorie deficits (>60% TDEE deficit past 18:00) and recommends autoregulated carbohydrate refeeds.
- **Local Persistence Layer:** Integrated with **SwiftData** and `UserDefaults` for persistent card confirmations and offline tracking.

---

## System Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                       DashboardView                         │
│   (MetabolicHeaderCard, Predictive Cards, Habit Tracker)    │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
    ┌────────────────────┐          ┌───────────────────┐
    │  MetabolicEngine   │          │  SwiftData Model  │
    │ (@ObservedObject)  │          │      Context      │
    └──────────┬─────────┘          └─────────┬─────────┘
               │                              │
               ▼                              ▼
    ┌────────────────────┐          ┌───────────────────┐
    │ Contextual Logic / │          │ LoggedMeal /      │
    │  Prediction Pool   │          │ LoggedWorkout     │
    └────────────────────┘          └───────────────────┘
