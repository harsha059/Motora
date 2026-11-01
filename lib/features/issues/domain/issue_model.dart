import '../../../core/database/app_database.dart';

class IssueModel {
  final String id;
  final String vehicleId;
  final String componentId;
  final String title;
  final String description;
  final IssuePriority priority;
  final DateTime dateNoticed;
  final IssueFrequency frequency;
  final List<String> photoUrls;
  final IssueStatus status;
  final String? technicianRemarks;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IssueModel({
    required this.id,
    required this.vehicleId,
    required this.componentId,
    required this.title,
    required this.description,
    required this.priority,
    required this.dateNoticed,
    required this.frequency,
    this.photoUrls = const [],
    this.status = IssueStatus.open,
    this.technicianRemarks,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  IssueModel copyWith({
    String? id,
    String? vehicleId,
    String? componentId,
    String? title,
    String? description,
    IssuePriority? priority,
    DateTime? dateNoticed,
    IssueFrequency? frequency,
    List<String>? photoUrls,
    IssueStatus? status,
    String? technicianRemarks,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IssueModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      componentId: componentId ?? this.componentId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dateNoticed: dateNoticed ?? this.dateNoticed,
      frequency: frequency ?? this.frequency,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      technicianRemarks: technicianRemarks ?? this.technicianRemarks,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
