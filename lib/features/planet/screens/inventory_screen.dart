import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/item_model.dart';
import '../controllers/inventory_controller.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🎒 내 아이템')),
      body: inventory.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                '아직 아이템이 없어요.\n뽑기를 해보세요! 🎰',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return _InventoryGrid(items: items);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _InventoryGrid extends ConsumerWidget {
  final List<ItemModel> items;
  const _InventoryGrid({required this.items});

  static const _typeLabels = {
    ItemType.background: '배경',
    ItemType.planetSkin: '행성 스킨',
    ItemType.pet: '펫',
    ItemType.decoration: '장식',
    ItemType.theme: '테마',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by type
    final grouped = <ItemType, List<ItemModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.itemType, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _typeLabels[entry.key] ?? entry.key.name,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: entry.value.length,
              itemBuilder: (_, i) {
                final item = entry.value[i];
                return GestureDetector(
                  onTap: () {
                    if (item.equipped) {
                      ref.read(inventoryProvider.notifier).unequip(item.itemId);
                    } else {
                      ref.read(inventoryProvider.notifier).equip(item.itemId);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E3A),
                      border: item.equipped
                          ? Border.all(
                              color: const Color(0xFFFFD700), width: 2)
                          : Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/items/${item.itemId}.png',
                            filterQuality: FilterQuality.none,
                            errorBuilder: (_, __, ___) => const Text(
                              '✨',
                              style: TextStyle(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (item.equipped)
                          const Positioned(
                            top: 2,
                            right: 2,
                            child: Text('✅', style: TextStyle(fontSize: 10)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
