import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_category_management_bloc.dart';
import '../bloc/cashier_category_management_event.dart';

class CashierCategoryManagementPage extends StatelessWidget {
  const CashierCategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierCategoryManagementBloc()
        ..add(const CashierCategoryManagementStarted()),
      child: const _CashierCategoryManagementView(),
    );
  }
}

class _CashierCategoryManagementView extends StatefulWidget {
  const _CashierCategoryManagementView();

  @override
  State<_CashierCategoryManagementView> createState() =>
      _CashierCategoryManagementViewState();
}

class _CashierCategoryManagementViewState
    extends State<_CashierCategoryManagementView>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  late final AnimationController _animCtrl;

  final _categories = const <_CategoryItem>[
    _CategoryItem('Foods', Icons.restaurant_rounded, 12, Color(0xFFFF4D06)),
    _CategoryItem('Drinks', Icons.local_cafe_rounded, 8, Color(0xFF3498DB)),
    _CategoryItem('Snacks', Icons.cookie_rounded, 5, Color(0xFFF39C12)),
    _CategoryItem('Sauce', Icons.water_drop_rounded, 3, Color(0xFFE74C3C)),
    _CategoryItem('Desserts', Icons.cake_rounded, 0, Color(0xFF9B59B6)),
    _CategoryItem('Seafood', Icons.set_meal_rounded, 0, Color(0xFF2ECC71)),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddCategorySheet(context),
          backgroundColor: _accent,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Add',
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const SizedBox(height: 8),

            // --- Summary ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _StatChip(
                      label: 'Total', value: '${_categories.length}', color: _accent),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Active',
                    value: '${_categories.where((c) => c.itemCount > 0).length}',
                    color: const Color(0xFF2ECC71),
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Empty',
                    value: '${_categories.where((c) => c.itemCount == 0).length}',
                    color: const Color(0xFFF39C12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // --- Category list ---
            Expanded(
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (_, __) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final delay = (i / _categories.length).clamp(0.0, 1.0);
                      final curved = CurvedAnimation(
                        parent: _animCtrl,
                        curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
                      );
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(curved),
                        child: FadeTransition(
                          opacity: curved,
                          child: _CategoryTile(
                            item: _categories[i],
                            accent: _accent,
                            onEdit: () {},
                            onDelete: () {},
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Text(
            'Category Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New Category',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212)),
            ),
            const SizedBox(height: 22),
            _SheetTextField(label: 'Category Name'),
            const SizedBox(height: 12),
            _SheetTextField(label: 'Description'),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('Save Category',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Stat Chip ----------

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.80))),
          ],
        ),
      ),
    );
  }
}

// ---------- Category Tile ----------

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.item,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  final _CategoryItem item;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212))),
                const SizedBox(height: 3),
                Text(
                  '${item.itemCount} menu items',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B8B8B)),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_rounded,
                size: 18, color: accent.withValues(alpha: 0.60)),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                size: 18, color: const Color(0xFFE74C3C).withValues(alpha: 0.60)),
          ),
        ],
      ),
    );
  }
}

// ---------- Sheet Text Field ----------

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8B8B8B)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF4D06), width: 1.5),
        ),
      ),
    );
  }
}

// ---------- Data ----------

class _CategoryItem {
  const _CategoryItem(this.name, this.icon, this.itemCount, this.color);
  final String name;
  final IconData icon;
  final int itemCount;
  final Color color;
}
