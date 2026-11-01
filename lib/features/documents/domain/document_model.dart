enum DocumentCategory {
  rc('Registration Certificate (RC)'),
  insurance('Insurance Policy'),
  puc('Pollution Under Control (PUC)'),
  warranty('Warranty Certificate'),
  serviceInvoice('Service Invoice'),
  purchaseInvoice('Purchase Invoice'),
  other('Other Document');

  final String label;
  const DocumentCategory(this.label);

  static DocumentCategory fromString(String val) {
    return DocumentCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => DocumentCategory.other,
    );
  }
}

class VehicleDocumentModel {
  final String id;
  final String vehicleId;
  final String title;
  final DocumentCategory category;
  final String localFilePath;
  final String fileName;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;

  const VehicleDocumentModel({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.category,
    required this.localFilePath,
    required this.fileName,
    this.issueDate,
    this.expiryDate,
    this.notes,
    required this.createdAt,
  });

  bool isExpired({DateTime? now}) {
    if (expiryDate == null) return false;
    final current = now ?? DateTime.now();
    return current.isAfter(expiryDate!);
  }

  bool isExpiringSoon({DateTime? now, int daysThreshold = 30}) {
    if (expiryDate == null || isExpired(now: now)) return false;
    final current = now ?? DateTime.now();
    final daysLeft = expiryDate!.difference(current).inDays;
    return daysLeft >= 0 && daysLeft <= daysThreshold;
  }

  int? daysUntilExpiry({DateTime? now}) {
    if (expiryDate == null) return null;
    final current = now ?? DateTime.now();
    return expiryDate!.difference(current).inDays;
  }

  bool get isPdf => fileName.toLowerCase().endsWith('.pdf') || localFilePath.toLowerCase().endsWith('.pdf');
  bool get isImage {
    final lower = (fileName + localFilePath).toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }

  VehicleDocumentModel copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DocumentCategory? category,
    String? localFilePath,
    String? fileName,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return VehicleDocumentModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      category: category ?? this.category,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'title': title,
        'category': category.name,
        'localFilePath': localFilePath,
        'fileName': fileName,
        'issueDate': issueDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VehicleDocumentModel.fromJson(Map<String, dynamic> json) => VehicleDocumentModel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        title: json['title'] as String,
        category: DocumentCategory.fromString(json['category'] as String),
        localFilePath: json['localFilePath'] as String,
        fileName: json['fileName'] as String,
        issueDate: json['issueDate'] != null ? DateTime.parse(json['issueDate'] as String) : null,
        expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
