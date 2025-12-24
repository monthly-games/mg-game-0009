import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import '../game/skin_manager.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _goldManager = GetIt.I<GoldManager>();
  final _skinManager = GetIt.I<SkinManager>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          'Shop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          StreamBuilder<int>(
            stream: _goldManager.onGoldChanged,
            initialData: _goldManager.currentGold,
            builder: (context, snapshot) {
              final gold = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$gold',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF76c043),
          labelColor: const Color(0xFF76c043),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Snake Skins', icon: Icon(Icons.gesture)),
            Tab(text: 'Food Skins', icon: Icon(Icons.restaurant)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _skinManager,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [_buildSnakeTab(), _buildFoodTab()],
          );
        },
      ),
    );
  }

  Widget _buildSnakeTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: SnakeSkin.values.length,
      itemBuilder: (context, index) {
        final skin = SnakeSkin.values[index];
        final isUnlocked = _skinManager.isSnakeUnlocked(skin);
        final isSelected = _skinManager.currentSnakeSkin == skin;

        return _buildItemCard(
          name: skin.name,
          cost: skin.cost,
          isUnlocked: isUnlocked,
          isSelected: isSelected,
          color: skin.baseColor,
          onTap: () => _handleSnakeTap(skin, isUnlocked),
        );
      },
    );
  }

  Widget _buildFoodTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: FoodSkin.values.length,
      itemBuilder: (context, index) {
        final skin = FoodSkin.values[index];
        final isUnlocked = _skinManager.isFoodUnlocked(skin);
        final isSelected = _skinManager.currentFoodSkin == skin;

        // Determine preview color
        Color previewColor;
        switch (skin) {
          case FoodSkin.apple:
            previewColor = Colors.red;
            break;
          case FoodSkin.mouse:
            previewColor = Colors.grey;
            break;
          case FoodSkin.burger:
            previewColor = Colors.orange;
            break;
          case FoodSkin.diamond:
            previewColor = Colors.cyan;
            break;
          case FoodSkin.coin:
            previewColor = Colors.amber;
            break;
          case FoodSkin.potion:
            previewColor = Colors.purple;
            break;
        }

        return _buildItemCard(
          name: skin.name,
          cost: skin.cost,
          isUnlocked: isUnlocked,
          isSelected: isSelected,
          color: previewColor, // Use circle for food
          isCircle: true,
          onTap: () => _handleFoodTap(skin, isUnlocked),
        );
      },
    );
  }

  Widget _buildItemCard({
    required String name,
    required int cost,
    required bool isUnlocked,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    bool isCircle = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF76c043), width: 3)
              : Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview
            Expanded(
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: !isUnlocked
                      ? const Icon(Icons.lock, color: Colors.white54, size: 32)
                      : null,
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    const Text(
                      '선택됨',
                      style: TextStyle(
                        color: Color(0xFF76c043),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  else if (isUnlocked)
                    const Text(
                      '보유중',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$cost',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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

  Future<void> _handleSnakeTap(SnakeSkin skin, bool isUnlocked) async {
    if (isUnlocked) {
      await _skinManager.setSnakeSkin(skin);
    } else {
      if (_goldManager.currentGold >= skin.cost) {
        final success = await _skinManager.unlockSnakeSkin(skin);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchased successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough gold!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleFoodTap(FoodSkin skin, bool isUnlocked) async {
    if (isUnlocked) {
      await _skinManager.setFoodSkin(skin);
    } else {
      if (_goldManager.currentGold >= skin.cost) {
        final success = await _skinManager.unlockFoodSkin(skin);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchased successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough gold!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
