import '../../../core/database/app_database.dart';

class ServiceVisitModel {
  final String id;
  final String vehicleId;
  final String serviceCentre;
  final DateTime visitDate;
  final int odometerReading;
  final ServiceVisitStatus status;
  final String? additionalRequests;
  final String? technicianName;
  final String? signOffDetails;
  final double? totalCost;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ServiceVisitModel({
    required this.id,
    required this.vehicleId,
    required this.serviceCentre,
    required this.visitDate,
    required this.odometerReading,
    required this.status,
    this.additionalRequests,
    this.technicianName,
    this.signOffDetails,
    this.totalCost,
    required this.createdAt,
    this.completedAt,
  });

  ServiceVisitModel copyWith({
    String? id,
    String? vehicleId,
    String? serviceCentre,
    DateTime? visitDate,
    int? odometerReading,
    ServiceVisitStatus? status,
    String? additionalRequests,
    String? technicianName,
    String? signOffDetails,
    double? totalCost,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ServiceVisitModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceCentre: serviceCentre ?? this.serviceCentre,
      visitDate: visitDate ?? this.visitDate,
      odometerReading: odometerReading ?? this.odometerReading,
      status: status ?? this.status,
      additionalRequests: additionalRequests ?? this.additionalRequests,
      technicianName: technicianName ?? this.technicianName,
      signOffDetails: signOffDetails ?? this.signOffDetails,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class ServiceVisitIssueModel {
  final String id;
  final String serviceVisitId;
  final String issueId;
  final String issueTitle;
  final String issueDescription;
  final String componentId;
  final IssuePriority issuePriority;
  final List<String> photoUrls;
  final String? technicianRemarks;
  final String? workPerformed;
  final String? partsReplaced;
  final VisitIssueResolution resolutionStatus;
  final bool followUpRequired;
  final DateTime createdAt;

  const ServiceVisitIssueModel({
    required this.id,
    required this.serviceVisitId,
    required this.issueId,
    required this.issueTitle,
    required this.issueDescription,
    required this.componentId,
    required this.issuePriority,
    this.photoUrls = const [],
    this.technicianRemarks,
    this.workPerformed,
    this.partsReplaced,
    this.resolutionStatus = VisitIssueResolution.notResolved,
    this.followUpRequired = false,
    required this.createdAt,
  });

  ServiceVisitIssueModel copyWith({
    String? id,
    String? serviceVisitId,
    String? issueId,
    String? issueTitle,
    String? issueDescription,
    String? componentId,
    IssuePriority? issuePriority,
    List<String>? photoUrls,
    String? technicianRemarks,
    String? workPerformed,
    String? partsReplaced,
    VisitIssueResolution? resolutionStatus,
    bool? followUpRequired,
    DateTime? createdAt,
  }) {
    return ServiceVisitIssueModel(
      id: id ?? this.id,
      serviceVisitId: serviceVisitId ?? this.serviceVisitId,
      issueId: issueId ?? this.issueId,
      issueTitle: issueTitle ?? this.issueTitle,
      issueDescription: issueDescription ?? this.issueDescription,
      componentId: componentId ?? this.componentId,
      issuePriority: issuePriority ?? this.issuePriority,
      photoUrls: photoUrls ?? this.photoUrls,
      technicianRemarks: technicianRemarks ?? this.technicianRemarks,
      workPerformed: workPerformed ?? this.workPerformed,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      resolutionStatus: resolutionStatus ?? this.resolutionStatus,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ServiceVisitDetailModel {
  final ServiceVisitModel visit;
  final List<ServiceVisitIssueModel> issues;

  const ServiceVisitDetailModel({
    required this.visit,
    required this.issues,
  });
}
