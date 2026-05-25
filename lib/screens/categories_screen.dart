import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Women', 'Men', 'Kids', 'Footwear'];

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('THIYA FASHION'),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('SEASONAL EDIT',
                      style: GoogleFonts.jost(
                          fontSize: 11,
                          color: AppColors.badgeGold,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Text('Heritage\nCollection',
                    style: GoogleFonts.cormorant(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.1)),
              ],
            ),
          ),

          // Category tabs
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(cat,
                          style: GoogleFonts.jost(
                              fontSize: 13,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Products grid
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _selectedCategory == 'All'
                  ? firestoreService.getProducts()
                  : firestoreService
                      .getProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                        'No products in this category.',
                        style: GoogleFonts.jost(
                            color: AppColors.textMuted)),
                  );
                }
                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product))),
                      child: _ProductCard(product: product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.inputBg),
                ),
                if (product.badge != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(product.badge!,
                          style: GoogleFonts.jost(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('NEW',
                          style: GoogleFonts.jost(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border,
                        size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(product.subtitle.toUpperCase(),
            style: GoogleFonts.jost(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 0.8)),
        Text(product.name,
            style: GoogleFonts.cormorant(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Row(
          children: [
            Text(
                'LKR ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                style: GoogleFonts.jost(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
            if (product.originalPrice != null) ...[
              const SizedBox(width: 6),
              Text(
                  'LKR ${product.originalPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                  style: GoogleFonts.jost(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.lineThrough)),
            ],
          ],
        ),
      ],
    );
  }
}
