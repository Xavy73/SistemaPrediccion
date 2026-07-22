import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({super.key});

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _probabilityController = TextEditingController();
  final _targetReturnController = TextEditingController();
  String _trend = 'alcista';
  String _category = 'Acciones';
  String _riskLevel = 'Medio';
  bool _saving = false;
  String? _error;

  Future<void> _savePrediction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await ApiService.post(
      '/predictions',
      {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'probability': double.tryParse(_probabilityController.text) ?? 0,
        'trend': _trend,
        'category': _category,
        'targetReturn': double.tryParse(_targetReturnController.text) ?? 0,
        'riskLevel': _riskLevel,
      },
      token: auth.token,
    );

    if (response.statusCode == 201) {
      _goBack();
    } else {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo guardar la predicción. Intenta de nuevo.';
      });
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
    });
  }

  void _goBack() {
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = auth.user?.role == 'admin';
      Navigator.pushReplacementNamed(context, isAdmin ? '/admin-dashboard' : '/client-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva predicción'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile ? 12.0 : 20.0;
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 20)),
                elevation: isMobile ? 6 : 10,
                child: Padding(
                  padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Título del activo/predicción', labelStyle: TextStyle(fontSize: isMobile ? 14 : 16)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Título es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Descripción del análisis', labelStyle: TextStyle(fontSize: isMobile ? 14 : 16)),
                      minLines: isMobile ? 2 : 3,
                      maxLines: isMobile ? 4 : 5,
                      validator: (value) => (value == null || value.isEmpty) ? 'Descripción es obligatoria' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(labelText: 'Categoría de activo', labelStyle: TextStyle(fontSize: isMobile ? 14 : 16)),
                      items: const [
                        DropdownMenuItem(value: 'Acciones', child: Text('Acciones')),
                        DropdownMenuItem(value: 'Cryptos', child: Text('Criptomonedas')),
                        DropdownMenuItem(value: 'Forex', child: Text('Forex / Divisas')),
                        DropdownMenuItem(value: 'Commodities', child: Text('Commodities / Materias Primas')),
                      ],
                      onChanged: (value) => setState(() => _category = value ?? 'Acciones'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(labelText: 'Monto (\$)'),
                            keyboardType: TextInputType.number,
                            validator: (value) => (value == null || double.tryParse(value) == null) ? 'Monto inválido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _targetReturnController,
                            decoration: const InputDecoration(labelText: 'Rendimiento Est. (%)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _probabilityController,
                            decoration: const InputDecoration(labelText: 'Probabilidad (%)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final number = double.tryParse(value ?? '');
                              if (number == null || number < 0 || number > 100) {
                                return '0-100%';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _riskLevel,
                            decoration: const InputDecoration(labelText: 'Nivel de Riesgo'),
                            items: const [
                              DropdownMenuItem(value: 'Bajo', child: Text('Bajo')),
                              DropdownMenuItem(value: 'Medio', child: Text('Medio')),
                              DropdownMenuItem(value: 'Alto', child: Text('Alto')),
                            ],
                            onChanged: (value) => setState(() => _riskLevel = value ?? 'Medio'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _trend,
                      decoration: InputDecoration(labelText: 'Tendencia', labelStyle: TextStyle(fontSize: isMobile ? 14 : 16)),
                      items: const [
                        DropdownMenuItem(value: 'alcista', child: Text('Alcista 📈')),
                        DropdownMenuItem(value: 'neutral', child: Text('Neutral ➡️')),
                        DropdownMenuItem(value: 'bajista', child: Text('Bajista 📉')),
                      ],
                      onChanged: (value) => setState(() => _trend = value ?? 'alcista'),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ElevatedButton(
                      onPressed: _saving ? null : _savePrediction,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar predicción'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
);
  }
}
