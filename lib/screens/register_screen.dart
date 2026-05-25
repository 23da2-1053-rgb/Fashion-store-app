import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().register(
            name: name,
            email: email,
            password: password,
          );
      // AuthGate will navigate to MainShell automatically
    } on Exception catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.jost()),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'This email is already registered. Try signing in.';
    }
    if (raw.contains('invalid-email')) return 'Please enter a valid email address.';
    if (raw.contains('weak-password')) return 'Password is too weak. Use at least 6 characters.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Registration failed. Please try again.';
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) =>
      InputDecoration(
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
        suffixIcon: suffix,
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.jost(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'THIYA FASHION',
                style: GoogleFonts.jost(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Join Us',
                style: GoogleFonts.cormorant(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Become part of the Thiya Fashion community and discover the finest in Sri Lankan heritage fashion.',
                style: GoogleFonts.jost(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Full Name
              _label('Full Name'),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration('Aruni Perera'),
              ),
              const SizedBox(height: 20),

              // Email
              _label('Email Address'),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration('name@example.com'),
              ),
              const SizedBox(height: 20),

              // Password
              _label('Password'),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration(
                  '••••••••',
                  suffix: IconButton(
                    icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              _label('Confirm Password'),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                style: GoogleFonts.jost(fontSize: 14),
                decoration: _inputDecoration(
                  '••••••••',
                  suffix: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create My Account'),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already a member? ',
                      style:
                          GoogleFonts.jost(fontSize: 14, color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
