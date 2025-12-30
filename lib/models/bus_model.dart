class BusModel {
  final String id;
  final String busNumber;
  final String busRoute;
  final String departureLocation;
  final String arrivalLocation;
  final double departureLatitude;
  final double departureLongitude;
  final double arrivalLatitude;
  final double arrivalLongitude;
  final double? currentLatitude;
  final double? currentLongitude;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final List<String> assignedStudents;
  final String status; // active, inactive, maintenance

  BusModel({
    required this.id,
    required this.busNumber,
    required this.busRoute,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.arrivalLatitude,
    required this.arrivalLongitude,
    this.currentLatitude,
    this.currentLongitude,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.assignedStudents,
    this.status = 'active',
  });

  // Convert from Firestore document
  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    return BusModel(
      id: id,
      busNumber: map['busNumber'] ?? '',
      busRoute: map['busRoute'] ?? '',
      departureLocation: map['departureLocation'] ?? '',
      arrivalLocation: map['arrivalLocation'] ?? '',
      departureLatitude: (map['departureLatitude'] ?? 0.0).toDouble(),
      departureLongitude: (map['departureLongitude'] ?? 0.0).toDouble(),
      arrivalLatitude: (map['arrivalLatitude'] ?? 0.0).toDouble(),
      arrivalLongitude: (map['arrivalLongitude'] ?? 0.0).toDouble(),
      currentLatitude: map['currentLatitude'] != null ? (map['currentLatitude']).toDouble() : null,
      currentLongitude: map['currentLongitude'] != null ? (map['currentLongitude']).toDouble() : null,
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      assignedStudents: List<String>.from(map['assignedStudents'] ?? []),
      status: map['status'] ?? 'active',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'busRoute': busRoute,
      'departureLocation': departureLocation,
      'arrivalLocation': arrivalLocation,
      'departureLatitude': departureLatitude,
      'departureLongitude': departureLongitude,
      'arrivalLatitude': arrivalLatitude,
      'arrivalLongitude': arrivalLongitude,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'assignedStudents': assignedStudents,
      'status': status,
    };
  }
}
