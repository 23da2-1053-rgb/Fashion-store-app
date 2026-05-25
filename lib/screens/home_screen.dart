import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/data.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: AppColors.textDark),
        title: const Text('THIYA FASHION'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search the collection...',
                    hintStyle: GoogleFonts.jost(
                        color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            _HeroBanner(),
            const SizedBox(height: 28),

            // Departments
            _SectionHeader(
                title: 'The Departments',
                subtitle: 'Curated selections for every occasion'),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _DepartmentCard(label: 'Women', imageUrl: AppData.womenDeptUrl),
                  const SizedBox(width: 12),
                  _DepartmentCard(label: 'Men', imageUrl: AppData.menDeptUrl),
                  const SizedBox(width: 12),
                  _DepartmentCard(label: 'Kids', imageUrl: AppData.kidsDeptUrl),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Seasonal Edits
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Seasonal Edits',
                  style: GoogleFonts.cormorant(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SeasonalCard(
                    title: 'Festival Hub',
                    subtitle: 'Celebrate in style',
                    imageUrl: AppData.festivalHubUrl,
                    dark: true,
                  ),
                  const SizedBox(height: 10),
                  _SeasonalCard(
                    title: 'Office Luxe',
                    subtitle: '',
                    imageUrl: AppData.officeLuxeUrl,
                    dark: false,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _SmallCategoryCard(
                              label: 'Kids Wear',
                              icon: Icons.child_care)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _SmallCategoryCard(
                              label: 'Bespoke',
                              icon: Icons.diamond_outlined)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Handpicked for You — from Firestore
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Handpicked for You',
                      style: GoogleFonts.cormorant(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const Icon(Icons.tune, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Product>>(
              stream: firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No products available.',
                        style: GoogleFonts.jost(color: AppColors.textMuted)),
                  );
                }
                final products = snapshot.data!;
                final display = products.take(6).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: display.length,
                    itemBuilder: (context, index) {
                      final product = display[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: product))),
                        child: _ProductCard(product: product),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: AppData.heroBannerUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(height: 220, color: AppColors.inputBg),
            ),
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('NEW SEASON',
                        style: GoogleFonts.jost(
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text('Avurudu\nCollection',
                      style: GoogleFonts.cormorant(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1)),
                  const SizedBox(height: 4),
                  Text(
                      'Experience the heritage of Sri Lankan weaving reinvented for the modern era.',
                      style: GoogleFonts.jost(
                          fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Shop Now!',
                            style: GoogleFonts.jost(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.cormorant(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              Text(subtitle,
                  style: GoogleFonts.jost(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text('View All',
                style: GoogleFonts.jost(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  const _DepartmentCard({required this.label, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 110,
            height: 130,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(width: 110, height: 130, color: AppColors.inputBg),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.jost(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
      ],
    );
  }
}

class _SeasonalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool dark;
  const _SeasonalCard(
      {required this.title,
      required this.subtitle,
      required this.imageUrl,
      required this.dark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(height: 140, color: AppColors.inputBg),
          ),
          if (dark)
            Container(height: 140, color: Colors.black.withOpacity(0.4)),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cormorant(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : AppColors.textDark)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: GoogleFonts.jost(
                          fontSize: 12,
                          color:
                              dark ? Colors.white70 : AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SmallCategoryCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.jost(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark)),
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
        Text(
            'LKR ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
            style: GoogleFonts.jost(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
