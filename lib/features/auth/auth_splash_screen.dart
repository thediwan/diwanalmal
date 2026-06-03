import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/auth_background.dart';
import '../../core/widgets/brand_logo.dart';
import '../../providers/settings_provider.dart';

/// Initial splash — routes to the correct auth entry point.
class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;

    final settings = context.read<SettingsProvider>();

    if (!settings.hasAccount) {
      context.go('/auth/start');
      return;
    }

    if (!settings.isSecuritySetupComplete) {
      context.go('/auth/setup-lock');
      return;
    }

    if (settings.needsSecurityCodeScreen) {
      context.go('/auth/security-code');
      return;
    }

    if (settings.requiresUnlock) {
      context.go('/auth/unlock');
      return;
    }

    if (settings.isSetupComplete) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthBackground(
        child: Center(
          child: BrandLogo(height: 72),
        ),
      ),
    );
  }
}
