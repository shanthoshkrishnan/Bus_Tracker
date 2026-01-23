# 🔧 LO BUS - Backend Documentation

This document covers the backend architecture, Firebase services, database structure, API methods, security rules, and deployment for the LO BUS application.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Database Structure](#database-structure)
- [Services & APIs](#services--apis)
- [Data Models](#data-models)
- [Security Rules](#security-rules)
- [Cloud Functions](#cloud-functions)
- [Real-time Updates](#real-time-updates)
- [Deployment](#deployment)

---

## 🏗️ Architecture Overview

### Backend Stack

```
┌─────────────────────────────────────────┐
│         Flutter App (Frontend)          │
└──────────────┬──────────────────────────┘
               │
               ├──── Firebase Authentication
               │     (Email/Password)
               │
               ├──── Cloud Firestore
               │     (User data, buses, drivers)
               │
               ├──── Realtime Database
               │     (Live location tracking)
               │
               ├──── Firebase Cloud Messaging
               │     (Push notifications)
               │
               ├──── Firebase Cloud Functions
               │     (Server-side logic)
               │
               └──── Firebase Storage
                     (Profile pictures, assets)
```

### Why Two Databases?

**Cloud Firestore** (Document database)
- ✅ Better for: User profiles, buses, drivers, routes
- ✅ Rich querying capabilities
- ✅ Offline support
- ✅ Complex queries with indexes
- ⚠️ Higher cost for high-frequency updates

**Realtime Database** (JSON tree)
- ✅ Better for: GPS location updates
- ✅ Real-time sync (< 100ms latency)
- ✅ Lower cost for frequent updates
- ✅ Simple read/write operations
- ⚠️ Limited querying

---

## 💾 Database Structure

### Cloud Firestore Structure

```
/users/{userId}
├── uid: string
├── email: string
├── firstName: string
├── lastName: string
├── year: string
├── department: string
├── age: number
├── dob: string
├── address: string
├── role: string (student|driver|admin)
├── gender: string
├── profilePicture: string (URL)
├── phone: string
├── createdAt: timestamp
└── updatedAt: timestamp

/buses/{busId}
├── busId: string
├── busNumber: string
├── departurePlace: string
├── arrivalPlace: string
├── totalCapacity: number
├── assignedDriverId: string
├── assignedDriverName: string
├── assignedRoute: string
├── status: string (active|inactive)
├── createdAt: timestamp
└── updatedAt: timestamp

/drivers/{driverId}
├── driverId: string (user UID)
├── driverName: string
├── driverEmail: string
├── driverPhone: string
├── assignedBusNumber: string
├── assignedRoute: string
├── status: string (active|inactive|on-break)
├── createdAt: timestamp
└── updatedAt: timestamp

/demo_data/{demoId}
├── type: string (bus|driver|route)
├── data: object
└── createdAt: timestamp
```

### Firestore Indexes

**Required indexes (in `firestore.indexes.json`):**
```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "role", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "buses",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "busNumber", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "drivers",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "driverName", "order": "ASCENDING"}
      ]
    }
  ]
}
```

---

### Realtime Database Structure

```json
{
  "bus_locations": {
    "bus_001": {
      "busId": "bus_001",
      "busNumber": "154",
      "departurePlace": "Main Gate",
      "arrivalPlace": "Central Station",
      "currentLatitude": 12.8400,
      "currentLongitude": 79.8810,
      "lastUpdated": "2026-01-23T10:30:00.000Z",
      "status": "in-transit",
      "delayReason": "",
      "delayMinutes": 0,
      "currentPassengers": 25,
      "totalCapacity": 40
    }
  },
  
  "driver_locations": {
    "driver_001": {
      "driverId": "driver_001",
      "driverName": "John Doe",
      "driverPhone": "+1234567890",
      "assignedBusId": "bus_001",
      "assignedBusNumber": "154",
      "currentLatitude": 12.8400,
      "currentLongitude": 79.8810,
      "lastUpdated": "2026-01-23T10:30:00.000Z",
      "status": "online",
      "isActive": true
    }
  },
  
  "bus_routes": {
    "route_001": {
      "routeId": "route_001",
      "routeName": "Main Street Route",
      "departureLocation": "Main Gate",
      "arrivalLocation": "Central Station",
      "stops": [
        "Main Gate",
        "Library",
        "Sports Complex",
        "Central Station"
      ],
      "departureTime": "08:00",
      "arrivalTime": "09:00",
      "estimatedDuration": 60,
      "assignedBuses": ["bus_001", "bus_002"],
      "isActive": true,
      "createdAt": "2026-01-23T08:00:00.000Z"
    }
  },
  
  "student_bus_assignments": {
    "assignment_001": {
      "assignmentId": "assignment_001",
      "studentId": "STU12345",
      "studentName": "Alice Johnson",
      "studentEmail": "alice@example.com",
      "assignedBusId": "bus_001",
      "assignedBusNumber": "154",
      "routeId": "route_001",
      "departurePlace": "Main Gate",
      "departureLatitude": 12.8400,
      "departureLongitude": 79.8810,
      "stopPlace": "Library",
      "stopLatitude": 12.8450,
      "stopLongitude": 79.8860,
      "assignedDate": "2026-01-23T08:00:00.000Z",
      "isActive": true
    }
  },
  
  "route_tables": {
    "route_001": {
      "routeId": "route_001",
      "routeName": "Main Street Route",
      "assignedBusId": "bus_001",
      "assignedBusNumber": "154",
      "stops": [
        {
          "stopId": "stop_001",
          "stopName": "Main Gate",
          "latitude": 12.8400,
          "longitude": 79.8810,
          "order": 0
        },
        {
          "stopId": "stop_002",
          "stopName": "Library",
          "latitude": 12.8450,
          "longitude": 79.8860,
          "order": 1
        }
      ],
      "departureTime": "08:00",
      "arrivalTime": "09:00",
      "isActive": true,
      "lastUpdated": "2026-01-23T08:00:00.000Z"
    }
  }
}
```

---

## 🔌 Services & APIs

### 1. FirebaseService (`firebase_service.dart`)

**Purpose:** Handle Firestore operations (users, buses, drivers)

#### Authentication Methods

```dart
// Register new user
Future<void> registerUser({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String year,
  required String department,
  required int age,
  required String dob,
  required String address,
  required String role,
  required String gender,
})

// Login user
Future<UserCredential> loginUser(String email, String password)

// Logout
Future<void> signOut()

// Get current user
User? getCurrentUser()

// Reset password
Future<void> resetPassword(String email)
```

#### User Profile Methods

```dart
// Get user data
Future<DocumentSnapshot> getUserData(String uid)

// Update user profile
Future<void> updateUserProfile(String uid, Map<String, dynamic> data)

// Delete user account
Future<void> deleteUser(String uid)

// Get user role
Future<String> getUserRole(String uid)

// Check if user is admin
Future<bool> isAdmin(String uid)
```

#### Bus Management Methods

```dart
// Create bus
Future<void> createBus({
  required String busNumber,
  required String departurePlace,
  required String arrivalPlace,
  required int totalCapacity,
  String? assignedDriverId,
  String? assignedDriverName,
  String? assignedRoute,
})

// Get all buses
Future<List<Bus>> getAllBuses()

// Stream buses (real-time)
Stream<List<Bus>> streamBuses()

// Update bus
Future<void> updateBus(String busId, Map<String, dynamic> data)

// Delete bus
Future<void> deleteBus(String busId)

// Get bus by ID
Future<Bus?> getBusById(String busId)

// Get bus by number
Future<Bus?> getBusByNumber(String busNumber)
```

#### Driver Management Methods

```dart
// Create driver
Future<void> createDriver({
  required String driverId,
  required String driverName,
  required String driverEmail,
  required String driverPhone,
  String? assignedBusNumber,
  String? assignedRoute,
})

// Get all drivers
Future<List<Map<String, dynamic>>> getAllDrivers()

// Stream drivers (real-time)
Stream<List<Map<String, dynamic>>> streamDrivers()

// Update driver
Future<void> updateDriver(String driverId, Map<String, dynamic> data)

// Delete driver
Future<void> deleteDriver(String driverId)

// Get driver by ID
Future<Map<String, dynamic>?> getDriverById(String driverId)

// Assign bus to driver
Future<void> assignBusToDriver(String driverId, String busId, String busNumber)
```

**Usage Example:**
```dart
// Create a new bus
await FirebaseService().createBus(
  busNumber: '154',
  departurePlace: 'Main Gate',
  arrivalPlace: 'Central Station',
  totalCapacity: 40,
  assignedDriverId: 'driver_001',
  assignedDriverName: 'John Doe',
  assignedRoute: 'Main Street Route',
);

// Stream buses in real-time
StreamBuilder<List<Bus>>(
  stream: FirebaseService().streamBuses(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return BusCard(bus: snapshot.data![index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### 2. LocationTrackingService (`location_tracking_service.dart`)

**Purpose:** Handle Realtime Database operations (GPS tracking)

#### Bus Location Methods

```dart
// Update bus location (called every 5-10 seconds by driver)
Future<void> updateBusLocation(BusLocation busLocation)

// Get all bus locations
Future<List<BusLocation>> getAllBusLocations()

// Get specific bus location
Future<BusLocation?> getBusLocation(String busId)

// Stream all bus locations (real-time)
Stream<List<BusLocation>> streamAllBusLocations()

// Stream specific bus location
Stream<BusLocation?> streamBusLocation(String busId)

// Delete bus location
Future<void> deleteBusLocation(String busId)
```

#### Driver Location Methods

```dart
// Update driver location
Future<void> updateDriverLocation(DriverLocation driverLocation)

// Get all driver locations
Future<List<DriverLocation>> getAllDriverLocations()

// Get specific driver location
Future<DriverLocation?> getDriverLocation(String driverId)

// Stream all driver locations
Stream<List<DriverLocation>> streamAllDriverLocations()

// Stream specific driver location
Stream<DriverLocation?> streamDriverLocation(String driverId)

// Delete driver location
Future<void> deleteDriverLocation(String driverId)
```

#### Route Management Methods

```dart
// Create/update bus route
Future<void> createOrUpdateBusRoute(BusRoute route)

// Get all routes
Future<List<BusRoute>> getAllRoutes()

// Get specific route
Future<BusRoute?> getRoute(String routeId)

// Stream all routes
Stream<List<BusRoute>> streamAllRoutes()

// Stream specific route
Stream<BusRoute?> streamRoute(String routeId)

// Delete route
Future<void> deleteRoute(String routeId)
```

#### Student Assignment Methods

```dart
// Assign bus to student
Future<void> assignBusToStudent(StudentBusAssignment assignment)

// Get student assignment
Future<StudentBusAssignment?> getStudentAssignment(String studentId)

// Get student's assigned bus location (filtered)
Future<BusLocation?> getStudentAssignedBusLocation(String studentId)

// Stream student's assigned bus location
Stream<BusLocation?> streamStudentAssignedBusLocation(String studentId)

// Get all students assigned to a route
Future<List<StudentBusAssignment>> getStudentsByRoute(String routeId)

// Update student assignment
Future<void> updateStudentAssignment(String studentId, Map<String, dynamic> data)

// Remove student assignment
Future<void> removeStudentAssignment(String studentId)

// Stream all student assignments
Stream<List<StudentBusAssignment>> streamAllStudentAssignments()
```

#### Route Table Methods

```dart
// Create/update route table
Future<void> createOrUpdateRouteTable(RouteTable routeTable)

// Get route table
Future<RouteTable?> getRouteTable(String routeId)

// Stream route table
Stream<RouteTable?> streamRouteFromTable(String routeId)

// Get route stops
Future<List<RouteStop>> getRouteStops(String routeId)

// Subscribe to route changes (for notifications)
Future<void> subscribeToRouteChanges(String routeId, Function(RouteTable) callback)

// Delete route table
Future<void> deleteRouteTable(String routeId)
```

**Usage Example:**
```dart
// Update bus location (in driver app)
Timer.periodic(Duration(seconds: 10), (timer) async {
  LatLng? location = await LocationService().getCurrentLocation();
  if (location != null) {
    await LocationTrackingService().updateBusLocation(
      BusLocation(
        busId: 'bus_001',
        busNumber: '154',
        departurePlace: 'Main Gate',
        arrivalPlace: 'Central Station',
        currentLatitude: location.latitude,
        currentLongitude: location.longitude,
        lastUpdated: DateTime.now().toIso8601String(),
        status: 'in-transit',
        delayReason: '',
        delayMinutes: 0,
        currentPassengers: 25,
        totalCapacity: 40,
      ),
    );
  }
});

// Stream student's assigned bus location
StreamBuilder<BusLocation?>(
  stream: LocationTrackingService()
      .streamStudentAssignedBusLocation(studentId),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return GoogleMap(
        markers: {
          Marker(
            markerId: MarkerId(snapshot.data!.busId),
            position: LatLng(
              snapshot.data!.currentLatitude,
              snapshot.data!.currentLongitude,
            ),
          ),
        },
      );
    }
    return Text('No bus assigned');
  },
)
```

---

### 3. LocationService (`location_service.dart`)

**Purpose:** Handle device GPS and location permissions

#### Methods

```dart
// Get current device location
Future<LatLng?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)})

// Get location updates stream
Stream<LatLng> getLocationUpdates({
  LocationAccuracy accuracy = LocationAccuracy.high,
  int distanceFilter = 10,
})

// Request location permission
Future<bool> requestLocationPermission()

// Check if location service is enabled
Future<bool> isLocationServiceEnabled()

// Get last known location
Future<LatLng?> getLastKnownLocation()

// Open location settings
Future<void> openLocationSettings()
```

**Error Handling:**
- Timeout: Falls back to medium accuracy
- Permission denied: Shows permission request dialog
- Service disabled: Prompts user to enable
- No GPS signal: Returns last known location

**Usage Example:**
```dart
// Get current location with error handling
try {
  LatLng? location = await LocationService().getCurrentLocation();
  if (location != null) {
    print('Lat: ${location.latitude}, Lng: ${location.longitude}');
  } else {
    print('Location not available');
  }
} catch (e) {
  print('Error: $e');
}

// Stream real-time location updates
LocationService().getLocationUpdates(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10, // meters
).listen((location) {
  print('New location: ${location.latitude}, ${location.longitude}');
});
```

---

### 4. DriverSyncService (`driver_sync_service.dart`)

**Purpose:** Sync driver data between Firestore and Realtime Database

#### Methods

```dart
// Sync current logged-in user (if driver)
Future<void> syncCurrentUserDriver()

// Sync specific driver
Future<void> syncDriverData(String driverId)

// Auto-sync on profile update
void setupAutoSync()
```

**When Sync Happens:**
1. App startup (in `_AppInitializer`)
2. User profile update (in `ProfilePage`)
3. Driver assignment changes (in admin pages)

**What Gets Synced:**
- Driver name
- Driver email
- Driver phone
- Assigned bus number
- Assigned route
- Status (active/inactive)

**Usage:**
```dart
// In main.dart (app startup)
await DriverSyncService().syncCurrentUserDriver();

// In ProfilePage (after profile update)
await FirebaseService().updateUserProfile(uid, data);
await DriverSyncService().syncCurrentUserDriver();
```

---

### 5. BusSetupService (`bus_setup_service.dart`)

**Purpose:** Initialize and configure buses

#### Methods

```dart
// Create demo bus data
Future<void> createDemoBuses()

// Validate bus data
bool validateBusData(Map<String, dynamic> data)

// Initialize bus with default settings
Future<void> initializeBus(String busId)
```

---

## 📦 Data Models

### 1. BusLocation Model (`location_model.dart`)

```dart
class BusLocation {
  final String busId;
  final String busNumber;
  final String departurePlace;
  final String arrivalPlace;
  final double currentLatitude;
  final double currentLongitude;
  final String lastUpdated; // ISO 8601 string
  final String status; // departed, in-transit, arrived, delayed
  final String delayReason;
  final int delayMinutes;
  final int currentPassengers;
  final int totalCapacity;

  BusLocation({/* constructor */});

  // Convert to JSON for database
  Map<String, dynamic> toJson();

  // Create from JSON
  factory BusLocation.fromJson(String busId, Map<String, dynamic> json);

  // Create copy with changes
  BusLocation copyWith({/* parameters */});
}
```

### 2. DriverLocation Model

```dart
class DriverLocation {
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String assignedBusId;
  final String assignedBusNumber;
  final double currentLatitude;
  final double currentLongitude;
  final String lastUpdated;
  final String status; // online, offline, on-break
  final bool isActive;

  DriverLocation({/* constructor */});
  Map<String, dynamic> toJson();
  factory DriverLocation.fromJson(String driverId, Map<String, dynamic> json);
  DriverLocation copyWith({/* parameters */});
}
```

### 3. StudentBusAssignment Model

```dart
class StudentBusAssignment {
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String assignedBusId;
  final String assignedBusNumber;
  final String routeId;
  final String departurePlace;
  final double departureLatitude;
  final double departureLongitude;
  final String stopPlace;
  final double stopLatitude;
  final double stopLongitude;
  final String assignedDate;
  final bool isActive;

  StudentBusAssignment({/* constructor */});
  Map<String, dynamic> toJson();
  factory StudentBusAssignment.fromJson(String id, Map<String, dynamic> json);
  StudentBusAssignment copyWith({/* parameters */});
}
```

### 4. RouteTable Model

```dart
class RouteTable {
  final String routeId;
  final String routeName;
  final String assignedBusId;
  final String assignedBusNumber;
  final List<RouteStop> stops;
  final String departureTime;
  final String arrivalTime;
  final bool isActive;
  final String lastUpdated;

  RouteTable({/* constructor */});
  Map<String, dynamic> toJson();
  factory RouteTable.fromJson(String routeId, Map<String, dynamic> json);
  RouteTable copyWith({/* parameters */});
}

class RouteStop {
  final String stopId;
  final String stopName;
  final double latitude;
  final double longitude;
  final int order;

  RouteStop({/* constructor */});
  Map<String, dynamic> toJson();
  factory RouteStop.fromJson(Map<String, dynamic> json);
}
```

### 5. Bus Model (`bus_model.dart`)

```dart
class Bus {
  final String busId;
  final String busNumber;
  final String departurePlace;
  final String arrivalPlace;
  final int totalCapacity;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final String? assignedRoute;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bus({/* constructor */});
  Map<String, dynamic> toJson();
  factory Bus.fromFirestore(DocumentSnapshot doc);
  Bus copyWith({/* parameters */});
}
```

---

## 🔒 Security Rules

### Firestore Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isDriver() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'driver';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Buses collection
    match /buses/{busId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isAdmin();
    }
    
    // Drivers collection
    match /drivers/{driverId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isAdmin();
    }
    
    // Demo data collection
    match /demo_data/{demoId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isAdmin();
    }
    
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Realtime Database Rules

```json
{
  "rules": {
    "bus_locations": {
      ".read": "auth != null",
      "$busId": {
        ".write": "auth != null && (root.child('drivers').child(auth.uid).exists() || root.child('users').child(auth.uid).child('role').val() == 'admin')"
      }
    },
    
    "driver_locations": {
      ".read": "auth != null",
      "$driverId": {
        ".write": "auth != null && (auth.uid == $driverId || root.child('users').child(auth.uid).child('role').val() == 'admin')"
      }
    },
    
    "bus_routes": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
    },
    
    "student_bus_assignments": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'",
      ".indexOn": ["studentId", "routeId", "assignedBusId", "isActive"]
    },
    
    "route_tables": {
      ".read": "auth != null",
      ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'",
      ".indexOn": ["routeId", "isActive", "routeName"]
    }
  }
}
```

**Deploy Rules:**
```bash
# Firestore
firebase deploy --only firestore:rules

# Realtime Database
firebase deploy --only database
```

---

## ☁️ Cloud Functions

### Driver Sync Function (`functions/sync-drivers.js`)

**Purpose:** Automatically sync driver data when user profile changes

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.syncDriverOnProfileUpdate = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const newData = change.after.data();
    const oldData = change.before.data();
    
    // Only sync if user is a driver
    if (newData.role !== 'driver') {
      return null;
    }
    
    // Check if relevant fields changed
    const fieldsToSync = ['firstName', 'lastName', 'email', 'phone'];
    const hasChanges = fieldsToSync.some(field => newData[field] !== oldData[field]);
    
    if (!hasChanges) {
      return null;
    }
    
    // Update driver record
    const driverRef = admin.firestore().collection('drivers').doc(userId);
    await driverRef.update({
      driverName: `${newData.firstName} ${newData.lastName}`,
      driverEmail: newData.email,
      driverPhone: newData.phone || '',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    console.log(`Driver ${userId} synced successfully`);
    return null;
  });
```

**Deploy:**
```bash
cd functions
npm install
firebase deploy --only functions
```

---

## 🔄 Real-time Updates

### How Real-time Works

**1. Driver Updates Location (every 5-10 seconds):**
```dart
LocationService().getLocationUpdates().listen((location) {
  LocationTrackingService().updateBusLocation(
    BusLocation(/* data with new location */),
  );
});
```

**2. Student Listens to Updates:**
```dart
StreamBuilder<BusLocation?>(
  stream: LocationTrackingService().streamStudentAssignedBusLocation(studentId),
  builder: (context, snapshot) {
    // UI updates automatically when location changes
  },
)
```

**3. Firebase Realtime Database Syncs:**
- Driver writes → Firebase → All listeners notified in < 100ms
- No polling needed
- Efficient data transfer

**Optimization Tips:**
- Use `distanceFilter` to reduce update frequency (only update if moved > 10 meters)
- Use `StreamBuilder` to automatically rebuild UI
- Unsubscribe from streams when not needed (dispose in `dispose()`)

---

## 🚀 Deployment

### 1. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 2. Deploy Realtime Database Rules

```bash
firebase deploy --only database
```

### 3. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

### 4. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 5. Deploy All at Once

```bash
firebase deploy
```

---

## 📊 API Rate Limits

### Firebase Free Tier (Spark Plan)

**Cloud Firestore:**
- 50,000 reads/day
- 20,000 writes/day
- 20,000 deletes/day
- 1 GB storage

**Realtime Database:**
- 100 simultaneous connections
- 10 GB/month bandwidth
- 1 GB storage

**Authentication:**
- Unlimited sign-ins

**Cloud Functions:**
- 125K invocations/month
- 40K GB-seconds/month

**Recommendations:**
- Use Realtime Database for location updates (cheaper)
- Use Firestore for user/bus/driver data (better querying)
- Implement caching to reduce reads
- Use `limit()` in queries to reduce data transfer

---

## 🔍 Monitoring & Analytics

### Firebase Console

Monitor in real-time:
- **Authentication:** Active users, sign-ins
- **Firestore:** Document reads/writes, errors
- **Realtime Database:** Connections, bandwidth
- **Cloud Functions:** Invocations, errors, execution time

### Enable Logging

**In `firebase_service.dart`:**
```dart
try {
  await _firestore.collection('users').doc(uid).set(data);
  print('✅ User created: $uid');
} catch (e) {
  print('❌ Error creating user: $e');
  rethrow;
}
```

**In Cloud Functions:**
```javascript
console.log('Driver synced:', userId);
console.error('Sync failed:', error);
```

---

## 🧪 Testing Backend

### Test Firestore Operations

```dart
void main() {
  test('Create and read bus', () async {
    final service = FirebaseService();
    
    // Create bus
    await service.createBus(
      busNumber: 'TEST_001',
      departurePlace: 'Test Gate',
      arrivalPlace: 'Test Station',
      totalCapacity: 40,
    );
    
    // Read bus
    final bus = await service.getBusByNumber('TEST_001');
    expect(bus, isNotNull);
    expect(bus!.busNumber, equals('TEST_001'));
    
    // Cleanup
    await service.deleteBus(bus.busId);
  });
}
```

### Test Location Tracking

```dart
void main() {
  test('Update and stream bus location', () async {
    final service = LocationTrackingService();
    
    // Update location
    await service.updateBusLocation(
      BusLocation(
        busId: 'test_bus',
        busNumber: 'TEST',
        currentLatitude: 12.8400,
        currentLongitude: 79.8810,
        // ... other fields
      ),
    );
    
    // Stream location
    final stream = service.streamBusLocation('test_bus');
    final location = await stream.first;
    
    expect(location, isNotNull);
    expect(location!.busNumber, equals('TEST'));
    
    // Cleanup
    await service.deleteBusLocation('test_bus');
  });
}
```

---

**For frontend documentation, see [README_FRONTEND.md](README_FRONTEND.md)**

---

**Last Updated:** January 23, 2026
