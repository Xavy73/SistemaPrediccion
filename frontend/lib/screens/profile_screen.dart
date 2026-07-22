import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/responsive_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  final _passwordController = TextEditingController();
  bool _saving = false;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.user?.name ?? '');
    _companyController = TextEditingController(text: auth.user?.company ?? '');
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _message = null;
      _error = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'company': _companyController.text.trim(),
    };
    if (_passwordController.text.isNotEmpty) {
      body['password'] = _passwordController.text;
    }

    try {
      final response = await ApiService.put('/users/me', body, token: auth.token);
      if (response.statusCode == 200) {
        await auth.loadSession();
        if (!mounted) return;
        setState(() {
          _message = 'Perfil actualizado exitosamente.';
          _saving = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'No se pudo actualizar el perfil (${response.statusCode}).';
          _saving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return ResponsiveScaffold(
      appBarTitle: const Text('Mi Perfil'),
      drawer: const AppNavigationDrawer(currentRoute: '/profile'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF1A73E8),
                            child: Text(
                              (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(user?.role == 'admin' ? 'ADMINISTRADOR' : 'CLIENTE'),
                                  backgroundColor: user?.role == 'admin' ? Colors.amber.shade100 : Colors.blue.shade100,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person)),
                        validator: (val) => (val == null || val.isEmpty) ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(labelText: 'Empresa / Entidad', prefixIcon: Icon(Icons.business)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nueva contraseña (deja en blanco para mantener)',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_message != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_message!, style: TextStyle(color: Colors.green.shade900)),
                        ),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error!, style: TextStyle(color: Colors.red.shade900)),
                        ),
                      ElevatedButton(
                        onPressed: _saving ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _saving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Guardar cambios de perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
