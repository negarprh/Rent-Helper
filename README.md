# 🏠 RentHelper - iOS Rental Listing Application

RentHelper is a **SwiftUI-based iOS application** that helps users discover rental properties, explore them on a map, and save favorite listings locally.

The project demonstrates a **modern hybrid mobile architecture** integrating:

* 🔐 Firebase Authentication
* ☁️ Firebase Firestore (Cloud Database)
* 🖼 Firebase Storage (listing images)
* 💾 CoreData (local favorites persistence)
* 🧭 MVVM Architecture
* 🗺 MapKit (interactive listing map)
* 🔎 Search & filtering system
* 💳 Stripe deposit system *(planned)*
* 👤 User profile system *(planned)*

The application is being built through **structured iterations**, gradually expanding from infrastructure setup to a fully featured rental browsing platform.

---

# 📌 Project Overview

RentHelper simulates a **real-world rental discovery platform** where users can:

* Create an account
* Log in securely
* Browse rental listings
* View property details
* Explore listings on an interactive map
* Search and filter listings
* Save favorite properties
* Remove favorites
* Persist favorites after app restart

The architecture clearly separates responsibilities between cloud services and local persistence.

| Component        | Purpose                   |
| ---------------- | ------------------------- |
| Firebase Auth    | User authentication       |
| Firestore        | Rental listing data       |
| Firebase Storage | Listing images            |
| CoreData         | Favorite listings storage |
| SwiftUI          | User interface            |

---

# 🏗 Architecture

RentHelper follows the **MVVM architecture pattern**.

```
Views → ViewModels → Services → Firebase / CoreData
```

### Views

SwiftUI screens responsible for UI rendering:

* Login
* Signup
* Listings
* Listing Details
* Favorites
* Profile *(planned)*

Navigation uses **NavigationStack + TabView**.

---

### ViewModels

ViewModels manage UI state and async data:

* Fetch listings
* Handle loading/error states
* Sync Firestore updates
* Manage filtering and search

Example:

```
ListingsViewModel
```

---

### Services

Services handle all external integrations.

**AuthService**

* Firebase login
* Signup
* Logout
* Session state

**ListingService**

* Fetch listings from Firestore
* Listen for real-time updates
* Decode listing data

---

### Persistence

Favorites are stored locally using **CoreData**.

Entity:

```
FavoriteListing
```

Attributes include:

* favoriteId
* userId
* listingId
* title
* price
* address
* city
* lat
* long
* imageUrl
* savedAt

Favorites remain saved even after restarting the app.

---

# ☁️ Firestore Listings

Listings are stored in the Firestore collection:

```
listings
```

Each document contains:

| Field       | Type   |
| ----------- | ------ |
| title       | String |
| price       | Number |
| address     | String |
| city        | String |
| lat         | Number |
| long        | Number |
| description | String |
| imageUrl    | String |

Listings are fetched using Firestore queries and decoded into Swift models.

---

# ⚡ Real-Time Firestore Updates

The app uses:

```
addSnapshotListener
```

This enables **live database updates**.

When listings are added or modified in Firestore:

* The UI updates automatically
* No refresh is required

---

# 🗺 Map Integration

RentHelper includes a **MapKit-based map view** that visualizes listings geographically.

Features:

* Display listings as map pins
* Click a pin to open listing details
* Seamless navigation from map → listing page

This allows users to explore rentals spatially.

---

# 🔎 Search & Filtering

Users can refine listings using:

* Text search (title or address)
* Price filtering
* Dynamic list updates

Filtering is handled inside the ViewModel and updates the UI instantly.

---

# 🖼 Listing Images

Images are stored in **Firebase Storage**.

Workflow:

```
Firebase Storage → image URL → Firestore → SwiftUI AsyncImage
```

Each listing document contains an `imageUrl` referencing the stored image.

Images are rendered using:

```
AsyncImage
```

---

# ❤️ Favorites System

Users can:

* Save listings as favorites
* Remove favorites
* View saved favorites in a dedicated screen

Favorites are stored in **CoreData** to ensure:

* Fast access
* Offline availability
* Persistence after app restart

---

# 🔁 Iteration Development

The project is developed through structured iterations.

---

## 🟢 Iteration 1 - Project Infrastructure

Focus: Establish architecture and Firebase integration.

Implemented:

* SwiftUI project setup
* MVVM folder structure
* Firebase configuration
* Firestore initialization
* Authentication setup
* CoreData stack
* App navigation

---

## 🟡 Iteration 2 - Listings & Authentication

Focus: Enable secure login and listing browsing.

Implemented:

* Signup / login / logout
* Listings screen
* Listing details screen
* Firestore listing structure
* Firebase Storage images

---

## 🔵 Iteration 3 - Favorites, Map & Filtering

Focus: Improve user experience and data persistence.

Implemented:

* Real Firestore listing fetch
* Real-time database updates
* MapKit listing map
* Search and filtering
* Save/remove favorites
* Favorites persistence via CoreData

---

# 🔐 Security Notes

* `GoogleService-Info.plist` is **not committed to GitHub**
* Firestore rules restrict write access
* Stripe secret keys will **never be stored in the client**
* Favorites remain local for privacy and performance

---

# 🛠 Tech Stack

| Layer             | Technology               |
| ----------------- | ------------------------ |
| UI                | SwiftUI                  |
| Architecture      | MVVM                     |
| Authentication    | Firebase Auth            |
| Database          | Firestore                |
| Image Storage     | Firebase Storage         |
| Maps              | MapKit                   |
| Local Persistence | CoreData                 |
| Filtering         | SwiftUI state management |
| Payments          | Stripe *(planned)*       |

---

# 🚀 How to Run

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/negarprh/Rent-Helper.git
cd Rent-Helper
```

---

### 2️⃣ Firebase Setup

1. Create Firebase project
2. Add iOS application
3. Enable:

* Email/Password Authentication
* Firestore Database
* Firebase Storage

4. Download:

```
GoogleService-Info.plist
```

5. Add it to the Xcode project.

---

### 3️⃣ Open the Project

Open:

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

# 🔮 Future Improvements

Upcoming features include:

* 💳 Stripe rent deposit system
* 👤 User profile system
* Advanced map interactions
* Push notifications
* Cloud-synced favorites
* Listing creation interface

---
