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
      if (!mounted) return;
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva predicción')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título del activo/predicción'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Título es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción del análisis'),
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) => (value == null || value.isEmpty) ? 'Descripción es obligatoria' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoría de activo'),
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
                      decoration: const InputDecoration(labelText: 'Tendencia'),
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
        ),
      ),
    );
  }
}
