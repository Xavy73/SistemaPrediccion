import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/responsive_scaffold.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _loadingSignals = true;
  List<PredictionModel> _topPredictions = [];

  @override
  void initState() {
    super.initState();
    _loadTopPredictions();
  }

  Future<void> _loadTopPredictions() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.get('/predictions', token: auth.token);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _topPredictions = json.map((e) => PredictionModel.fromJson(e)).take(4).toList();
          _loadingSignals = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loadingSignals = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSignals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final userName = user?.name ?? 'Cliente';

    return ResponsiveScaffold(
      appBarTitle: const Text('FinTech - Portal de Inversión'),
      drawer: const AppNavigationDrawer(currentRoute: '/client-home'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMobile = constraints.maxWidth < 600;
          final horizontalPadding = isMobile ? 8.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner & Financial Summary Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    (userName.isNotEmpty ? userName[0] : 'C').toUpperCase(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('¡Hola, $userName!', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text('Cliente VIP', style: TextStyle(color: Colors.white70, fontSize: isMobile ? 10 : 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isMobile)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade500.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.greenAccent),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.trending_up, color: Colors.greenAccent, size: 12),
                                  SizedBox(width: 3),
                                  Text('+18%', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Balance Portafolio', style: TextStyle(color: Colors.white70, fontSize: isMobile ? 11 : 12)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text('\$24,850', style: TextStyle(fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Text('USD', style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 4,
                        runSpacing: 3,
                        children: [
                          _buildMiniBadge(Icons.analytics, '12 Ops', isMobile),
                          _buildMiniBadge(Icons.shield, 'Riesgo', isMobile),
                          _buildMiniBadge(Icons.verified, '84%', isMobile),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Text('Acciones Rápidas', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : (isWide ? 4 : 2),
                  crossAxisSpacing: isMobile ? 8 : 10,
                  mainAxisSpacing: isMobile ? 8 : 10,
                  childAspectRatio: isMobile ? 1.1 : (isWide ? 1.3 : 1.2),
                  children: [
                    _buildActionCard(
                      icon: Icons.auto_graph_rounded,
                      title: 'Explorar Predicciones',
                      subtitle: 'Ver recomendaciones',
                      color: const Color(0xFF1A73E8),
                      onTap: () => Navigator.pushNamed(context, '/predictions'),
                    ),
                    _buildActionCard(
                      icon: Icons.add_chart_rounded,
                      title: 'Nueva Predicción',
                      subtitle: 'Crear análisis',
                      color: const Color(0xFF059669),
                      onTap: () => Navigator.pushNamed(context, '/prediction-form'),
                    ),
                    _buildActionCard(
                      icon: Icons.person_rounded,
                      title: 'Mi Perfil',
                      subtitle: 'Gestionar datos',
                      color: const Color(0xFF7C3AED),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    _buildActionCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Soporte',
                      subtitle: 'Asistencia',
                      color: const Color(0xFFEA580C),
                      onTap: () => Navigator.pushNamed(context, '/predictions'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Section Header for Market Signals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('Señales de Mercado', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/predictions'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Market Signals Stream
                _loadingSignals
                    ? const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                    : _topPredictions.isEmpty
                        ? const Center(child: Text('No hay señales activas en este momento.'))
                        : Column(
                            children: _topPredictions.map((p) => _buildSignalTile(p)).toList(),
                          ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: isMobile ? 2 : 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 12 : 14, color: Colors.white),
          SizedBox(width: isMobile ? 4 : 6),
          Text(text, style: TextStyle(color: Colors.white, fontSize: isMobile ? 9 : 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 14 : 20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 20),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                ),
                child: Icon(icon, color: color, size: isMobile ? 20 : 24),
              ),
              const Spacer(),
              Flexible(child: Text(title, style: TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: isMobile ? 10 : 11), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalTile(PredictionModel p) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isUp = p.trend.toLowerCase() == 'alcista';
    final isDown = p.trend.toLowerCase() == 'bajista';
    final color = isUp ? Colors.green : (isDown ? Colors.red : Colors.orange);
    final icon = isUp ? Icons.trending_up : (isDown ? Icons.trending_down : Icons.trending_flat);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 16)),
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 6 : 8),
        leading: Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Icon(icon, color: color, size: isMobile ? 18 : 22),
        ),
        title: Row(
          children: [
            Expanded(child: Text(p.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (!isMobile)
              Chip(
                label: Text(p.category),
                padding: EdgeInsets.zero,
                labelStyle: TextStyle(fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFFF1F5F9),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isMobile ? 11 : 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Prob: ${p.probability.toStringAsFixed(0)}%', style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600)),
                SizedBox(width: isMobile ? 8 : 12),
                if (p.targetReturn > 0)
                  Text('+${p.targetReturn}%', style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                SizedBox(width: isMobile ? 8 : 12),
                Text(p.riskLevel, style: TextStyle(fontSize: isMobile ? 10 : 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: isMobile ? null : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, '/predictions'),
      ),
    );
  }
}

