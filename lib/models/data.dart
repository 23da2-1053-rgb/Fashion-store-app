import 'package:cloud_firestore/cloud_firestore.dart';

// ── Product ────────────────────────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isNew;
  final bool featured;
  final String? badge;
  final List<String> sizes;
  final List<String> colorOptions;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isNew = false,
    this.featured = false,
    this.badge,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colorOptions = const [],
    this.description = '',
  });

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
        id: id,
        name: m['name'] ?? '',
        subtitle: m['subtitle'] ?? '',
        category: m['category'] ?? '',
        price: (m['price'] as num).toDouble(),
        originalPrice: m['originalPrice'] != null
            ? (m['originalPrice'] as num).toDouble()
            : null,
        imageUrl: m['imageUrl'] ?? '',
        isNew: m['isNew'] ?? false,
        featured: m['featured'] ?? false,
        badge: m['badge'],
        sizes: List<String>.from(m['sizes'] ?? ['S', 'M', 'L', 'XL']),
        colorOptions: List<String>.from(m['colorOptions'] ?? []),
        description: m['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'subtitle': subtitle,
        'category': category,
        'price': price,
        if (originalPrice != null) 'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'isNew': isNew,
        'featured': featured,
        if (badge != null) 'badge': badge,
        'sizes': sizes,
        'colorOptions': colorOptions,
        'description': description,
      };
}

// ── CartItem ──────────────────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
  });

  String get key => '${product.id}_$selectedSize';

  double get lineTotal => product.price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': product.id,
        'name': product.name,
        'subtitle': product.subtitle,
        'category': product.category,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
        'selectedSize': selectedSize,
      };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        product: Product(
          id: m['productId'] ?? '',
          name: m['name'] ?? '',
          subtitle: m['subtitle'] ?? '',
          category: m['category'] ?? '',
          price: (m['price'] as num).toDouble(),
          imageUrl: m['imageUrl'] ?? '',
        ),
        quantity: m['quantity'] ?? 1,
        selectedSize: m['selectedSize'] ?? 'M',
      );

  // Slimmer map stored inside Firestore orders
  Map<String, dynamic> toOrderMap() => {
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'lineTotal': lineTotal,
      };
}

// ── AppOrder ──────────────────────────────────────────────────────────────────
class AppOrder {
  final String id;
  final List<Map<String, dynamic>> items;
  final String deliveryName;
  final String address;
  final String phone;
  final double total;
  final String status;
  final DateTime? createdAt;

  const AppOrder({
    required this.id,
    required this.items,
    required this.deliveryName,
    required this.address,
    required this.phone,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory AppOrder.fromMap(String id, Map<String, dynamic> m) => AppOrder(
        id: id,
        items: List<Map<String, dynamic>>.from(m['items'] ?? []),
        deliveryName: m['deliveryName'] ?? '',
        address: m['address'] ?? '',
        phone: m['phone'] ?? '',
        total: (m['total'] as num).toDouble(),
        status: m['status'] ?? 'confirmed',
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] as Timestamp).toDate()
            : null,
      );
}

// ── Static seed data (mirrors what's in Firestore) ────────────────────────────
class AppData {
  static const String heroBannerUrl =
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&q=80';
  static const String womenDeptUrl =
      'https://images.unsplash.com/photo-1708363390847-b4af54f45273?w=700&auto=format&fit=crop&q=60';
  static const String menDeptUrl =
      'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=400&q=80';
  static const String kidsDeptUrl =
      'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=400&q=80';
  static const String festivalHubUrl =
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&q=80';
  static const String officeLuxeUrl =
      'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=800&q=80';

  /// Products used for Firestore seeding. Do NOT use these directly in UI —
  /// always read from Firestore via FirestoreService.
  static const List<Product> seedProducts = [
    Product(
      id: 'p1',
      name: 'Lotus Thread Linen Midi',
      subtitle: 'Heritage Casual',
      category: 'Women',
      price: 12500,
      featured: true,
      imageUrl:
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&q=80',
      badge: 'NEW',
      description:
          'A breathable linen midi crafted with lotus-thread techniques native to the hill country. Perfect for festive afternoons.',
    ),
    Product(
      id: 'p2',
      name: 'Geometric Batik Sarong',
      subtitle: 'Island Modern',
      category: 'Men',
      price: 8200,
      featured: true,
      isNew: true,
      imageUrl:
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=500&q=80',
      description:
          'A modern take on the classic sarong featuring geometric batik motifs inspired by the temple architecture of Anuradhapura.',
    ),
    Product(
      id: 'p3',
      name: 'Hand-Woven Royal Silk',
      subtitle: 'Deep Maroon Heritage Silk',
      category: 'Women',
      price: 42500,
      featured: true,
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1740413441109-fdc9790064d4?w=700&auto=format&fit=crop&q=60',
      badge: 'New Arrival',
      description:
          'Pure mulberry silk woven by master craftspeople in Kandy. Each piece takes three days to complete by hand.',
    ),
    Product(
      id: 'p4',
      name: 'Batik Fusion Linen',
      subtitle: 'Ocean Teal Artisanal Print',
      category: 'Men',
      price: 18900,
      isNew: true,
      imageUrl:
          'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=500&q=80',
      description:
          'Hand-printed with natural dyes sourced from the southern coast, blending traditional batik with contemporary silhouettes.',
    ),
    Product(
      id: 'p5',
      name: 'Golden Hour Handloom',
      subtitle: 'Sun-Drenched Cotton Weave',
      category: 'Men',
      price: 24000,
      imageUrl:
          'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=500&q=80',
      description:
          'Handloomed on traditional pit-looms in the Gampaha district, this piece embodies warmth in every thread.',
    ),
    Product(
      id: 'p6',
      name: 'Ivory Cloud Tunic',
      subtitle: 'Textured Sustainable Cotton',
      category: 'Women',
      price: 12500,
      imageUrl:
          'https://images.unsplash.com/photo-1602185335134-2d072c07703c?w=700&auto=format&fit=crop&q=60',
      badge: 'Campaign',
      description:
          'Crafted from sustainably sourced organic cotton, this relaxed tunic pairs with any bottom for effortless style.',
    ),
    Product(
      id: 'p7',
      name: 'Heritage Brass Sandal',
      subtitle: 'Hand-Burnished Leather',
      category: 'Footwear',
      price: 9800,
      featured: true,
      imageUrl:
          'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=500&q=80',
      sizes: ['36', '37', '38', '39', '40', '41'],
      description:
          'Hand-burnished leather sandals with brass detailing, crafted by Colombo artisans using century-old techniques.',
    ),
    Product(
      id: 'p8',
      name: 'Midnight Atelier Jacket',
      subtitle: 'Tailored Canvas & Silk',
      category: 'Men',
      price: 31200,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500&q=80',
      description:
          'A structured jacket combining canvas and silk panels, tailored in our Colombo atelier for the discerning gentleman.',
    ),
    Product(
      id: 'p9',
      name: 'Coastline Linen Pant',
      subtitle: 'Organic Sandy Beige',
      category: 'Men',
      price: 14500,
      imageUrl:
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500&q=80',
      description:
          'Wide-leg linen trousers in a sandy beige, cut to breathe in the island heat while maintaining a crisp silhouette.',
    ),
    Product(
      id: 'p10',
      name: 'Vihara Silk Batik',
      subtitle: 'Deep Garnet • Heritage Edit',
      category: 'Women',
      price: 18500,
      originalPrice: 22000,
      featured: true,
      imageUrl:
          'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=500&q=80',
      badge: 'Heritage Edit',
      colorOptions: ['#7B1010', '#1A7A7A', '#8B7355'],
      description:
          'Hand-pressed using traditional wax-resist techniques in the heart of Galle, the Vihara collection honours the geometric precision of island temple architecture.',
    ),
    Product(
      id: 'p11',
      name: 'Temple Garden Kurta',
      subtitle: 'Embroidered Festival Wear',
      category: 'Women',
      price: 16800,
      isNew: true,
      imageUrl:
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500&q=80',
      badge: 'NEW',
      description:
          'Hand-embroidered kurta with floral motifs drawn from the Peradeniya Botanical Gardens. A celebration of nature and craft.',
    ),
    Product(
      id: 'p12',
      name: 'Little Batik Explorer',
      subtitle: 'Kids Heritage Collection',
      category: 'Kids',
      price: 5200,
      imageUrl:
          'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=500&q=80',
      sizes: ['2Y', '4Y', '6Y', '8Y', '10Y'],
      description:
          'Soft batik cotton romper designed for the little ones, with child-safe natural dyes and easy snap closures.',
    ),
  ];
}
