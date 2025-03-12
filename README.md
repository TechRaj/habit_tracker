# 🚀 Habit Tracker App

A **simple, engaging, and user-friendly** habit tracker app built with **Flutter**. This app helps users build positive habits while eliminating negative behaviors through **streak tracking, insightful analytics, and a sleek UI/UX**. By providing **daily tracking, visual progress indicators, and smart habit history**, the app keeps users motivated and accountable.

![Home page](UI%20screenshots/main_screen.png)
![Power habits page](UI%20screenshots/power_habits.png)
![Limit habits page](UI%20screenshots/limit_habits.png)
---

## 📌 Features

### ✅ Daily Habit Logging
- **Log habits daily** using:
  - **Increment/decrement buttons** for quick updates.
  - **Manual entry** for more precise tracking.
- **Two types of habits:**
  - 🚀 **Power Habits** – Encourages positive actions (e.g., exercise, reading).
  - 🔒 **Limit Habits** – Helps users stay within constraints (e.g., screen time, spending).
- **Fully customisable** – Add or modify habits with ease.

### 📅 Habit Streaks & History
- **Track habit streaks** with a 🔥 counter next to each progress bar.
- **Expandable habit widget** shows:
  - **Consistency score** for long-term progress.
  - **Past 7 days history** using emoji-based logging:
    - 🟢 **Completed**
    - 🔴 **Missed**
    - ⚪ **Not Started Yet**

### 📊 Insights & Analytics
- **📊 Daily Progress Tracker**
  - Displays the **total number of habits completed for the day**.
  - Helps users stay accountable and motivated.

- **📅 Weekly Progress Graph**
  - **Visualises habit performance over the past week**.
  - **Color-coded bars**:
    - 🟢 **Green** = Power Habits successfully completed.
    - 🔴 **Red** = Limit Habits successfully adhered to.
  - Aids in spotting patterns and optimising habits.

- **🏆 Top 3 Best Habits Podium**
  - Highlights the **most consistent habits**.
  - Ranks top habits based on **streak count & completion percentage**.

### 🎉 Engaging UI/UX
- **🎊 Confetti animations** for **achieving goals**.
- **👎 Boo-ing Confetti animations** for **failing limit habits**.
- **Minimalist, sleek UI** with **smooth colour transitions**.

### 📱 Seamless Navigation
- **Swipe between pages** with **color transition animations**.
- **Swipe-to-delete habits** with confirmation prompts for quick habit management.

---

## 🛠 Tech Stack
- **Flutter** (Dart)
- **SharedPreferences** (Local Storage)
- **Google Fonts** (Custom Styling)
- **Confetti Package** (Animations)

---

## 🚀 Getting Started

## 🔧 Prerequisites
- Flutter SDK installed ([Install Guide](https://docs.flutter.dev/get-started/install))
- Android Studio / Xcode for mobile development
- Chrome (for web deployment)

### 1️⃣ Clone the Repository
```sh
git clone https://github.com/TechRaj/habit-tracker
cd habit-tracker
```
### 2️⃣ Install Dependencies
```sh
flutter pub get  
```

### 3️⃣ Run the App

#### 📱 For Mobile (iOS/Android)
- **Android Emulator / Physical Device:**
  ```sh
  flutter run
  ```
  Ensure you have an emulator running or a physical device connected via USB with developer mode enabled.
  
- **iOS Simulator / Physical Device:**
  ```sh
  flutter run -d ios
  ```
  Ensure you have Xcode installed and an iOS simulator running, or a physical device connected and trusted.
  
#### 💻 For Web (Chrome)
- **Run on Chrome Browser:**
  ```sh
  flutter run -d chrome
  ```
  Ensure you have Chrome installed and configured for Flutter web development.
  
#### 🖥️ For Desktop (Mac/Windows)
- **Mac (macOS):**
  ```sh
  flutter run -d macos
  ```
  Requires Flutter desktop support enabled and macOS Catalina (10.15) or later.
  
- **Windows:**
  ```sh
  flutter run -d windows
  ```
  Requires Flutter desktop support enabled and Windows 10 or later.

## 🏆 Future Enhancements

- **Comprehensive Habit Logging:** Introduce a **calendar view with a heatmap** to provide a visual representation of habit completion trends over time.  
- **Achievement System:** Implement **badges and milestone rewards** for users who maintain streaks or achieve high consistency rates to encourage user engagement by rearding long-term commitment.  
- **Dark Mode Support:** Provide a **customisable theme option** to enhance user accessibility and experience.  
- **Cross-Device Synchronisation:** Enable seamless habit tracking across multiple devices using **Firebase integration**, making tracking seemless.  
- **Automated Habit Tracking:** Integrate APIs such as **Apple HealthKit and banking APIs** to **reduce manual entry** for fitness and financial habits.  
- **Home & Lock Screen Widgets:** Develop **interactive widgets** for quick habit updates and progress tracking without opening the app.  
- **Smart Reminders & Notifications:** Implement **personalised push notifications** to remind users of pending habits before the day ends, improving consistency.  
