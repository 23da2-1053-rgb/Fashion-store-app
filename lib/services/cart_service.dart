import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data.dart';

class CartService extends ChangeNotifier {
  static const _prefsKey = 'thiya_cart';
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  double get handlingFee => _items.isEmpty ? 0 : 150;

  double get total => subtotal + handlingFee;

  bool get isEmpty => _items.isEmpty;

  // ── Mutations ─────────────────────────────────────────────────────────────

  void addItem(Product product, String selectedSize) {
    final idx = _items.indexWhere((i) =>
        i.product.id == product.id && i.selectedSize == selectedSize);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: 1,
        selectedSize: selectedSize,
      ));
    }
    notifyListeners();
    _persist();
  }

  void removeItem(String productId, String selectedSize) {
    _items.removeWhere(
        (i) => i.product.id == productId && i.selectedSize == selectedSize);
    notifyListeners();
    _persist();
  }

  void increment(String productId, String selectedSize) {
    final idx = _items.indexWhere(
        (i) => i.product.id == productId && i.selectedSize == selectedSize);
    if (idx >= 0) {
      _items[idx].quantity++;
      notifyListeners();
      _persist();
    }
  }

  void decrement(String productId, String selectedSize) {
    final idx = _items.indexWhere(
        (i) => i.product.id == productId && i.selectedSize == selectedSize);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
      _persist();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _items.clear();
      _items.addAll(list.map((m) => CartItem.fromMap(m as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_items.map((i) => i.toMap()).toList()),
      );
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String formatLKR(double amount) =>
      'LKR ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
}
