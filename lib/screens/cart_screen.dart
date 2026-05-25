import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/data.dart';
import '../theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: const Icon(Icons.menu),
            title: const Text('THIYA FASHION'),
            actions: [
              Stack(
                children: [
                  IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () {}),
                  if (cart.count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: Text('${cart.count}',
                            style: GoogleFonts.jost(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: cart.isEmpty ? _EmptyCart() : _CartBody(cart: cart),
        );
      },
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text('Your bag is empty',
              style: GoogleFonts.cormorant(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text('Discover our heritage collections',
              style: GoogleFonts.jost(
                  fontSize: 14, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── Full Cart ─────────────────────────────────────────────────────────────────
class _CartBody extends StatelessWidget {
  final CartService cart;
  const _CartBody({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR SELECTION',
              style: GoogleFonts.jost(
                  fontSize: 11,
                  color: AppColors.badgeGold,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Shopping Bag',
              style: GoogleFonts.cormorant(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),

          // Cart items
          ...cart.items.map((item) => _CartItemTile(item: item, cart: cart)),

          // Upsell
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Missing the perfect\naccessory?',
                        style: GoogleFonts.cormorant(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.2)),
                    const SizedBox(height: 4),
                    Text('Complete your look with our\nCurated Edit.',
                        style: GoogleFonts.jost(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Explore\nMore',
                      style: GoogleFonts.jost(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),

          // Order summary
          const SizedBox(height: 24),
          Text('Order Summary',
              style: GoogleFonts.cormorant(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          _SummaryRow(
              label: 'Subtotal', value: cart.formatLKR(cart.subtotal)),
          const SizedBox(height: 8),
          const _SummaryRow(
              label: 'Standard Shipping',
              value: 'Free',
              valueColor: AppColors.teal),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'Handling Fee', value: cart.formatLKR(cart.handlingFee)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED TOTAL',
                      style: GoogleFonts.jost(
                          fontSize: 10,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  Text('Total',
                      style: GoogleFonts.cormorant(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
              Text(cart.formatLKR(cart.total),
                  style: GoogleFonts.cormorant(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 16),

          // Promo code
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Promo Code',
                      hintStyle: GoogleFonts.jost(
                          fontSize: 14, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {},
                child: Text('APPLY',
                    style: GoogleFonts.jost(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen())),
              icon: const Text('Proceed to Checkout'),
              label: const Icon(Icons.arrow_forward, size: 18),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Secure Sri Lankan Gateway Encryption',
                    style: GoogleFonts.jost(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Cart Item Tile ────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartService cart;
  const _CartItemTile({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 100,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 100, height: 110, color: AppColors.inputBg),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.product.name,
                            style: GoogleFonts.cormorant(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => cart.removeItem(
                            item.product.id, item.selectedSize),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Text('Size: ${item.selectedSize}',
                      style: GoogleFonts.jost(
                          fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _QtyBtn(
                              icon: Icons.remove,
                              onTap: () => cart.decrement(
                                  item.product.id, item.selectedSize)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('${item.quantity}',
                                style: GoogleFonts.jost(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ),
                          _QtyBtn(
                              icon: Icons.add,
                              onTap: () => cart.increment(
                                  item.product.id, item.selectedSize)),
                        ],
                      ),
                      Text(
                        cart.formatLKR(item.lineTotal),
                        style: GoogleFonts.jost(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
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
            style: GoogleFonts.jost(
                fontSize: 14, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.jost(
                fontSize: 14,
                color: valueColor ?? AppColors.textDark,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
