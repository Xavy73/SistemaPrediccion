import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _role = 'client';
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        title: const Text('Crear cuenta'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 48, color: Color(0xFF1A73E8)),
                    const SizedBox(height: 12),
                    const Text('Crear cuenta', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2138))),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      enabled: !auth.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF1A73E8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Nombre es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: !auth.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF1A73E8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty) ? 'Email es obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !auth.isLoading,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A73E8)),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF1A73E8)),
                          onPressed: auth.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Color(0xFF1A73E8), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tipo de cuenta: Cliente FinTech',
                              style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (auth.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(auth.error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final success = await auth.register(
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text,
                                role: _role,
                              );
                              if (!success) {
                                return;
                              }
                              if (!mounted) return;
                              final destination = auth.user?.role == 'admin' ? '/admin-dashboard' : '/client-home';
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacementNamed(context, destination);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Crear cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: auth.isLoading ? null : () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Ya tengo cuenta', style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
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
