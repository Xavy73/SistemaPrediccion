class DashboardStatsModel {
  final int totalPredictions;
  final int approved;
  final int completed;
  final int pending;
  final int totalUsers;
  final int clients;
  final int admins;
  final List<TrendCount> trends;
  final List<ProbabilityBucket> probabilities;
  final List<ScatterPoint> scatterData;
  final List<HistogramBin> histogramBins;
  final DataMiningInsight? dataMining;

  DashboardStatsModel({
    required this.totalPredictions,
    required this.approved,
    required this.completed,
    required this.pending,
    required this.totalUsers,
    required this.clients,
    required this.admins,
    required this.trends,
    required this.probabilities,
    required this.scatterData,
    required this.histogramBins,
    this.dataMining,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final trendsList = (json['trends'] ?? json['trendCounts'] ?? []) as List<dynamic>;
    final probsList = (json['probabilities'] ?? json['probabilityBuckets'] ?? []) as List<dynamic>;
    final scatterList = (json['scatterData'] ?? []) as List<dynamic>;
    final histoList = (json['histogramBins'] ?? []) as List<dynamic>;

    return DashboardStatsModel(
      totalPredictions: _toInt(json['totalPredictions'] ?? json['total']) ?? 0,
      approved: _toInt(json['approved'] ?? json['approvedCount']) ?? 0,
      completed: _toInt(json['completed'] ?? json['completedCount']) ?? 0,
      pending: _toInt(json['pending'] ?? json['pendingCount']) ?? 0,
      totalUsers: _toInt(json['totalUsers'] ?? json['users']) ?? 0,
      clients: _toInt(json['clients']) ?? 0,
      admins: _toInt(json['admins']) ?? 0,
      trends: trendsList.map((e) => TrendCount.fromJson(_asMap(e))).toList(),
      probabilities: probsList.map((e) => ProbabilityBucket.fromJson(_asMap(e))).toList(),
      scatterData: scatterList.map((e) => ScatterPoint.fromJson(_asMap(e))).toList(),
      histogramBins: histoList.map((e) => HistogramBin.fromJson(_asMap(e))).toList(),
      dataMining: json['dataMining'] != null ? DataMiningInsight.fromJson(_asMap(json['dataMining'])) : null,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {'_id': value?.toString() ?? '', 'count': 0};
  }
}

class TrendCount {
  final String trend;
  final int count;

  TrendCount({required this.trend, required this.count});

  factory TrendCount.fromJson(Map<String, dynamic> json) {
    return TrendCount(
      trend: json['_id']?.toString() ?? json['trend']?.toString() ?? 'General',
      count: DashboardStatsModel._toInt(json['count']) ?? 0,
    );
  }
}

class ProbabilityBucket {
  final String range;
  final int count;

  ProbabilityBucket({required this.range, required this.count});

  factory ProbabilityBucket.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'];
    String rangeLabel = 'Rango general';

    if (rawId != null) {
      final strId = rawId.toString();
      if (strId == '0') {
        rangeLabel = '0 - 30%';
      } else if (strId == '30') {
        rangeLabel = '30 - 60%';
      } else if (strId == '60') {
        rangeLabel = '60 - 80%';
      } else if (strId == '80') {
        rangeLabel = '80 - 100%';
      } else {
        rangeLabel = strId;
      }
    }

    return ProbabilityBucket(
      range: rangeLabel,
      count: DashboardStatsModel._toInt(json['count']) ?? 0,
    );
  }
}

class ScatterPoint {
  final String id;
  final String title;
  final String category;
  final double probability;
  final double targetReturn;
  final double amount;
  final String riskLevel;

  ScatterPoint({
    required this.id,
    required this.title,
    required this.category,
    required this.probability,
    required this.targetReturn,
    required this.amount,
    required this.riskLevel,
  });

  factory ScatterPoint.fromJson(Map<String, dynamic> json) {
    return ScatterPoint(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Acciones',
      probability: DashboardStatsModel._toDouble(json['probability']) ?? 50.0,
      targetReturn: DashboardStatsModel._toDouble(json['targetReturn']) ?? 10.0,
      amount: DashboardStatsModel._toDouble(json['amount']) ?? 1000.0,
      riskLevel: json['riskLevel']?.toString() ?? 'Medio',
    );
  }
}

class HistogramBin {
  final String range;
  final int count;
  final double totalAmount;

  HistogramBin({required this.range, required this.count, required this.totalAmount});

  factory HistogramBin.fromJson(Map<String, dynamic> json) {
    return HistogramBin(
      range: json['range']?.toString() ?? '0 - 20%',
      count: DashboardStatsModel._toInt(json['count']) ?? 0,
      totalAmount: DashboardStatsModel._toDouble(json['totalAmount']) ?? 0.0,
    );
  }
}

class DataMiningInsight {
  final double confidenceIndex;
  final List<CategoryMetric> avgReturnByCategory;
  final List<RiskCluster> clusters;

  DataMiningInsight({
    required this.confidenceIndex,
    required this.avgReturnByCategory,
    required this.clusters,
  });

  factory DataMiningInsight.fromJson(Map<String, dynamic> json) {
    final catList = (json['avgReturnByCategory'] ?? []) as List<dynamic>;
    final clusterList = (json['clusters'] ?? []) as List<dynamic>;

    return DataMiningInsight(
      confidenceIndex: DashboardStatsModel._toDouble(json['confidenceIndex']) ?? 75.0,
      avgReturnByCategory: catList.map((e) => CategoryMetric.fromJson(DashboardStatsModel._asMap(e))).toList(),
      clusters: clusterList.map((e) => RiskCluster.fromJson(DashboardStatsModel._asMap(e))).toList(),
    );
  }
}

class CategoryMetric {
  final String category;
  final double avgReturn;
  final double avgProbability;
  final int count;

  CategoryMetric({
    required this.category,
    required this.avgReturn,
    required this.avgProbability,
    required this.count,
  });

  factory CategoryMetric.fromJson(Map<String, dynamic> json) {
    return CategoryMetric(
      category: json['category']?.toString() ?? 'Acciones',
      avgReturn: DashboardStatsModel._toDouble(json['avgReturn']) ?? 0.0,
      avgProbability: DashboardStatsModel._toDouble(json['avgProbability']) ?? 0.0,
      count: DashboardStatsModel._toInt(json['count']) ?? 0,
    );
  }
}

class RiskCluster {
  final String clusterName;
  final int count;
  final double avgReturn;

  RiskCluster({
    required this.clusterName,
    required this.count,
    required this.avgReturn,
  });

  factory RiskCluster.fromJson(Map<String, dynamic> json) {
    return RiskCluster(
      clusterName: json['clusterName']?.toString() ?? 'Cluster General',
      count: DashboardStatsModel._toInt(json['count']) ?? 0,
      avgReturn: DashboardStatsModel._toDouble(json['avgReturn']) ?? 0.0,
    );
  }
}
