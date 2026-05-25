import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().login(email: email, password: password);
      // AuthGate's StreamBuilder will automatically navigate to MainShell
    } on Exception catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (raw.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Sign in failed. Please try again.';
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jost(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'THIYA FASHION',
                style: GoogleFonts.jost(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Ayubowan',
                style: GoogleFonts.cormorant(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back to Thiya Fashion. Sign in to access your curated wardrobe and heritage collections.',
                style: GoogleFonts.jost(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),

              // Email
              Text('Email Address',
                  style: GoogleFonts.jost(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration('name@example.com'),
              ),
              const SizedBox(height: 20),

              // Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Password',
                      style: GoogleFonts.jost(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Forgot password?',
                        style: GoogleFonts.jost(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration('••••••••').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sign In button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In to Thiya Fashion'),
                ),
              ),
              const SizedBox(height: 28),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('New here?',
                        style: GoogleFonts.jost(
                            fontSize: 13, color: AppColors.textMuted)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Create account button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Join the Thiya Fashion',
                    style: GoogleFonts.jost(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Text(
                  'Privacy Policy    Terms of Service    © 2025 Thiya Fashion',
                  style:
                      GoogleFonts.jost(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
