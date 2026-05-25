import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../main_shell.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedOnce();
  }

  Future<void> _seedOnce() async {
    await context.read<FirestoreService>().seedProductsIfNeeded();
    if (mounted) setState(() => _seeded = true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While Firebase is restoring auth state or seeding
        if (snapshot.connectionState == ConnectionState.waiting || !_seeded) {
          return const _SplashScreen();
        }
        if (snapshot.hasData) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'THIYA FASHION',
              style: GoogleFonts.jost(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'WHERE STYLE SPEAKS',
              style: GoogleFonts.cormorant(
                fontSize: 18,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
