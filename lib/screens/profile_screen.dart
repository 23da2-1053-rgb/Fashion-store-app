import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editMode = false;
  bool _isSaving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _startEdit(Map<String, dynamic> data) {
    _nameCtrl.text = data['name'] ?? '';
    _phoneCtrl.text = data['phone'] ?? '';
    _addressCtrl.text = data['address'] ?? '';
    setState(() => _editMode = true);
  }

  Future<void> _saveChanges(String uid) async {
    setState(() => _isSaving = true);
    try {
      await context.read<FirestoreService>().updateUserProfile(uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
      setState(() => _editMode = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully.',
              style: GoogleFonts.jost()),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save. Please try again.',
              style: GoogleFonts.jost()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out',
            style: GoogleFonts.cormorant(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        content: Text('Are you sure you want to sign out of Thiya Fashion?',
            style: GoogleFonts.jost(fontSize: 14, color: AppColors.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.jost(color: AppColors.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthService>().logout();
      // AuthGate will automatically navigate to LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('THIYA FASHION'),
        actions: [
          if (_editMode)
            TextButton(
              onPressed: () => setState(() => _editMode = false),
              child: Text('Cancel',
                  style: GoogleFonts.jost(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
            )
          else
            IconButton(
                icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: context.read<FirestoreService>().getUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final data = snapshot.data ?? {};
          final name = data['name'] ?? 'Fashion Enthusiast';
          final email = FirebaseAuth.instance.currentUser?.email ?? '';
          final phone = data['phone'] ?? '';
          final address = data['address'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'T',
                          style: GoogleFonts.cormorant(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _startEdit(data),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child:
                              const Icon(Icons.edit, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(name,
                    style: GoogleFonts.cormorant(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                Text(email,
                    style: GoogleFonts.jost(
                        fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Heritage Member',
                      style: GoogleFonts.jost(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 28),

                // Profile details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile Details',
                              style: GoogleFonts.cormorant(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                          if (!_editMode)
                            TextButton.icon(
                              onPressed: () => _startEdit(data),
                              icon: const Icon(Icons.edit_outlined,
                                  size: 14, color: AppColors.primary),
                              label: Text('Edit',
                                  style: GoogleFonts.jost(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_editMode) ...[
                        _EditField(label: 'Full Name', controller: _nameCtrl),
                        const SizedBox(height: 14),
                        _EditField(
                            label: 'Phone Number',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 14),
                        _EditField(
                            label: 'Delivery Address',
                            controller: _addressCtrl,
                            maxLines: 2),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : () => _saveChanges(uid),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes'),
                          ),
                        ),
                      ] else ...[
                        _InfoTile(
                            icon: Icons.person_outline,
                            label: 'Full Name',
                            value: name),
                        _InfoTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: email),
                        _InfoTile(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value:
                                phone.isNotEmpty ? phone : 'Not set'),
                        _InfoTile(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: address.isNotEmpty
                                ? address
                                : 'Not set'),
                      ],

                      const SizedBox(height: 24),

                      // Menu items
                      Text('Account',
                          style: GoogleFonts.cormorant(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(height: 12),
                      _MenuTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Order History',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrderHistoryScreen())),
                      ),
                      _MenuTile(
                          icon: Icons.favorite_border,
                          label: 'Wishlist',
                          onTap: () {}),
                      _MenuTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () {}),
                      _MenuTile(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          onTap: () {}),

                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Logout
                      _MenuTile(
                        icon: Icons.logout,
                        label: 'Sign Out',
                        onTap: _handleLogout,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.jost(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.jost(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  const _EditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.jost(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.jost(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textDark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style: GoogleFonts.jost(
              fontSize: 15, color: c, fontWeight: FontWeight.w500)),
      trailing:
          Icon(Icons.chevron_right, color: AppColors.border, size: 20),
      onTap: onTap,
    );
  }
}
