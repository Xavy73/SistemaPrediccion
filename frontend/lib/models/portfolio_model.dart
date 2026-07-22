class PortfolioModel {
  final String id;
  final String userId;
  final double totalValue;
  final String currency;
  final List<String> predictions;
  final List<PerformanceData> performanceHistory;
  final DateTime createdAt;

  PortfolioModel({
    required this.id,
    required this.userId,
    required this.totalValue,
    required this.currency,
    required this.predictions,
    required this.performanceHistory,
    required this.createdAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      predictions: List<String>.from(json['predictions'] ?? []),
      performanceHistory: (json['performanceHistory'] as List?)
              ?.map((e) => PerformanceData.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PerformanceData {
  final DateTime date;
  final double value;
  final double changePercent;

  PerformanceData({
    required this.date,
    required this.value,
    required this.changePercent,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
    );
  }
}
