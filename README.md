# 🏠 RentHelper - iOS Rental Listing Application

RentHelper is a SwiftUI-based iOS application that allows users to browse rental properties, authenticate securely, and persist favorite listings locally.

The project demonstrates a hybrid mobile architecture combining:

* 🔐 Firebase Authentication
* ☁️ Firebase Firestore (Cloud Database)
* 💾 CoreData (Local Persistence)
* 🧭 MVVM Architecture
* 🗺️ MapKit (planned)
* 💳 Stripe (planned)

The application is developed through **three structured iterations**, progressively building from architecture setup to fully working user flows.

---

# 📌 Project Overview

RentHelper simulates a rental discovery platform where users can:

* Create an account
* Log in securely
* Browse rental listings
* View detailed property information
* Save listings as favorites
* Persist favorites after app restart

The design separates:

* Cloud-based listing data (Firestore)
* Authentication (Firebase Auth)
* Local user persistence (CoreData)

---

# 🏗 Architecture

The project follows the MVVM pattern:

```
Views → ViewModels → Services → Firebase / CoreData
```

### Layers

**Views**

* SwiftUI screens
* NavigationStack + TabView
* State-driven UI updates

**ViewModels**

* Manage loading states
* Handle async operations
* Expose data to UI

**Services**

* `AuthService` → Firebase Authentication
* `ListingService` → Firestore integration layer

**Persistence**

* CoreData stack
* `FavoriteListing` entity
* User-specific local storage

---


# 🔐 Security Notes

* `GoogleService-Info.plist` is not committed to GitHub
* Stripe secret keys are never stored client-side
* Firestore rules restrict write access
* Favorites stored locally to reduce cloud exposure

---

# 🛠 Tech Stack

| Layer             | Technology       |
| ----------------- | ---------------- |
| UI                | SwiftUI          |
| Architecture      | MVVM             |
| Authentication    | Firebase Auth    |
| Cloud Database    | Firestore        |
| Local Persistence | CoreData         |
| Maps              | MapKit (planned) |
| Payments          | Stripe (planned) |

---

# 🚀 How to Run

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/negarprh/Rent-Helper.git
cd Rent-Helper
```

## 2️⃣ Firebase Setup

1. Create Firebase project
2. Add iOS app with correct Bundle ID
3. Enable:

   * Email/Password Authentication
   * Firestore Database
4. Download `GoogleService-Info.plist`
5. Add it to the Xcode project

## 3️⃣ Open in Xcode

```
RentHelper.xcodeproj
```

Run on simulator.

---

# 👩‍💻 Team

* Negar Pirasteh
* Betty Dang
* Naomi Pham

---

# 📄 Academic Context

Developed as part of an Information Systems implementation course, following structured iteration-based deliverables emphasizing architecture, persistence, and secure integration.

---
