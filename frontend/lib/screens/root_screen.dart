import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'client_home_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAuthenticated) {
      return auth.user?.role == 'admin' ? const AdminDashboardScreen() : const ClientHomeScreen();
    }

    return const LoginScreen();
  }
}
