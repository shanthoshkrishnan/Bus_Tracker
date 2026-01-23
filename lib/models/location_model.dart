class BusLocation {
  final String busId;
  final String busNumber;
  final String departurePlace;
  final String arrivalPlace;
  final double currentLatitude;
  final double currentLongitude;
  final DateTime lastUpdated;
  final String status; // 'departed', 'in-transit', 'arrived', 'delayed'
  final String? delayReason; // 'traffic', 'breakdown', 'weather', 'late-start'
  final int delayMinutes;
  final int currentPassengers;
  final int totalCapacity;

  BusLocation({
    required this.busId,
    required this.busNumber,
    required this.departurePlace,
    required this.arrivalPlace,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.lastUpdated,
    required this.status,
    this.delayReason,
    this.delayMinutes = 0,
    this.currentPassengers = 0,
    this.totalCapacity = 50,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'busNumber': busNumber,
      'departurePlace': departurePlace,
      'arrivalPlace': arrivalPlace,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status,
      'delayReason': delayReason,
      'delayMinutes': delayMinutes,
      'currentPassengers': currentPassengers,
      'totalCapacity': totalCapacity,
    };
  }

  // Create from JSON
  factory BusLocation.fromJson(String busId, Map<String, dynamic> json) {
    return BusLocation(
      busId: busId,
      busNumber: json['busNumber'] ?? '',
      departurePlace: json['departurePlace'] ?? '',
      arrivalPlace: json['arrivalPlace'] ?? '',
      currentLatitude: (json['currentLatitude'] ?? 0.0).toDouble(),
      currentLongitude: (json['currentLongitude'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'in-transit',
      delayReason: json['delayReason'],
      delayMinutes: json['delayMinutes'] ?? 0,
      currentPassengers: json['currentPassengers'] ?? 0,
      totalCapacity: json['totalCapacity'] ?? 50,
    );
  }

  // Copy with modifications
  BusLocation copyWith({
    String? busId,
    String? busNumber,
    String? departurePlace,
    String? arrivalPlace,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastUpdated,
    String? status,
    String? delayReason,
    int? delayMinutes,
    int? currentPassengers,
    int? totalCapacity,
  }) {
    return BusLocation(
      busId: busId ?? this.busId,
      busNumber: busNumber ?? this.busNumber,
      departurePlace: departurePlace ?? this.departurePlace,
      arrivalPlace: arrivalPlace ?? this.arrivalPlace,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      delayReason: delayReason ?? this.delayReason,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      currentPassengers: currentPassengers ?? this.currentPassengers,
      totalCapacity: totalCapacity ?? this.totalCapacity,
    );
  }
}

class DriverLocation {
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String assignedBusId;
  final String assignedBusNumber;
  final double currentLatitude;
  final double currentLongitude;
  final DateTime lastUpdated;
  final String status; // 'online', 'offline', 'on-break'
  final bool isActive;

  DriverLocation({
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.assignedBusId,
    required this.assignedBusNumber,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.lastUpdated,
    required this.status,
    this.isActive = true,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'assignedBusId': assignedBusId,
      'assignedBusNumber': assignedBusNumber,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status,
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory DriverLocation.fromJson(String driverId, Map<String, dynamic> json) {
    return DriverLocation(
      driverId: driverId,
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      assignedBusId: json['assignedBusId'] ?? '',
      assignedBusNumber: json['assignedBusNumber'] ?? '',
      currentLatitude: (json['currentLatitude'] ?? 0.0).toDouble(),
      currentLongitude: (json['currentLongitude'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'offline',
      isActive: json['isActive'] ?? true,
    );
  }

  // Copy with modifications
  DriverLocation copyWith({
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? assignedBusId,
    String? assignedBusNumber,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastUpdated,
    String? status,
    bool? isActive,
  }) {
    return DriverLocation(
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedBusNumber: assignedBusNumber ?? this.assignedBusNumber,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }
}

class BusRoute {
  final String routeId;
  final String routeName;
  final String departurePlace;
  final String arrivalPlace;
  final String departureTime; // HH:mm format
  final String arrivalTime; // HH:mm format
  final List<String> stops; // Intermediate stops
  final int estimatedDurationMinutes;
  final List<String> assignedBuses; // Bus IDs assigned to this route
  final bool isActive;
  final DateTime createdAt;

  BusRoute({
    required this.routeId,
    required this.routeName,
    required this.departurePlace,
    required this.arrivalPlace,
    required this.departureTime,
    required this.arrivalTime,
    required this.stops,
    required this.estimatedDurationMinutes,
    required this.assignedBuses,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'departurePlace': departurePlace,
      'arrivalPlace': arrivalPlace,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'stops': stops,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'assignedBuses': assignedBuses,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory BusRoute.fromJson(String routeId, Map<String, dynamic> json) {
    return BusRoute(
      routeId: routeId,
      routeName: json['routeName'] ?? '',
      departurePlace: json['departurePlace'] ?? '',
      arrivalPlace: json['arrivalPlace'] ?? '',
      departureTime: json['departureTime'] ?? '00:00',
      arrivalTime: json['arrivalTime'] ?? '00:00',
      stops: List<String>.from(json['stops'] ?? []),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      assignedBuses: List<String>.from(json['assignedBuses'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Copy with modifications
  BusRoute copyWith({
    String? routeId,
    String? routeName,
    String? departurePlace,
    String? arrivalPlace,
    String? departureTime,
    String? arrivalTime,
    List<String>? stops,
    int? estimatedDurationMinutes,
    List<String>? assignedBuses,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BusRoute(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      departurePlace: departurePlace ?? this.departurePlace,
      arrivalPlace: arrivalPlace ?? this.arrivalPlace,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      stops: stops ?? this.stops,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      assignedBuses: assignedBuses ?? this.assignedBuses,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Student Bus Assignment Model
/// Tracks which bus is assigned to which student
class StudentBusAssignment {
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String assignedBusId;
  final String assignedBusNumber;
  final String routeId;
  final String departurePlace; // Where student boards
  final double departureLatitude;
  final double departureLongitude;
  final String stopPlace; // Where student gets off
  final double stopLatitude;
  final double stopLongitude;
  final DateTime assignedDate;
  final bool isActive;
  final String? notes; // Additional notes

  StudentBusAssignment({
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.assignedBusId,
    required this.assignedBusNumber,
    required this.routeId,
    required this.departurePlace,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.stopPlace,
    required this.stopLatitude,
    required this.stopLongitude,
    required this.assignedDate,
    this.isActive = true,
    this.notes,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'assignedBusId': assignedBusId,
      'assignedBusNumber': assignedBusNumber,
      'routeId': routeId,
      'departurePlace': departurePlace,
      'departureLatitude': departureLatitude,
      'departureLongitude': departureLongitude,
      'stopPlace': stopPlace,
      'stopLatitude': stopLatitude,
      'stopLongitude': stopLongitude,
      'assignedDate': assignedDate.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
    };
  }

  // Create from JSON
  factory StudentBusAssignment.fromJson(
    String assignmentId,
    Map<String, dynamic> json,
  ) {
    return StudentBusAssignment(
      assignmentId: assignmentId,
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      assignedBusId: json['assignedBusId'] ?? '',
      assignedBusNumber: json['assignedBusNumber'] ?? '',
      routeId: json['routeId'] ?? '',
      departurePlace: json['departurePlace'] ?? '',
      departureLatitude: (json['departureLatitude'] ?? 0.0).toDouble(),
      departureLongitude: (json['departureLongitude'] ?? 0.0).toDouble(),
      stopPlace: json['stopPlace'] ?? '',
      stopLatitude: (json['stopLatitude'] ?? 0.0).toDouble(),
      stopLongitude: (json['stopLongitude'] ?? 0.0).toDouble(),
      assignedDate: DateTime.parse(
        json['assignedDate'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
    );
  }

  // Copy with method
  StudentBusAssignment copyWith({
    String? assignmentId,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? assignedBusId,
    String? assignedBusNumber,
    String? routeId,
    String? departurePlace,
    double? departureLatitude,
    double? departureLongitude,
    String? stopPlace,
    double? stopLatitude,
    double? stopLongitude,
    DateTime? assignedDate,
    bool? isActive,
    String? notes,
  }) {
    return StudentBusAssignment(
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedBusNumber: assignedBusNumber ?? this.assignedBusNumber,
      routeId: routeId ?? this.routeId,
      departurePlace: departurePlace ?? this.departurePlace,
      departureLatitude: departureLatitude ?? this.departureLatitude,
      departureLongitude: departureLongitude ?? this.departureLongitude,
      stopPlace: stopPlace ?? this.stopPlace,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      assignedDate: assignedDate ?? this.assignedDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}

/// Route Table Model (Enhanced version of BusRoute for all route details)
class RouteTable {
  final String routeId;
  final String routeName;
  final String departurePlace;
  final double departureLatitude;
  final double departureLongitude;
  final String arrivalPlace;
  final double arrivalLatitude;
  final double arrivalLongitude;
  final String departureTime; // HH:mm format
  final String arrivalTime; // HH:mm format
  final List<RouteStop> stops; // Intermediate stops
  final int estimatedDurationMinutes;
  final List<String> assignedBuses;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUpdated;

  RouteTable({
    required this.routeId,
    required this.routeName,
    required this.departurePlace,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.arrivalPlace,
    required this.arrivalLatitude,
    required this.arrivalLongitude,
    required this.departureTime,
    required this.arrivalTime,
    required this.stops,
    required this.estimatedDurationMinutes,
    required this.assignedBuses,
    this.isActive = true,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'departurePlace': departurePlace,
      'departureLatitude': departureLatitude,
      'departureLongitude': departureLongitude,
      'arrivalPlace': arrivalPlace,
      'arrivalLatitude': arrivalLatitude,
      'arrivalLongitude': arrivalLongitude,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'stops': stops.map((s) => s.toJson()).toList(),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'assignedBuses': assignedBuses,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory RouteTable.fromJson(String routeId, Map<String, dynamic> json) {
    return RouteTable(
      routeId: routeId,
      routeName: json['routeName'] ?? '',
      departurePlace: json['departurePlace'] ?? '',
      departureLatitude: (json['departureLatitude'] ?? 0.0).toDouble(),
      departureLongitude: (json['departureLongitude'] ?? 0.0).toDouble(),
      arrivalPlace: json['arrivalPlace'] ?? '',
      arrivalLatitude: (json['arrivalLatitude'] ?? 0.0).toDouble(),
      arrivalLongitude: (json['arrivalLongitude'] ?? 0.0).toDouble(),
      departureTime: json['departureTime'] ?? '00:00',
      arrivalTime: json['arrivalTime'] ?? '00:00',
      stops:
          (json['stops'] as List?)
              ?.map((s) => RouteStop.fromJson(s))
              .toList() ??
          [],
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 0,
      assignedBuses: List<String>.from(json['assignedBuses'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  RouteTable copyWith({
    String? routeId,
    String? routeName,
    String? departurePlace,
    double? departureLatitude,
    double? departureLongitude,
    String? arrivalPlace,
    double? arrivalLatitude,
    double? arrivalLongitude,
    String? departureTime,
    String? arrivalTime,
    List<RouteStop>? stops,
    int? estimatedDurationMinutes,
    List<String>? assignedBuses,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return RouteTable(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      departurePlace: departurePlace ?? this.departurePlace,
      departureLatitude: departureLatitude ?? this.departureLatitude,
      departureLongitude: departureLongitude ?? this.departureLongitude,
      arrivalPlace: arrivalPlace ?? this.arrivalPlace,
      arrivalLatitude: arrivalLatitude ?? this.arrivalLatitude,
      arrivalLongitude: arrivalLongitude ?? this.arrivalLongitude,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      stops: stops ?? this.stops,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      assignedBuses: assignedBuses ?? this.assignedBuses,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Individual stop in a route
class RouteStop {
  final String stopName;
  final double latitude;
  final double longitude;
  final int orderInRoute; // 1, 2, 3, etc.

  RouteStop({
    required this.stopName,
    required this.latitude,
    required this.longitude,
    required this.orderInRoute,
  });

  Map<String, dynamic> toJson() {
    return {
      'stopName': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'orderInRoute': orderInRoute,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      stopName: json['stopName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      orderInRoute: json['orderInRoute'] ?? 0,
    );
  }
}
