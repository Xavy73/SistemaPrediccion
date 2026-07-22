import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/responsive_scaffold.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _loading = true;
  String? _error;
  List<UserModel> _users = [];
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.get('/users', token: auth.token);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        if (!mounted) return;
        setState(() {
          _users = json.map((e) => UserModel.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Error al cargar usuarios (${response.statusCode})';
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

  Future<void> _toggleUserStatus(UserModel user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await ApiService.put(
      '/users/${user.id}/status',
      {'active': !user.active},
      token: auth.token,
    );
    if (response.statusCode == 200) {
      _loadUsers();
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Estás seguro de eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.delete('/users/${user.id}', token: auth.token);
      if (response.statusCode == 200) {
        _loadUsers();
      }
    }
  }

  void _showUserFormDialog([UserModel? user]) {
    final isEditing = user != null;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final companyCtrl = TextEditingController(text: user?.company ?? '');
    final passwordCtrl = TextEditingController();
    String role = user?.role ?? 'client';
    bool active = user?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Usuario' : 'Crear Nuevo Usuario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: companyCtrl,
                    decoration: const InputDecoration(labelText: 'Empresa / Entidad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    decoration: InputDecoration(
                      labelText: isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Cliente FinTech')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (val) => setDialogState(() => role = val ?? 'client'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Estado de la cuenta'),
                      subtitle: Text(active ? 'Activa' : 'Inactiva'),
                      value: active,
                      onChanged: (val) => setDialogState(() => active = val),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final navigator = Navigator.of(ctx);
                  if (isEditing) {
                    final body = <String, dynamic>{
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'company': companyCtrl.text.trim(),
                      'role': role,
                      'active': active,
                    };
                    if (passwordCtrl.text.isNotEmpty) {
                      body['password'] = passwordCtrl.text;
                    }
                    await ApiService.put('/users/${user.id}', body, token: auth.token);
                  } else {
                    await ApiService.post(
                      '/users',
                      {
                        'name': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'password': passwordCtrl.text,
                        'company': companyCtrl.text.trim(),
                        'role': role,
                      },
                      token: auth.token,
                    );
                  }
                  navigator.pop();
                  _loadUsers();
                },
                child: Text(isEditing ? 'Guardar Cambios' : 'Crear Usuario'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<UserModel> get _filteredUsers {
    return _users.where((u) {
      final matchesRole = _roleFilter == 'all' || u.role == _roleFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u.company?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesRole && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBarTitle: const Text('Gestión de Usuarios'),
      drawer: const AppNavigationDrawer(currentRoute: '/admin-users'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserFormDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Usuario'),
        backgroundColor: const Color(0xFF1A73E8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar & Filter Header
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, email o empresa...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUsers,
                  tooltip: 'Actualizar lista',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _roleFilter == 'all',
                  onSelected: (val) => setState(() => _roleFilter = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Clientes'),
                  selected: _roleFilter == 'client',
                  onSelected: (val) => setState(() => _roleFilter = 'client'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Administradores'),
                  selected: _roleFilter == 'admin',
                  onSelected: (val) => setState(() => _roleFilter = 'admin'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 50, color: Colors.orange),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadUsers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? const Center(child: Text('No hay usuarios que coincidan con la búsqueda.'))
                          : ListView.builder(
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final companyText = (user.company?.isNotEmpty == true) ? ' · ${user.company}' : '';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: user.role == 'admin' ? Colors.amber.shade100 : Colors.blue.shade100,
                                      child: Icon(
                                        user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                                        color: user.role == 'admin' ? Colors.amber.shade900 : Colors.blue.shade900,
                                      ),
                                    ),
                                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${user.email} · ${user.role.toUpperCase()}$companyText'),
                                    trailing: Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            user.active ? Icons.check_circle : Icons.block,
                                            color: user.active ? Colors.green : Colors.red,
                                          ),
                                          tooltip: user.active ? 'Desactivar' : 'Activar',
                                          onPressed: () => _toggleUserStatus(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                          tooltip: 'Editar',
                                          onPressed: () => _showUserFormDialog(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          tooltip: 'Eliminar',
                                          onPressed: () => _deleteUser(user),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
