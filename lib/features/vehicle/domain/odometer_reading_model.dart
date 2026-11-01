class OdometerReadingModel {
  final String id;
  final String vehicleId;
  final int reading;
  final DateTime readingDate;
  final String? notes;
  final bool isCorrection;
  final DateTime createdAt;
  final int? distanceDelta; // Calculated relative to previous reading

  const OdometerReadingModel({
    required this.id,
    required this.vehicleId,
    required this.reading,
    required this.readingDate,
    this.notes,
    this.isCorrection = false,
    required this.createdAt,
    this.distanceDelta,
  });

  OdometerReadingModel copyWith({
    String? id,
    String? vehicleId,
    int? reading,
    DateTime? readingDate,
    String? notes,
    bool? isCorrection,
    DateTime? createdAt,
    int? distanceDelta,
  }) {
    return OdometerReadingModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      reading: reading ?? this.reading,
      readingDate: readingDate ?? this.readingDate,
      notes: notes ?? this.notes,
      isCorrection: isCorrection ?? this.isCorrection,
      createdAt: createdAt ?? this.createdAt,
      distanceDelta: distanceDelta ?? this.distanceDelta,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'reading': reading,
        'readingDate': readingDate.toIso8601String(),
        'notes': notes,
        'isCorrection': isCorrection,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OdometerReadingModel.fromJson(Map<String, dynamic> json) => OdometerReadingModel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        reading: json['reading'] as int,
        readingDate: DateTime.parse(json['readingDate'] as String),
        notes: json['notes'] as String?,
        isCorrection: (json['isCorrection'] as bool?) ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
