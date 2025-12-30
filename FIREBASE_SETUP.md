# Firebase Setup Guide for Bus Tracker

## Overview
This guide walks you through setting up Firebase for the Bus Tracker application. Firebase will handle user authentication and store all user details in Firestore database.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `bus-tracker` (or your preferred name)
4. Continue through the setup (you can disable Google Analytics if you prefer)
5. Click **"Create project"**

## Step 2: Set Up Firebase Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **"Get started"**
3. Click on **"Email/Password"** provider
4. Enable it by toggling the switch
5. Click **"Save"**

## Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database** (left sidebar)
2. Click **"Create database"**
3. Select **"Start in test mode"** (you'll update rules next)
4. Choose your preferred location
5. Click **"Create"**

## Step 4: Set Firestore Security Rules

1. In Firestore, go to the **"Rules"** tab
2. Replace the default rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
      allow read: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

## Step 5: Get Firebase Configuration

### For Android:
1. In Firebase Console, click **"Add app"** → **"Android"**
2. Package name: `com.example.bus_tracker` (or your package name)
3. Click **"Next"**
4. Download `google-services.json`
5. Move the file to: `android/app/google-services.json`
6. Complete the setup by clicking **"Next"** until done
7. Your Android API Key and other details are now configured

### For iOS:
1. In Firebase Console, click **"Add app"** → **"iOS"**
2. Bundle ID: `com.example.busTracker` (or your bundle ID)
3. Click **"Next"**
4. Download `GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click on `Runner` project → **"Add Files to Runner"**
7. Select `GoogleService-Info.plist` and click **"Add"**
8. Make sure **"Copy items if needed"** is checked

## Step 6: Update Firebase Configuration in Code

1. Open `lib/firebase_options.dart`
2. Go to [Firebase Project Settings](https://console.firebase.google.com/project/_/settings/general)
3. For each platform, replace the placeholder values:
   - `YOUR_ANDROID_API_KEY` → Web API Key
   - `YOUR_ANDROID_APP_ID` → Android App ID
   - `YOUR_IOS_API_KEY` → Web API Key
   - `YOUR_IOS_APP_ID` → iOS App ID
   - `YOUR_MESSAGING_SENDER_ID` → Sender ID (Project number)
   - `YOUR_PROJECT_ID` → Project ID

Example firebase_options.dart values can be found in:
- Android: Check `android/app/build.gradle` after adding google-services.json
- iOS: Check `GoogleService-Info.plist` properties
- Web/Windows/Linux/macOS: Get from Firebase Console → Project Settings

## Step 7: Install Dependencies

Run the following command in your project root:

```bash
flutter pub get
```

This will install all dependencies including:
- firebase_core
- firebase_auth
- cloud_firestore
- intl

## Step 8: Build and Run

### For Android:
```bash
flutter run
```

### For iOS:
```bash
cd ios
pod install
cd ..
flutter run
```

## Database Structure

Your Firestore database will have the following structure:

```
users/
  {uid}/
    uid: string
    email: string
    firstName: string
    lastName: string
    year: string
    department: string
    age: number
    dob: string (yyyy-MM-dd format)
    address: string
    role: string (student, driver, staff, worker, people, admin)
    createdAt: timestamp
    updatedAt: timestamp
```

## Features Implemented

✅ User Registration with all required fields
✅ Email and Password Authentication
✅ Automatic user data storage in Firestore
✅ Email validation
✅ Password strength validation (minimum 6 characters)
✅ Duplicate email checking
✅ Role-based user types (Student, Driver, Staff, Worker, People, Admin)
✅ Date of birth picker
✅ Comprehensive form validation
✅ Error handling and user feedback

## Testing the Registration

1. Run the app: `flutter run`
2. Click on **"Sign Up"** on the login page
3. Fill in all the required fields:
   - First Name
   - Last Name
   - Email (must be valid email format)
   - Year
   - Department
   - Age (numeric)
   - Date of Birth (select from date picker)
   - Address
   - Password (minimum 6 characters)
   - Confirm Password
   - Role (select from dropdown)
4. Check the terms checkbox
5. Click **"Create Account"**
6. If successful, user data will be saved in Firebase Firestore

## Troubleshooting

### "Unknown host exception" or "Network error"
- Check your internet connection
- Ensure Firebase project is created and active
- Verify API keys in firebase_options.dart

### "Permission denied" error
- Update your Firestore security rules (see Step 4)
- Ensure Firebase Authentication is enabled

### "Method not found" errors
- Run `flutter pub get` again
- Run `flutter clean` and rebuild

### Android build issues
- Ensure `google-services.json` is in `android/app/` directory
- Update `android/build.gradle` if needed

## Environment Variables (Optional)

For enhanced security in production, consider:
1. Using Firebase Emulator Suite for development
2. Storing API keys in a separate config file
3. Implementing custom claims for role-based access control

## Next Steps

After successful registration setup, you can:
1. Set up Login page with Firebase Authentication
2. Add role-based navigation
3. Create user profile pages
4. Implement password reset functionality
5. Add profile update features

For more information, visit:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://firebase.flutter.dev/)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
