class PredictionModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final double probability;
  final String trend;
  final String category;
  final double targetReturn;
  final String riskLevel;
  final String status;
  final String createdBy;

  PredictionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.probability,
    required this.trend,
    required this.category,
    required this.targetReturn,
    required this.riskLevel,
    required this.status,
    required this.createdBy,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      probability: (json['probability'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'neutral',
      category: json['category'] ?? 'Acciones',
      targetReturn: (json['targetReturn'] ?? 0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'Medio',
      status: json['status'] ?? 'pending',
      createdBy: json['createdBy'] is Map ? json['createdBy']['name'] ?? '' : (json['createdBy'] ?? ''),
    );
  }
}
