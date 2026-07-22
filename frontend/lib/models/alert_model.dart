class AlertModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedPredictionId;
  final bool read;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedPredictionId,
    required this.read,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedPredictionId: json['relatedPredictionId'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
