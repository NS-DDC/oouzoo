import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/item_model.dart';

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<ItemModel>>(
        InventoryNotifier.new);

/// 현재 장착 중인 아이템만 반환
final equippedItemsProvider = Provider<AsyncValue<Map<ItemType, ItemModel>>>((ref) {
  return ref.watch(inventoryProvider).whenData((items) {
    final equipped = items.where((i) => i.equipped);
    return {for (final item in equipped) item.itemType: item};
  });
});

class InventoryNotifier extends AsyncNotifier<List<ItemModel>> {
  @override
  Future<List<ItemModel>> build() => _fetchAll();

  Future<List<ItemModel>> _fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('inventory', orderBy: 'obtained_at DESC');
    return rows.map(ItemModel.fromMap).toList();
  }

  Future<void> equip(String itemId) async {
    final db = await DatabaseHelper.instance.database;
    final current = state.value ?? [];

    // Find the item to determine its type
    final target = current.firstWhere((i) => i.itemId == itemId);

    // Unequip existing item of same type
    await db.update(
      'inventory',
      {'equipped': 0},
      where: 'item_type = ?',
      whereArgs: [target.itemType.name],
    );

    // Equip new item
    await db.update(
      'inventory',
      {'equipped': 1},
      where: 'item_id = ?',
      whereArgs: [itemId],
    );

    state = AsyncData(await _fetchAll());
  }

  Future<void> unequip(String itemId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'inventory',
      {'equipped': 0},
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    state = AsyncData(await _fetchAll());
  }
}
