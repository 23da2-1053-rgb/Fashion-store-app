import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/data.dart';
import '../services/cart_service.dart';
import '../theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  int _selectedColor = 0;
  bool _isFav = false;

  final List<String> _colorSwatch = ['#7B1010', '#1A7A7A', '#8B7355'];

  String _formatPrice(double price) =>
      'LKR ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  void _addToBag() {
    final product = widget.product;
    context.read<CartService>().addItem(product, _selectedSize);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.name} (Size $_selectedSize) added to bag',
                style: GoogleFonts.jost(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW BAG',
          textColor: Colors.white,
          onPressed: () {
            // Pop back — user can tap the cart tab
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final sizes =
        p.sizes.isNotEmpty ? p.sizes : ['S', 'M', 'L', 'XL'];

    // Default selectedSize to first available
    if (!sizes.contains(_selectedSize)) _selectedSize = sizes.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('THIYA FASHION'),
        actions: [
          Consumer<CartService>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () => Navigator.pop(context)),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: p.imageUrl,
                  height: 340,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(height: 340, color: AppColors.inputBg),
                ),
                if (p.badge != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.badge!.toUpperCase(),
                          style: GoogleFonts.jost(
                              fontSize: 11,
                              color: Colors.white,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),

            // Color thumbnails
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: List.generate(_colorSwatch.length, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = i),
                    child: Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _hexColor(_colorSwatch[i]),
                        borderRadius: BorderRadius.circular(10),
                        border: _selectedColor == i
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price
                  Text(p.name,
                      style: GoogleFonts.cormorant(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(_formatPrice(p.price),
                          style: GoogleFonts.jost(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      if (p.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(_formatPrice(p.originalPrice!),
                            style: GoogleFonts.jost(
                                fontSize: 16,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),

                  // Story
                  const SizedBox(height: 16),
                  Text('THE STORY',
                      style: GoogleFonts.jost(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'Hand-crafted with traditional techniques, this piece reflects the rich heritage of Sri Lankan textile artistry.',
                    style: GoogleFonts.jost(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.7),
                  ),

                  // Color swatches
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AESTHETIC',
                          style: GoogleFonts.jost(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600)),
                      Text('Select Colour',
                          style: GoogleFonts.jost(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _colorSwatch
                        .map((hex) => GestureDetector(
                              onTap: () => setState(() =>
                                  _selectedColor = _colorSwatch.indexOf(hex)),
                              child: Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: _hexColor(hex),
                                  shape: BoxShape.circle,
                                  border:
                                      _selectedColor == _colorSwatch.indexOf(hex)
                                          ? Border.all(
                                              color: AppColors.primary, width: 2)
                                          : null,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  // Sizes
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('DIMENSIONS',
                          style: GoogleFonts.jost(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600)),
                      Text('Size Guide',
                          style: GoogleFonts.jost(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sizes.map((size) {
                      final selected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          width: 52,
                          height: 44,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                          child: Center(
                            child: Text(size,
                                style: GoogleFonts.jost(
                                    fontSize: 14,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Badges
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _BadgeChip(
                          icon: Icons.verified_outlined,
                          label: 'CERTIFIED HANDLOOM'),
                      const SizedBox(width: 12),
                      _BadgeChip(
                          icon: Icons.local_shipping_outlined,
                          label: 'ISLANDWIDE DELIVERY'),
                    ],
                  ),

                  const SizedBox(height: 28),
                  // Bottom actions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isFav = !_isFav),
                        child: Container(
                          width: 52,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isFav ? Icons.favorite : Icons.favorite_border,
                            color: _isFav
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToBag,
                          icon: const Icon(Icons.shopping_bag_outlined,
                              size: 18),
                          label: const Text('Add to Bag'),
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                    ],
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

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BadgeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.jost(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
