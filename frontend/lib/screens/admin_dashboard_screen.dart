import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_stats_model.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/responsive_scaffold.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final dashboard = Provider.of<DashboardProvider>(context, listen: false);
    
    final connectivity = await Connectivity().checkConnectivity();
    if (!mounted) return;

    final bool isOffline = connectivity.contains(ConnectivityResult.none);
    await dashboard.fetchStats(token: auth.token, useCache: isOffline);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context);
    
    return ResponsiveScaffold(
      appBarTitle: const Text('Admin Dashboard'),
      drawer: const AppNavigationDrawer(currentRoute: '/admin-dashboard'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMobile = constraints.maxWidth < 600;
          final horizontalPadding = isMobile ? 8.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: dashboard.isLoading
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 80), child: CircularProgressIndicator()))
                : dashboard.stats == null
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.orange),
                              const SizedBox(height: 16),
                              const Text(
                                'Error de conexión con el servidor',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dashboard.error ?? 'No se pudieron cargar los datos del dashboard.',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _loadStats,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar conexión'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Banner
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Panel de Administración', style: TextStyle(fontSize: isMobile ? 15 : 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Monitoreo de métricas, tendencias y minería de datos', style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Section Selector Tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _buildSectionTab(0, 'Métricas', Icons.grid_view_rounded, isMobile)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildSectionTab(1, 'Gráficas', Icons.bar_chart_rounded, isMobile)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildSectionTab(2, 'Analítica', Icons.psychology_rounded, isMobile)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab 0: Métricas Clave y Flujo
                          if (_selectedTab == 0) ...[
                            Text('Métricas de Rendimiento', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: isMobile ? 2 : (isWide ? 4 : 2),
                              crossAxisSpacing: isMobile ? 8 : 10,
                              mainAxisSpacing: isMobile ? 8 : 10,
                              childAspectRatio: isMobile ? 1.3 : (isWide ? 1.5 : 1.4),
                              children: [
                                _buildStatCard('Total Usuarios', dashboard.stats!.totalUsers.toString(), Icons.people, Colors.indigo),
                                _buildStatCard('Pendientes', dashboard.stats!.pending.toString(), Icons.hourglass_empty_rounded, Colors.amber),
                                _buildStatCard('Aprobadas', dashboard.stats!.approved.toString(), Icons.check_circle_outline, Colors.blue),
                                _buildStatCard('Completadas', dashboard.stats!.completed.toString(), Icons.task_alt, Colors.green),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildStatusDistributionChartCard(dashboard.stats!),
                          ],

                          // Tab 1: Análisis Gráfico y Tendencias
                          if (_selectedTab == 1) ...[
                            Text('Análisis Gráfico y Tendencias', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildProbabilityChartCard(dashboard.stats!)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTrendChartCard(dashboard.stats!)),
                                ],
                              )
                            else ...[
                              _buildProbabilityChartCard(dashboard.stats!),
                              const SizedBox(height: 16),
                              _buildTrendChartCard(dashboard.stats!),
                            ],
                          ],

                          // Tab 2: Analítica Avanzada y Minería
                          if (_selectedTab == 2) ...[
                            Text('Analítica Avanzada y Minería de Datos', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildScatterPlotCard(dashboard.stats!)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildHistogramCard(dashboard.stats!)),
                                ],
                              )
                            else ...[
                              _buildScatterPlotCard(dashboard.stats!),
                              const SizedBox(height: 16),
                              _buildHistogramCard(dashboard.stats!),
                            ],
                            const SizedBox(height: 16),
                            _buildDataMiningCard(dashboard.stats!),
                          ],
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTab(int index, String label, IconData icon, bool isMobile) {
    final isSelected = _selectedTab == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_selectedTab != index) {
            setState(() => _selectedTab = index);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12, horizontal: isMobile ? 4 : 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A73E8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF1A73E8).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isMobile ? 16 : 18, color: isSelected ? Colors.white : Colors.black54),
              SizedBox(width: isMobile ? 4 : 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                CircleAvatar(
                  radius: 13,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, size: 15, color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            const Text('Actualizado en tiempo real', style: TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityChartCard(DashboardStatsModel stats) {
    final total = stats.totalPredictions > 0 ? stats.totalPredictions : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: Color(0xFF1A73E8), size: 18),
                SizedBox(width: 8),
                Flexible(child: Text('Distribución Probabilidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Nivel de certidumbre en análisis', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 20),
            if (stats.probabilities.isEmpty)
              const Center(child: Text('No hay datos de probabilidad registrados.'))
            else
              Column(
                children: stats.probabilities.map((p) {
                  final pct = (p.count / total * 100).clamp(0, 100);
                  Color barColor = Colors.blue;
                  if (p.range.contains('80')) {
                    barColor = const Color(0xFF22C55E);
                  } else if (p.range.contains('60')) {
                    barColor = const Color(0xFF3B82F6);
                  } else if (p.range.contains('30')) {
                    barColor = const Color(0xFFF59E0B);
                  } else {
                    barColor = const Color(0xFFEF4444);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(p.range, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Text('${p.count} (${pct.toStringAsFixed(1)}%)', style: TextStyle(color: barColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 10,
                            backgroundColor: barColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChartCard(DashboardStatsModel stats) {
    final total = stats.totalPredictions > 0 ? stats.totalPredictions : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: Color(0xFF1A73E8), size: 18),
                SizedBox(width: 8),
                Flexible(child: Text('Tendencias Mercado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Sentimiento actual en activos', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 20),
            
            // Multi-segment Breakdown Bar
            if (stats.trends.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: stats.trends.map((t) {
                      final flex = (t.count / total * 1000).toInt().clamp(1, 1000);
                      Color segColor = Colors.orange;
                      if (t.trend.toLowerCase().contains('alcista')) {
                        segColor = Colors.green;
                      } else if (t.trend.toLowerCase().contains('bajista')) {
                        segColor = Colors.red;
                      }
                      return Expanded(
                        flex: flex,
                        child: Container(color: segColor),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Column(
              children: stats.trends.map((t) {
                final pct = (t.count / total * 100).clamp(0, 100);
                IconData tIcon = Icons.trending_flat;
                Color tColor = Colors.orange;
                if (t.trend.toLowerCase().contains('alcista')) {
                  tIcon = Icons.trending_up;
                  tColor = Colors.green;
                } else if (t.trend.toLowerCase().contains('bajista')) {
                  tIcon = Icons.trending_down;
                  tColor = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: tColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(tIcon, color: tColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.trend.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 8,
                                backgroundColor: tColor.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(tColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${t.count} (${pct.toStringAsFixed(0)}%)', style: TextStyle(fontWeight: FontWeight.bold, color: tColor, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistributionChartCard(DashboardStatsModel stats) {
    final total = stats.totalPredictions > 0 ? stats.totalPredictions : 1;
    final pendingPct = (stats.pending / total * 100).clamp(0, 100).toDouble();
    final approvedPct = (stats.approved / total * 100).clamp(0, 100).toDouble();
    final completedPct = (stats.completed / total * 100).clamp(0, 100).toDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.query_stats_rounded, color: Color(0xFF1A73E8), size: 18),
                SizedBox(width: 8),
                Flexible(child: Text('Flujo Predicciones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Progreso y aprobación de análisis', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 20),
            _buildStatusItem('Pendientes de revisión', stats.pending, pendingPct, Colors.amber),
            const SizedBox(height: 12),
            _buildStatusItem('Aprobadas activas', stats.approved, approvedPct, Colors.blue),
            const SizedBox(height: 12),
            _buildStatusItem('Completadas con éxito', stats.completed, completedPct, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Text('$count ops (${pct.toStringAsFixed(1)}%)', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildScatterPlotCard(DashboardStatsModel stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bubble_chart_rounded, color: Color(0xFF1A73E8), size: 18),
                SizedBox(width: 8),
                Flexible(child: Text('Dispersión (Riesgo/Retorno)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Probabilidad vs Rendimiento', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 16),
            if (stats.scatterData.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('No hay datos de dispersión registrados.', style: TextStyle(color: Colors.grey, fontSize: 12))),
              )
            else ...[
              ClipRect(
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ScatterPlotPainter(points: stats.scatterData),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegendItem('Acciones', Colors.blue),
                  _buildLegendItem('Cryptos', Colors.orange),
                  _buildLegendItem('Forex', Colors.green),
                  _buildLegendItem('Commodities', Colors.purple),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistogramCard(DashboardStatsModel stats) {
    final maxBinCount = stats.histogramBins.fold<int>(1, (max, b) => b.count > max ? b.count : max);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.equalizer_rounded, color: Color(0xFF1A73E8), size: 18),
                SizedBox(width: 8),
                Flexible(child: Text('Histograma Distribución', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Frecuencia por intervalos', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 20),
            if (stats.histogramBins.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('No hay datos de histograma registrados.', style: TextStyle(color: Colors.grey, fontSize: 12))),
              )
            else
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: stats.histogramBins.map((bin) {
                      final heightFactor = (bin.count / maxBinCount).clamp(0.08, 1.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${bin.count}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              width: 32,
                              height: 120 * heightFactor,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(bin.range, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataMiningCard(DashboardStatsModel stats) {
    final mining = stats.dataMining;
    final confidence = mining?.confidenceIndex ?? 75.0;
    final categories = mining?.avgReturnByCategory ?? [];
    final clusters = mining?.clusters ?? [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: Color(0xFF1A73E8), size: 18),
                    SizedBox(width: 8),
                    Flexible(child: Text('Minería de Datos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Confianza: $confidence%',
                    style: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Análisis de clusters y confiabilidad', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 20),
            
            const Text('Rendimiento por Categoría:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            Column(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(cat.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (cat.avgReturn / 40).clamp(0.05, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('+${cat.avgReturn.toStringAsFixed(0)}% ret. (${cat.avgProbability.toStringAsFixed(0)}% prob)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            const Text('Clusters (Riesgo/Desempeño):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: clusters.map((cls) {
                return Chip(
                  avatar: const Icon(Icons.hub, size: 16, color: Color(0xFF1A73E8)),
                  label: Text('${cls.clusterName}: ${cls.count} activos (+${cls.avgReturn.toStringAsFixed(0)}%)'),
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class ScatterPlotPainter extends CustomPainter {
  final List<ScatterPoint> points;

  ScatterPlotPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final leftMargin = 28.0;
    final bottomMargin = 18.0;
    final chartWidth = size.width - leftMargin - 12.0;
    final chartHeight = size.height - bottomMargin - 10.0;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * (i / 4) + 10.0;
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - 12.0, y), gridPaint);
      
      final label = '${((4 - i) * 10)}%';
      textPainter.text = TextSpan(text: label, style: TextStyle(color: Colors.grey.shade600, fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    for (int i = 0; i <= 4; i++) {
      final x = leftMargin + chartWidth * (i / 4);
      canvas.drawLine(Offset(x, 10.0), Offset(x, chartHeight + 10.0), gridPaint);

      final label = '${(i * 25)}%';
      textPainter.text = TextSpan(text: label, style: TextStyle(color: Colors.grey.shade600, fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 8, chartHeight + 12.0));
    }

    // Draw Scatter points
    for (final p in points) {
      final x = leftMargin + (p.probability / 100.0).clamp(0.02, 0.98) * chartWidth;
      final y = 10.0 + chartHeight - ((p.targetReturn / 40.0).clamp(0.02, 0.98) * chartHeight);

      Color color = Colors.blue;
      if (p.category.toLowerCase().contains('crypto')) {
        color = Colors.orange;
      } else if (p.category.toLowerCase().contains('forex')) {
        color = Colors.green;
      } else if (p.category.toLowerCase().contains('commodit')) {
        color = Colors.purple;
      }

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      final outerPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset(x, y), 8, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
