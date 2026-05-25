import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _selectedPayment = 0; // 0 = COD, 1 = Card
  bool _isPlacing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all delivery details.',
            style: GoogleFonts.jost()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cart = context.read<CartService>();
      final firestoreService = context.read<FirestoreService>();
      final paymentMethod = _selectedPayment == 0 ? 'Cash on Delivery' : 'Card';

      await firestoreService.placeOrder(
        userId: user.uid,
        items: cart.items.toList(),
        deliveryName: name,
        address: address,
        phone: phone,
        paymentMethod: paymentMethod,
        total: cart.total,
      );

      cart.clear();

      if (!mounted) return;

      // Show success and navigate to order history
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Order Placed!',
                  style: GoogleFonts.cormorant(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(
                  'Your heritage selection is confirmed. We\'ll deliver it to you soon.',
                  style: GoogleFonts.jost(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen()));
                  },
                  child: const Text('View My Orders'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to cart (now empty)
                },
                child: Text('Continue Shopping',
                    style: GoogleFonts.jost(
                        color: AppColors.textMuted, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to place order. Please try again.',
            style: GoogleFonts.jost()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('THIYA FASHION'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Checkout',
                  style: GoogleFonts.cormorant(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text(
                'Completing your curated selection from our heritage collection.',
                style: GoogleFonts.jost(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.5),
              ),
              const SizedBox(height: 28),

              // Delivery Details
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text('Delivery Details',
                      style: GoogleFonts.cormorant(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 16),
              _label('FULL NAME'),
              _textField('Aruni Perera', controller: _nameCtrl),
              const SizedBox(height: 14),
              _label('DELIVERY ADDRESS'),
              _textField('No. 42, Galle Road, Colombo 03, Sri Lanka',
                  controller: _addressCtrl, maxLines: 2),
              const SizedBox(height: 14),
              _label('PHONE NUMBER'),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius:
                          const BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                    child: Text('+94',
                        style: GoogleFonts.jost(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                      child: _textField('77 123 4567',
                          controller: _phoneCtrl, leftRadius: 0)),
                ],
              ),

              const SizedBox(height: 28),
              // Payment method
              Row(
                children: [
                  const Icon(Icons.payment_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text('Payment Method',
                      style: GoogleFonts.cormorant(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 14),
              _PaymentOption(
                title: 'Cash on Delivery',
                subtitle: 'Pay when your Atelier package arrives',
                badge: 'RECOMMENDED',
                selected: _selectedPayment == 0,
                onTap: () => setState(() => _selectedPayment = 0),
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                title: 'Credit / Debit Card',
                subtitle: '',
                selected: _selectedPayment == 1,
                onTap: () => setState(() => _selectedPayment = 1),
                trailing: Row(
                  children: ['VISA', 'MC']
                      .map((s) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s,
                                style: GoogleFonts.jost(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ),

              // Secure checkout
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Secure Checkout',
                              style: GoogleFonts.jost(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          Text(
                              'Your personal data is encrypted and protected by Sri Lankan privacy standards.',
                              style: GoogleFonts.jost(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Order totals — REAL values from CartService
              const SizedBox(height: 20),
              _SummaryRow(
                  label: 'Subtotal (${cart.count} items)',
                  value: cart.formatLKR(cart.subtotal)),
              const SizedBox(height: 6),
              const _SummaryRow(
                  label: 'Shipping',
                  value: 'Free',
                  valueColor: AppColors.teal),
              const SizedBox(height: 6),
              _SummaryRow(
                  label: 'Handling Fee',
                  value: cart.formatLKR(cart.handlingFee)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: GoogleFonts.cormorant(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  Text(cart.formatLKR(cart.total),
                      style: GoogleFonts.cormorant(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isPlacing ? null : _placeOrder,
                  icon: _isPlacing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_forward, size: 18),
                  label: Text(_isPlacing ? 'Placing Order...' : 'Place Order'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.jost(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600)),
      );

  Widget _textField(String hint,
      {required TextEditingController controller,
      int maxLines = 1,
      double leftRadius = 10}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.jost(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.jost(fontSize: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(leftRadius),
            bottomLeft: Radius.circular(leftRadius),
            topRight: const Radius.circular(10),
            bottomRight: const Radius.circular(10),
          ),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;
  const _PaymentOption(
      {required this.title,
      required this.subtitle,
      this.badge,
      required this.selected,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 2),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge!,
                              style: GoogleFonts.jost(
                                  fontSize: 9,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: GoogleFonts.jost(
                            fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                GoogleFonts.jost(fontSize: 14, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.jost(
                fontSize: 14,
                color: valueColor ?? AppColors.textDark,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
