class VehicleModel {
  final String id;
  final String nickname;
  final String manufacturer;
  final String model;
  final String variant;
  final String? registrationNumber;
  final int? modelYear;
  final DateTime? purchaseDate;
  final int currentOdometer;
  final String vehicleType;
  final String? imagePath;
  final String? model3dAssetPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModel({
    required this.id,
    required this.nickname,
    required this.manufacturer,
    required this.model,
    required this.variant,
    this.registrationNumber,
    this.modelYear,
    this.purchaseDate,
    this.currentOdometer = 0,
    this.vehicleType = 'Electric (EV)',
    this.imagePath,
    this.model3dAssetPath,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => '$manufacturer $model';
  String get displaySubtitle => '$variant • ${modelYear ?? 'N/A'}';

  VehicleModel copyWith({
    String? id,
    String? nickname,
    String? manufacturer,
    String? model,
    String? variant,
    String? registrationNumber,
    int? modelYear,
    DateTime? purchaseDate,
    int? currentOdometer,
    String? vehicleType,
    String? imagePath,
    String? model3dAssetPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      modelYear: modelYear ?? this.modelYear,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      vehicleType: vehicleType ?? this.vehicleType,
      imagePath: imagePath ?? this.imagePath,
      model3dAssetPath: model3dAssetPath ?? this.model3dAssetPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'manufacturer': manufacturer,
        'model': model,
        'variant': variant,
        'registrationNumber': registrationNumber,
        'modelYear': modelYear,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'currentOdometer': currentOdometer,
        'vehicleType': vehicleType,
        'imagePath': imagePath,
        'model3dAssetPath': model3dAssetPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        manufacturer: json['manufacturer'] as String,
        model: json['model'] as String,
        variant: json['variant'] as String,
        registrationNumber: json['registrationNumber'] as String?,
        modelYear: json['modelYear'] as int?,
        purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : null,
        currentOdometer: (json['currentOdometer'] as int?) ?? 0,
        vehicleType: (json['vehicleType'] as String?) ?? 'Electric (EV)',
        imagePath: json['imagePath'] as String?,
        model3dAssetPath: json['model3dAssetPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
