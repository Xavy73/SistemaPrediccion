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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner & Financial Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: Text(
                                  (userName.isNotEmpty ? userName[0] : 'C').toUpperCase(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('¡Hola, $userName! 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  const Text('Cliente FinTech VIP', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade500.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.greenAccent),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                                SizedBox(width: 6),
                                Text('+18.4% ROI', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Balance Estimado Portafolio', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('\$24,850.00', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 8),
                          Text('USD', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildMiniBadge(Icons.analytics, '12 Operaciones Activas'),
                          _buildMiniBadge(Icons.shield, 'Riesgo Moderado'),
                          _buildMiniBadge(Icons.verified, 'Certidumbre 84%'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const Text('Acciones Rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isWide ? 1.25 : 1.15,
                  children: [
                    _buildActionCard(
                      icon: Icons.auto_graph_rounded,
                      title: 'Explorar Predicciones',
                      subtitle: 'Ver recomendaciones y análisis',
                      color: const Color(0xFF1A73E8),
                      onTap: () => Navigator.pushNamed(context, '/predictions'),
                    ),
                    _buildActionCard(
                      icon: Icons.add_chart_rounded,
                      title: 'Nueva Predicción',
                      subtitle: 'Crear análisis financiero',
                      color: const Color(0xFF059669),
                      onTap: () => Navigator.pushNamed(context, '/prediction-form'),
                    ),
                    _buildActionCard(
                      icon: Icons.person_rounded,
                      title: 'Mi Perfil',
                      subtitle: 'Gestionar datos y contraseña',
                      color: const Color(0xFF7C3AED),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    _buildActionCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Soporte FinTech',
                      subtitle: 'Asistencia y consultas',
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
                    const Text('Señales de Mercado Destacadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalTile(PredictionModel p) {
    final isUp = p.trend.toLowerCase() == 'alcista';
    final isDown = p.trend.toLowerCase() == 'bajista';
    final color = isUp ? Colors.green : (isDown ? Colors.red : Colors.orange);
    final icon = isUp ? Icons.trending_up : (isDown ? Icons.trending_down : Icons.trending_flat);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            Chip(
              label: Text(p.category),
              padding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Prob: ${p.probability.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                if (p.targetReturn > 0)
                  Text('Rendimiento: +${p.targetReturn}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                const SizedBox(width: 12),
                Text('Riesgo: ${p.riskLevel}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.pushNamed(context, '/predictions'),
      ),
    );
  }
}

