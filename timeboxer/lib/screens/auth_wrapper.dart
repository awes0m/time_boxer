import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}