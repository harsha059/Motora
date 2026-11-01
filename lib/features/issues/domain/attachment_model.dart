class IssueAttachmentModel {
  final String id;
  final String issueId;
  final String localFilePath;
  final String fileName;
  final DateTime createdAt;

  const IssueAttachmentModel({
    required this.id,
    required this.issueId,
    required this.localFilePath,
    required this.fileName,
    required this.createdAt,
  });

  IssueAttachmentModel copyWith({
    String? id,
    String? issueId,
    String? localFilePath,
    String? fileName,
    DateTime? createdAt,
  }) {
    return IssueAttachmentModel(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
