import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/data.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Seeding ────────────────────────────────────────────────────────────────

  /// Call once on first run. Checks if products exist before writing.
  Future<void> seedProductsIfNeeded() async {
    final snapshot = await _db.collection('products').limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // already seeded

    final batch = _db.batch();
    for (final product in AppData.seedProducts) {
      final ref = _db.collection('products').doc(product.id);
      batch.set(ref, product.toMap());
    }
    await batch.commit();
  }

  // ── Products ───────────────────────────────────────────────────────────────

  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Product>> getFeaturedProducts() {
    return _db
        .collection('products')
        .where('featured', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': '',
      'address': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>?> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required String deliveryName,
    required String address,
    required String phone,
    required String paymentMethod,
    required double total,
  }) async {
    await _db.collection('orders').add({
      'userId': userId,
      'items': items.map((i) => i.toOrderMap()).toList(),
      'deliveryName': deliveryName,
      'address': address,
      'phone': phone,
      'paymentMethod': paymentMethod,
      'total': total,
      'status': 'Confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppOrder>> getOrders(String userId) {
  return _db
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final orders = s.docs
            .map((d) => AppOrder.fromMap(d.id, d.data()))
            .toList();
        // Sort newest first in Dart — no composite index needed
        orders.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        return orders;
      });
}
}
