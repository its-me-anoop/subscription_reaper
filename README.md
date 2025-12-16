# Subscription Reaper

A "Cyber-Utility" Flutter application designed to track and cancel subscriptions with urgency. It replaces the boring spreadsheet look with a tactical, high-contrast interface that empowers users to cut waste.

## 🚀 Features

- **Onboarding (Intro Screens)**:
  - Immersive 3-slide carousel explaining the app's philosophy ("The Leak", "The List", "The Reaper").
  - Smooth transitions and haptic feedback.

- **The Hit List (Dashboard)**:
  - Visualizes subscriptions sorted by urgency (Critical < 48h, Warning < 7d).
  - "Swipe to Kill" interaction to mark subscriptions as cancelled.
  - Real-time calculation of monthly cost and projected yearly waste.

- **Add Target**:
  - Quick bottom-sheet interface to add new subscriptions.
  - "Quick Chips" for fast date entry (+1 Month, +1 Year, etc.).
  - Supports Monthly, Yearly, and Trial billing cycles.

- **Execution Room (Detail View)**:
  - Countdown timer to the exact renewal moment.
  - "How to Cancel" instructions with copyable links.
  - Satisfying "Reaped" action to remove the subscription.

## 🎨 Aesthetic: Cyber-Utility

- **Dark Mode by Default**: `#121212` background.
- **Neon Accents**: High-contrast Neon Red (`#FF3B30`) for danger/costs and Neon Green (`#34C759`) for actions/savings.
- **Typography**: Monospace fonts (`Roboto Mono`) for data/numbers, Bold Sans-Serif (`Inter`) for headers.

## 🛠️ Tech Stack

- **Flutter**: UI Framework.
- **Provider**: State Management.
- **Google Fonts**: Typography.
- **Intl**: Date formatting.
- **Uuid**: Unique identifiers.

## 🏃‍♂️ Getting Started

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd subscription_reaper
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

## 🧪 Testing

The project includes unit tests for models and providers, and widget tests for the UI.

Run all tests:
```bash
flutter test
```
