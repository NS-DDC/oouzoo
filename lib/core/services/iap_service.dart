import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../database/database_helper.dart';
import '../utils/constants.dart';

/// In-App Purchase 서비스
/// - 광고 제거 (영구)
/// - 별 조각 패키지
/// - 프리미엄 테마
class IapService {
  static final IapService instance = IapService._();
  IapService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static final _productIds = {
    AppConstants.productAdFree,
    AppConstants.productShards100,
    AppConstants.productShards500,
    AppConstants.productThemeGalaxy,
    AppConstants.productThemeShattered,
    AppConstants.productThemeBlackhole,
  };

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (e) => debugPrint('[IAP] stream error: $e'),
    );
  }

  void dispose() => _subscription?.cancel();

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('[IAP] query error: ${response.error}');
    }
    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param); // for permanent items
  }

  Future<void> buyConsumable(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param); // for shard packs
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _deliverProduct(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    final db = await DatabaseHelper.instance.database;
    final productId = purchase.productID;

    switch (productId) {
      case AppConstants.productAdFree:
        await db.rawInsert(
          'INSERT OR IGNORE INTO purchases (product_id, purchased_at) VALUES (?, ?)',
          [productId, DateTime.now().toIso8601String()],
        );

      case AppConstants.productShards100:
        await db.rawUpdate(
          'UPDATE planet SET star_shards = star_shards + 100 WHERE id = 1',
        );

      case AppConstants.productShards500:
        await db.rawUpdate(
          'UPDATE planet SET star_shards = star_shards + 500 WHERE id = 1',
        );

      case AppConstants.productThemeGalaxy:
      case AppConstants.productThemeShattered:
      case AppConstants.productThemeBlackhole:
        await db.rawInsert(
          'INSERT OR IGNORE INTO inventory (item_id, item_type, equipped, obtained_at) VALUES (?, ?, 0, ?)',
          [productId, 'theme', DateTime.now().toIso8601String()],
        );
    }
  }

  /// Check if user has purchased ad-free
  Future<bool> isAdFree() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'purchases',
      where: 'product_id = ?',
      whereArgs: [AppConstants.productAdFree],
    );
    return rows.isNotEmpty;
  }

  /// Restore purchases (required for App Store)
  Future<void> restorePurchases() => _iap.restorePurchases();
}
