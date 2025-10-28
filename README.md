# Pence

A modern Flutter app for tracking expenses and monthly budgets. Expetrack uses Firebase for authentication and cloud data sync, and local storage (Hive) for user settings. It features animated charts, real-time updates, and a clean, theme-aware UI.

## Features

- Email/Password authentication (Firebase Auth)
- Store budgets and transactions in Cloud Firestore
- Local settings storage (Hive) for:
  - Theme (Light/Dark)
  - Font size (if enabled in your settings)
- Automatic monthly budget bootstrap:
  - Creates default categories for the current month if missing
- Real-time UI with StreamBuilder
- Animated background charts on login/signup screen
- Line chart on Analytics (weekly spending trend)
- Donut, bar, pie, line, and area chart visuals
- Sign Up enhancements:
  - Full name capture and saved as Firebase User displayName
  - Confirm password
  - Terms & Conditions checkbox

## Tech Stack

- Flutter
- Firebase Auth
- Cloud Firestore
- Hive (settings only)
- Provider (state management)
- Custom painters for charts

## Project Structure (high-level)

- lib/
  - pages/
    - login_page.dart
    - budgeting.dart
    - transactions.dart
    - analytics.dart
    - settings.dart
  - components/
    - donut_chart.dart
    - line_chart.dart (if present)
    - other UI components
  - models/
    - monthly_budget.dart
    - budget_category.dart
    - transaction.dart
    - settings_state.dart
    - HiveService.dart (settings only)
  - providers/
    - theme_provider.dart
    - bottom_navbar_manager.dart
  - services/
    - firebase_service.dart
  - firebase_options.dart (generated)

## Data Model

Firestore (cloud):
- users/{uid}
  - name: string
  - email: string
  - createdAt: timestamp
  - budgets/{yyyy-MM}
    - monthYear: "YYYY-MM"
    - monthIncome: double
    - categories: [
      { name, budgetAmount, spentAmount, colorValue }
    ]
    - updatedAt: timestamp
  - transactions/{transactionId}
    - id: string
    - title: string
    - amount: string
    - category: string
    - description: string
    - createdAt: timestamp

Hive (local):
- settings box
  - isDarkMode: bool
  - fontSize: int

Note: All non-settings data previously stored in Hive has been migrated to Firestore. Old local budget and transaction boxes are removed.

## Getting Started

1) Prerequisites
- Flutter SDK installed
- Firebase project created

2) Configure Firebase
- Enable Email/Password sign-in in Firebase Auth
- Add Android app:
  - Package name: from android/app/src/main/AndroidManifest.xml (applicationId in build.gradle)
  - Download google-services.json to android/app/
- Add iOS app (optional for iOS build):
  - Download GoogleService-Info.plist to ios/Runner/
- Generate firebase_options.dart (recommended):
  ```bash
  flutter pub global activate flutterfire_cli
  flutterfire configure
  ```

3) Install dependencies
```bash
flutter pub get
```

4) Run the app (debug)
```bash
flutter run
```

## Build

Android APK (release):
```bash
flutter build apk --release
```

Android App Bundle:
```bash
flutter build appbundle --release
```

iOS (on macOS):
```bash
cd ios
pod install
cd ..
flutter build ios --release
```

## Theming and Settings

- Theme and other settings (like font size) are stored locally via Hive for instant access and persistence across sessions.
- Toggle theme via the Settings page. Theme changes propagate using Provider (ThemeProvider).

## Authentication

- Login: Email + Password
- Sign Up: Email + Password + Full Name + Confirm Password + Terms
- FirebaseService handles signIn, signUp, and signOut, and updates displayName on sign up.

## Budgets and Transactions

- Budgets and transactions are stored in Firestore under the user document.
- On first launch of a month (or if no budget exists), default categories are auto-created.
- Spending (spentAmount) updates when transactions are added/updated/deleted.

## Analytics

- Weekly spending trend displayed via a custom line chart
- Donut and other charts provide visual insights

## App Name

- Display name: Expetrack
- Updated in:
  - lib/main.dart (MaterialApp title)
  - Android: android/app/src/main/AndroidManifest.xml (label)
  - iOS: ios/Runner/Info.plist (CFBundleDisplayName/CFBundleName)

## Troubleshooting

Not enough disk space (Windows) during build:
- Clean Flutter/Gradle caches:
  ```powershell
  flutter clean
  cd android; ./gradlew clean; cd ..
  Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches
  ```
- Ensure at least 5–10 GB free on C: drive
- Retry build:
  ```powershell
  flutter build apk --release
  ```

Gradle lock error:
```powershell
cd android; ./gradlew --stop; cd ..
taskkill /F /IM java.exe
Remove-Item -Recurse -Force "android\.gradle\8.12\executionHistory"
flutter clean
flutter build apk --release
```

Firebase API keys in code:
- Mobile Firebase API keys are intended to be embedded in apps but secure access with:
  - Firestore Security Rules
  - App Check (optional)
- Avoid committing private service JSONs if not needed.

## Security Rules (example)

Set restrictive rules so users can only access their own data:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Contributing

- Open issues or PRs for bug fixes or improvements.
- Keep settings in Hive and all other data in Firestore.

## License

This project is provided as-is.
