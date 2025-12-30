# 🚌 Panimalar Smart Bus Management System

> A comprehensive Flutter-based real-time bus tracking and management system built for Panimalar Engineering College.

**Project Status**: 🔥 Hackathon Submission  
**Platform**: Flutter (Cross-platform)  
**Backend**: Firebase (Firestore, Authentication, Cloud Functions)  
**Team**: Panimalar Engineering College

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Setup & Configuration](#setup--configuration)
- [Usage Guide](#usage-guide)
- [Technologies](#technologies)
- [Hackathon Info](#hackathon-info)

---

## 🎯 Project Overview

The **Panimalar Smart Bus Management System** is a real-time bus tracking solution that enables:

- **Students**: Track buses in real-time, receive notifications when buses arrive
- **Drivers**: Update bus location, complete routes, manage schedules
- **Admins**: Manage buses, routes, drivers, and view analytics
- **College Staff**: Monitor system usage and generate reports

### Key Problem Solved

Students often miss buses due to lack of real-time information. This system provides:
- ✅ Real-time bus location tracking
- ✅ Automatic notifications (bus approaching, arrived)
- ✅ Estimated arrival times (ETA)
- ✅ Route and schedule management
- ✅ Driver and student verification

---

## ✨ Features

### 1. 🎓 Student Features
- ✅ Real-time bus tracking on map
- ✅ Receive notifications when bus is near
- ✅ View bus schedule and route
- ✅ See driver information
- ✅ Mark attendance automatically
- ✅ View nearby buses (5 km radius)
- ✅ Complete and update profile

### 2. 🚕 Driver Features
- ✅ Real-time GPS location sharing
- ✅ Route navigation with waypoints
- ✅ Student pickup verification
- ✅ Delay tracking and reporting
- ✅ Navigation assistance
- ✅ Attendance management

### 3. 👨‍💼 Admin Features
- ✅ Manage buses and routes
- ✅ Assign drivers to buses
- ✅ Create and modify schedules
- ✅ View real-time fleet tracking
- ✅ Generate analytics and reports
- ✅ Manage student and driver data
- ✅ View system logs and errors

### 4. 🔔 Notification System
- ✅ Push notifications for bus arrival
- ✅ SMS alerts (optional)
- ✅ In-app notification center
- ✅ Customizable notification preferences

### 5. 🗺️ Map & Tracking
- ✅ Real-time bus location on map
- ✅ Route visualization with waypoints
- ✅ Distance calculation
- ✅ ETA calculation
- ✅ Support for multiple buses
- ✅ Vehicle icon display

### 6. 🔐 Security & Authentication
- ✅ Email/Password authentication
- ✅ Role-based access control
- ✅ Admin custom claims
- ✅ Firestore security rules
- ✅ Encrypted credential storage

### 7. 📊 Analytics & Reporting
- ✅ Daily bus statistics
- ✅ Student attendance reports
- ✅ Route performance metrics
- ✅ Driver performance tracking
- ✅ System health monitoring

---

## 🚀 Quick Start

### Prerequisites

- **Flutter**: 3.0 or higher
- **Dart**: 3.0 or higher
- **Firebase Account**: For Firestore, Auth, and Cloud Functions
- **Git**: For version control
- **Android Studio or Xcode**: For mobile development

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/bus_tracker.git
cd bus_tracker
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Setup Firebase Configuration

```bash
# Copy the environment template
cp .env.example .env

# Edit .env with your Firebase credentials
nano .env  # or use your preferred editor
```

**Where to get Firebase credentials:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Project Settings → Your apps
4. Copy credentials for each platform (Android, iOS, etc.)
5. Paste them in `.env` file

#### 4. Run the Application

```bash
# Development mode (with hot reload)
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

---

## 📁 Project Structure

```
bus_tracker/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── env_config.dart       # Environment configuration
│   ├── models/
│   │   ├── bus_model.dart
│   │   ├── route_model.dart
│   │   ├── driver_model.dart
│   │   └── student_model.dart
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── home_page.dart
│   │   ├── profile_page.dart
│   │   ├── admin_page.dart
│   │   ├── bus_management_page.dart
│   │   ├── driver_page.dart
│   │   └── map_page.dart
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   └── auth_service.dart
│   ├── widgets/
│   │   ├── bus_card.dart
│   │   ├── notification_card.dart
│   │   └── profile_header.dart
│   └── firebase_options.dart
├── android/
│   ├── app/
│   │   ├── google-services.json   # Google Play services (from Firebase)
│   │   └── src/
│   └── build.gradle
├── ios/
│   ├── Runner/
│   │   └── GoogleService-Info.plist  # Firebase config for iOS
│   └── Podfile
├── test/
│   └── widget_test.dart
├── pubspec.yaml                  # Dependencies
├── pubspec.lock                  # Locked dependency versions
├── .env.example                  # Environment template (MUST COPY TO .env)
├── .env                          # Environment variables (DO NOT COMMIT)
├── .gitignore                    # Git ignore rules
├── README.md                     # This file
└── HACKATHON_PROGRESS.md         # Hackathon progress tracking
```

---

## ⚙️ Setup & Configuration

### Firebase Setup

#### 1. Create Firebase Project

```
1. Go to https://console.firebase.google.com
2. Click "Create Project"
3. Enter project name: "bus-tracker"
4. Enable Google Analytics (optional)
5. Create project
```

#### 2. Enable Required Services

```
Firebase Console → Your Project → Project Settings → Enabled APIs:
✓ Cloud Firestore
✓ Firebase Authentication
✓ Cloud Storage
✓ Cloud Functions
✓ Cloud Messaging (FCM)
```

#### 3. Create Firestore Database

```
Firestore Database → Create Database
- Location: Nearest to college (Mumbai or Singapore region)
- Start in Production mode
- Update rules (see FIRESTORE_PERMISSION_FIX_QUICK.md)
```

#### 4. Enable Authentication

```
Authentication → Sign-in method:
✓ Email/Password (enable)
✓ Anonymous (enable for demo)
```

#### 5. Configure Firestore Rules

See [FIRESTORE_PERMISSION_FIX_QUICK.md](FIRESTORE_PERMISSION_FIX_QUICK.md) for complete rules.

#### 6. Setup Admin Custom Claims

```bash
# Option 1: Firebase Console
1. Go to Authentication → Users
2. Click on user email
3. Set Custom Claims:
   {
     "admin": true
   }

# Option 2: Firebase CLI
firebase functions:config:set customclaims.admin=true
```

### Environment Variables

Create a `.env` file in the root directory:

```env
# Firebase Android
FIREBASE_ANDROID_API_KEY=YOUR_KEY_HERE
FIREBASE_ANDROID_APP_ID=1:818518045990:android:8cf94322a372283fdabde7
FIREBASE_MESSAGING_SENDER_ID=YOUR_ID_HERE
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com

# Firebase iOS
FIREBASE_IOS_API_KEY=YOUR_KEY_HERE
FIREBASE_IOS_APP_ID=YOUR_APP_ID
FIREBASE_IOS_BUNDLE_ID=com.example.busTracker

# Demo Settings
DEMO_BUS_NUMBER=154
DEMO_STUDENT_EMAIL=student@example.com
DEMO_ADMIN_EMAIL=admin@example.com

# App Settings
APP_NAME=Bus Tracker
ENVIRONMENT=development
```

**⚠️ IMPORTANT**: Never commit `.env` file to GitHub. It's included in `.gitignore`.

---

## 📱 Usage Guide

### Create Test Users

#### Admin User

```
Email: admin@example.com
Password: admin@123
Role: admin
```

**Then set admin claims:**
1. Firebase Console → Authentication → Users
2. Find "admin@example.com"
3. Click Custom Claims (JSON)
4. Add: `{"admin": true}`

#### Student User

```
Email: student@example.com
Password: student@123
Role: student
Home Location: Urapakkam
```

#### Driver User

```
Email: driver@example.com
Password: driver@123
Role: driver
```

### Demo Data

#### Create Demo Routes

1. Login as admin
2. Go to "Bus Management" (Assign button)
3. Click "Routes" button
4. Routes created:
   - Evening: Panimalar (3:07 PM) → Chengalpattu
   - Morning: Chengalpattu (7:00 AM) → Panimalar

#### Create Demo Buses

1. Still in Admin page
2. Click "Demo Data" button
3. Buses created:
   - Bus #125 (Vehicle: TN01AB1234) - Live bus
   - Bus #123, #154, #115 (Demo collection)

#### Setup Demo Notification

1. Create notification in Firestore:

```javascript
db.collection("notifications").add({
  userId: "student_user_id",
  busNumber: "154",
  message: "Bus #154 is approaching. 2.5 km away",
  type: "bus_approaching",
  read: false,
  createdAt: new Date()
});
```

2. Login as student
3. Go to home page
4. Scroll to "🔔 Bus Notifications"
5. See notification card with Bus #154 info

---

## 💻 Technologies

### Frontend
- **Flutter** 3.0+ - Cross-platform mobile framework
- **Dart** 3.0+ - Programming language
- **flutter_map** - Map visualization
- **cloud_firestore** - Real-time database
- **firebase_auth** - Authentication
- **geolocator** - Location services
- **flutter_dotenv** - Environment variables

### Backend
- **Firebase Firestore** - Real-time NoSQL database
- **Firebase Authentication** - User auth & custom claims
- **Firebase Cloud Functions** - Serverless backend
- **Google Cloud Storage** - File storage
- **Firebase Cloud Messaging** - Push notifications

### APIs
- **Google Maps API** - Map services, routing
- **Haversine Formula** - Distance calculation
- **Geofencing** - Location-based triggers

---

## 🏆 Hackathon Info

### Project Title
**Panimalar Smart Bus Management System - Real-Time Bus Tracking & Notification System**

### Problem Statement
Students at Panimalar Engineering College often miss buses due to lack of real-time location information and automated notifications. The current system relies on manual communication and static schedules.

### Solution
A comprehensive Flutter mobile application that provides:
1. Real-time bus location tracking using GPS
2. Automatic notifications when buses approach/arrive
3. Route and schedule management
4. Student attendance verification
5. Driver and admin management tools

### Tech Stack
- **Frontend**: Flutter/Dart (Cross-platform)
- **Backend**: Firebase (Firestore, Auth, Cloud Functions)
- **Maps**: Google Maps API with custom bus icons
- **Notifications**: Firebase Cloud Messaging

### Key Features
✅ Real-time GPS tracking  
✅ Automatic notifications  
✅ Role-based access control  
✅ Admin management system  
✅ Analytics & reporting  
✅ Offline capability  

### Competition Categories
- Mobile Development
- IoT/Location Services
- Education Technology
- Cloud Infrastructure

---

## 📞 Support & Documentation

### Important Documents

1. **[HACKATHON_PROGRESS.md](HACKATHON_PROGRESS.md)** - What's done, what's pending
2. **[FIRESTORE_PERMISSION_FIX_QUICK.md](FIRESTORE_PERMISSION_FIX_QUICK.md)** - Firestore rules
3. **[ADVANCED_ROUTE_MANAGEMENT.md](ADVANCED_ROUTE_MANAGEMENT.md)** - Route setup
4. **[VERIFICATION_GUIDE_SESSION_3.md](VERIFICATION_GUIDE_SESSION_3.md)** - Testing guide

### Common Issues

#### Firebase Permission Denied

**Problem**: `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution**:
1. Check Firestore rules are published
2. Verify user is authenticated
3. Set admin custom claims if needed
4. Check collection-specific rules

#### Location Permission

**Problem**: App doesn't get location

**Solution**:
1. Grant location permission in app
2. For Android: Check `AndroidManifest.xml` has location permissions
3. For iOS: Check `Info.plist` has location usage keys

#### Firebase Credentials Not Found

**Problem**: `PlatformException(ERROR_FIREBASE_INIT_FAILED, ...)`

**Solution**:
1. Copy `.env.example` to `.env`
2. Fill in Firebase credentials from console
3. Run `flutter clean && flutter pub get`

### Getting Help

- Check the documentation files in the repo
- Review Firebase Console logs
- Check Flutter console output for errors
- Search GitHub issues

---

## 📈 Performance Metrics

### Target Performance
- App startup time: < 3 seconds
- Map rendering: < 500ms
- Location update interval: 5-10 seconds
- Notification delivery: < 30 seconds
- Database query time: < 200ms

### Optimization Techniques
- Lazy loading of data
- Image caching
- Location batching
- Firestore indexing
- Flutter performance monitoring

---

## 🔒 Security

### Data Protection
- End-to-end encryption for sensitive data
- Firestore security rules enforce access control
- Firebase custom claims for role-based security
- No sensitive data stored locally

### Authentication
- Email/Password with Firebase Auth
- Custom JWT tokens
- Session management
- Logout functionality

### API Security
- REST API with authentication headers
- Rate limiting for API calls
- Input validation
- SQL injection prevention (uses Firestore, not SQL)

---

## 📝 License

This project is created for Panimalar Engineering College Hackathon.

---

## 👥 Team

- **Project Lead**: [Your Name]
- **Developers**: [Team Members]
- **Mentors**: Panimalar Engineering College Faculty

---

## 📞 Contact

- **College**: Panimalar Engineering College
- **Email**: hackathon@panimalar.ac.in
- **Website**: www.panimalar.ac.in

---

**Made with ❤️ for Panimalar Engineering College**

*Last Updated: December 30, 2025*
