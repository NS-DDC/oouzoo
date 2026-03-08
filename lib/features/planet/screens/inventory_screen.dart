import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/gacha_pool.dart';
import '../../../core/models/item_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../controllers/inventory_controller.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎒 내 아이템'),
        backgroundColor: Colors.transparent,
      ),
      body: inventory.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎰', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(
                    '아직 아이템이 없어요',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '뽑기를 해서 펫과 장식을 모아보세요!',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ],
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

  static const _typeInfo = {
    ItemType.pet: ('🐾', '펫'),
    ItemType.decoration: ('✨', '장식'),
    ItemType.background: ('🌌', '배경'),
    ItemType.planetSkin: ('🪐', '행성 스킨'),
    ItemType.theme: ('🎨', '테마'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = <ItemType, List<ItemModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.itemType, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final info = _typeInfo[entry.key] ?? ('📦', entry.key.name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${info.$1} ${info.$2}',
                style: const TextStyle(
                  color: AppTheme.starYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: entry.value.length,
              itemBuilder: (_, i) {
                final item = entry.value[i];
                return _ItemCard(item: item);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final ItemModel item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gachaItem = getGachaItemById(item.itemId);
    final name = gachaItem?.name ?? item.itemId;
    final assetPath = gachaItem?.assetPath ?? _fallbackAsset(item);

    return GestureDetector(
      onTap: () => _showDetail(context, ref, name, assetPath),
      child: Container(
        decoration: BoxDecoration(
          color: item.equipped
              ? AppTheme.starYellow.withAlpha(20)
              : const Color(0xFF1E1E3A),
          border: item.equipped
              ? Border.all(color: AppTheme.starYellow, width: 2)
              : Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  assetPath,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) => Text(
                    _fallbackEmoji(item.itemType),
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: item.equipped
                    ? AppTheme.starYellow.withAlpha(40)
                    : Colors.black26,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.equipped
                          ? AppTheme.starYellow
                          : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.equipped)
                    const Text(
                      '장착 중',
                      style: TextStyle(
                        color: AppTheme.starYellow,
                        fontSize: 9,
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

  String _fallbackAsset(ItemModel item) {
    switch (item.itemType) {
      case ItemType.pet:
        return 'assets/images/pets/${item.itemId}.png';
      case ItemType.background:
        return 'assets/images/backgrounds/${item.itemId}.png';
      default:
        return 'assets/images/items/${item.itemId}.png';
    }
  }

  String _fallbackEmoji(ItemType type) {
    switch (type) {
      case ItemType.pet:
        return '🐾';
      case ItemType.decoration:
        return '✨';
      case ItemType.background:
        return '🌌';
      case ItemType.planetSkin:
        return '🪐';
      case ItemType.theme:
        return '🎨';
    }
  }

  void _showDetail(
      BuildContext context, WidgetRef ref, String name, String assetPath) {
    final gachaItem = getGachaItemById(item.itemId);
    final rarityLabel = gachaItem != null
        ? switch (gachaItem.rarity) {
            GachaRarity.rare => '★★★ 레어',
            GachaRarity.uncommon => '★★ 언커먼',
            GachaRarity.common => '★ 커먼',
          }
        : '';
    final rarityColor = gachaItem != null
        ? switch (gachaItem.rarity) {
            GachaRarity.rare => AppTheme.starYellow,
            GachaRarity.uncommon => AppTheme.accentCyan,
            GachaRarity.common => AppTheme.accentPink,
          }
        : Colors.white54;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                assetPath,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => Text(
                  _fallbackEmoji(item.itemType),
                  style: const TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (rarityLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                rarityLabel,
                style: TextStyle(color: rarityColor, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (item.equipped) {
                    ref
                        .read(inventoryProvider.notifier)
                        .unequip(item.itemId);
                  } else {
                    ref
                        .read(inventoryProvider.notifier)
                        .equip(item.itemId);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.equipped
                      ? Colors.white12
                      : AppTheme.nebulaPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  item.equipped ? '장착 해제' : '장착하기',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
