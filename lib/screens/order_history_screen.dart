import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('THIYA FASHION'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY ORDERS',
                    style: GoogleFonts.jost(
                        fontSize: 11,
                        color: AppColors.badgeGold,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Order History',
                    style: GoogleFonts.cormorant(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('Your curated selections, delivered with care.',
                    style: GoogleFonts.jost(
                        fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<AppOrder>>(
              stream: firestoreService.getOrders(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _EmptyOrders();
                }
                final orders = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _OrderCard(order: orders[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: GoogleFonts.cormorant(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text('Your heritage selections will appear here',
              style:
                  GoogleFonts.jost(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Explore the Collection'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? DateFormat('d MMM yyyy, h:mm a').format(order.createdAt!)
        : 'Processing...';
    final itemCount =
        order.items.fold<int>(0, (sum, i) => sum + (i['quantity'] as int));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: GoogleFonts.jost(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: GoogleFonts.jost(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.border),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? '',
                                    style: GoogleFonts.cormorant(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark),
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                    'Size ${item['selectedSize']} · Qty ${item['quantity']}',
                                    style: GoogleFonts.jost(
                                        fontSize: 11,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Text(
                              'LKR ${(item['lineTotal'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                              style: GoogleFonts.jost(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                if (order.items.length > 2)
                  Text(
                      '+ ${order.items.length - 2} more item${order.items.length - 2 > 1 ? 's' : ''}',
                      style: GoogleFonts.jost(
                          fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$itemCount item${itemCount != 1 ? 's' : ''}',
                        style: GoogleFonts.jost(
                            fontSize: 12, color: AppColors.textMuted)),
                    Text(order.deliveryName,
                        style: GoogleFonts.jost(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOTAL',
                        style: GoogleFonts.jost(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            letterSpacing: 1)),
                    Text(
                        'LKR ${order.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                        style: GoogleFonts.cormorant(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status.toLowerCase()) {
      'confirmed' => (AppColors.teal, AppColors.teal.withOpacity(0.1)),
      'delivered' => (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      'cancelled' => (AppColors.primary, AppColors.primary.withOpacity(0.1)),
      _ => (AppColors.badgeGold, AppColors.badgeGold.withOpacity(0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: GoogleFonts.jost(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}
