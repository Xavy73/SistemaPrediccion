import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prediction_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/responsive_scaffold.dart';

class PredictionListScreen extends StatefulWidget {
  const PredictionListScreen({super.key});

  @override
  State<PredictionListScreen> createState() => _PredictionListScreenState();
}

class _PredictionListScreenState extends State<PredictionListScreen> {
  bool _loading = true;
  String? _error;
  List<PredictionModel> _predictions = [];
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.get('/predictions', token: auth.token);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _predictions = json.map((e) => PredictionModel.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Error al cargar predicciones (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(String predictionId, String newStatus) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await ApiService.put(
      '/predictions/$predictionId/status',
      {'status': newStatus},
      token: auth.token,
    );
    if (response.statusCode == 200) {
      _fetchPredictions();
    }
  }

  Future<void> _deletePrediction(String predictionId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await ApiService.delete('/predictions/$predictionId', token: auth.token);
    if (response.statusCode == 200) {
      _fetchPredictions();
    }
  }

  List<PredictionModel> get _filteredPredictions {
    return _predictions.where((p) {
      final matchesStatus = _selectedStatusFilter == 'all' || p.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    return ResponsiveScaffold(
      appBarTitle: const Text('Predicciones Financieras'),
      drawer: const AppNavigationDrawer(currentRoute: '/predictions'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/prediction-form'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final horizontalPadding = isMobile ? 8.0 : 16.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter Header
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search, size: isMobile ? 18 : 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(isMobile ? 8 : 10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchPredictions,
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'all', isMobile),
                  SizedBox(width: isMobile ? 4 : 6),
                  _buildFilterChip('Pendientes', 'pending', isMobile),
                  SizedBox(width: isMobile ? 4 : 6),
                  _buildFilterChip('Aprobadas', 'approved', isMobile),
                  SizedBox(width: isMobile ? 4 : 6),
                  _buildFilterChip('Completadas', 'completed', isMobile),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                              const SizedBox(height: 12),
                              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _fetchPredictions,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : _filteredPredictions.isEmpty
                          ? const Center(
                              child: Text('No hay predicciones que coincidan con la búsqueda.'),
                            )
                          : ListView.builder(
                              itemCount: _filteredPredictions.length,
                              itemBuilder: (context, index) {
                                final p = _filteredPredictions[index];
                                return _buildPredictionCard(p, isAdmin, isMobile);
                              },
                            ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isMobile) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: isMobile ? 12 : 14)),
      selected: isSelected,
      selectedColor: const Color(0xFF1A73E8),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatusFilter = value);
        }
      },
    );
  }

  Widget _buildPredictionCard(PredictionModel p, bool isAdmin, bool isMobile) {
    final isUp = p.trend == 'alcista';
    final isDown = p.trend == 'bajista';
    final trendColor = isUp ? Colors.green : (isDown ? Colors.red : Colors.orange);
    final trendIcon = isUp ? Icons.trending_up : (isDown ? Icons.trending_down : Icons.trending_flat);

    Color statusBg = Colors.grey.shade200;
    Color statusText = Colors.black87;
    String statusLabel = 'Pendiente';
    if (p.status == 'approved') {
      statusBg = Colors.blue.shade50;
      statusText = Colors.blue.shade800;
      statusLabel = 'Aprobada';
    } else if (p.status == 'completed') {
      statusBg = Colors.green.shade50;
      statusText = Colors.green.shade800;
      statusLabel = 'Completada';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 12)),
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 10),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 4 : 6),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  ),
                  child: Icon(trendIcon, color: trendColor, size: isMobile ? 16 : 20),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: Text(p.title, style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (p.createdBy.isNotEmpty)
                        Text('Por ${p.createdBy} · ${p.category}', style: TextStyle(color: Colors.grey, fontSize: isMobile ? 10 : 11)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: isMobile ? 2 : 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusText, fontSize: isMobile ? 9 : 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.description, style: TextStyle(color: Colors.black87, fontSize: isMobile ? 11 : 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Wrap(
              spacing: isMobile ? 12 : 16,
              runSpacing: isMobile ? 6 : 8,
              children: [
                _buildMetric('Monto', '\$${p.amount.toStringAsFixed(0)}', isMobile),
                _buildMetric('Probabilidad', '${p.probability.toStringAsFixed(0)}%', isMobile),
                if (p.targetReturn > 0) _buildMetric('Rend.', '+${p.targetReturn}%', isMobile, color: Colors.green.shade700),
                _buildMetric('Riesgo', p.riskLevel, isMobile),
              ],
            ),
            if (isAdmin) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (p.status == 'pending')
                    TextButton.icon(
                      onPressed: () => _updateStatus(p.id, 'approved'),
                      icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                      label: const Text('Aprobar', style: TextStyle(color: Colors.blue)),
                    ),
                  if (p.status == 'approved')
                    TextButton.icon(
                      onPressed: () => _updateStatus(p.id, 'completed'),
                      icon: const Icon(Icons.task_alt, color: Colors.green),
                      label: const Text('Marcar completada', style: TextStyle(color: Colors.green)),
                    ),
                  TextButton.icon(
                    onPressed: () => _deletePrediction(p.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isMobile, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: isMobile ? 9 : 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14, color: color ?? Colors.black87)),
      ],
    );
  }
}
