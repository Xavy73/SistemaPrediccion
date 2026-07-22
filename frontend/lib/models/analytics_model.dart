class AnalyticsModel {
  final String userId;
  final double accuracy;
  final double roi;
  final double successRate;
  final int totalPredictions;
  final int completedPredictions;

  AnalyticsModel({
    required this.userId,
    required this.accuracy,
    required this.roi,
    required this.successRate,
    required this.totalPredictions,
    required this.completedPredictions,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      userId: json['userId'] ?? json['_id'] ?? '',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      roi: (json['roi'] ?? 0).toDouble(),
      successRate: (json['successRate'] ?? 0).toDouble(),
      totalPredictions: json['totalPredictions'] ?? 0,
      completedPredictions: json['completedPredictions'] ?? 0,
    );
  }
}
