import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final horizontalPadding = isMobile ? 16.0 : 24.0;
          final maxWidth = isMobile ? double.infinity : 440.0;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF4C63D2), Color(0xFF5B4C8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 20 : 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.trending_up_sharp, size: isMobile ? 40 : 48, color: const Color(0xFF1A73E8)),
                          const SizedBox(height: 12),
                          Text('Fintech Predict', textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A2138))),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !auth.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email, color: Color(0xFF1A73E8)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 12)),
                                  ),
                                  validator: (value) => (value == null || value.isEmpty) ? 'Email es obligatorio' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  enabled: !auth.isLoading,
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 12)),
                                  ),
                                  validator: (value) => (value == null || value.isEmpty) ? 'Contraseña es obligatoria' : null,
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
                                          if (_formKey.currentState!.validate()) {
                                            final success = await auth.login(_emailController.text.trim(), _passwordController.text);
                                            if (!success) {
                                              return;
                                            }

                                            if (!context.mounted) return;
                                            final nav = Navigator.of(context);
                                            if (auth.user?.role == 'admin') {
                                              nav.pushReplacementNamed('/admin-dashboard');
                                            } else {
                                              nav.pushReplacementNamed('/client-home');
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A73E8),
                                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 12)),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text('Iniciar sesión', style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: auth.isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                                  child: const Text('¿No tienes cuenta? Crear nueva', style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
