import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_menu_management_bloc.dart';
import '../bloc/cashier_menu_management_event.dart';

class CashierMenuManagementPage extends StatelessWidget {
  const CashierMenuManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CashierMenuManagementBloc()..add(const CashierMenuManagementStarted()),
      child: const _CashierMenuManagementView(),
    );
  }
}

class _CashierMenuManagementView extends StatefulWidget {
  const _CashierMenuManagementView();

  @override
  State<_CashierMenuManagementView> createState() =>
      _CashierMenuManagementViewState();
}

class _CashierMenuManagementViewState
    extends State<_CashierMenuManagementView> {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  int _selectedCategory = 0;
  final _categories = const ['All', 'Foods', 'Drinks', 'Snacks', 'Sauce'];
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
        builder: (_, value, child) =>
            Transform.scale(scale: value, child: child),
        child: FloatingActionButton(
          onPressed: () => _showAddMenuSheet(context),
          backgroundColor: _accent,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- App bar ---
            _buildAppBar(context),

            // --- Search bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.search, size: 24, color: Colors.black54),
                    hintText: 'Search menu...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF848484),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // --- Category chips ---
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final active = i == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _accent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? _accent : const Color(0xFFD0D0D0),
                          ),
                        ),
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                active ? Colors.white : const Color(0xFF8B8B8B),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // --- Menu grid ---
            Expanded(
              child: _MenuGrid(accent: _accent),
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
            'Menu Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.filter_list_rounded,
                  size: 22, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AddMenuSheet(),
    );
  }
}

// ---------- Menu Grid ----------

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.accent});

  final Color accent;

  static const _items = [
    _MenuItem('Nasi Goreng', 'Rp 25.000', 'Foods', true),
    _MenuItem('Mie Ayam', 'Rp 20.000', 'Foods', true),
    _MenuItem('Es Teh Manis', 'Rp 8.000', 'Drinks', true),
    _MenuItem('Ayam Geprek', 'Rp 22.000', 'Foods', false),
    _MenuItem('Jus Alpukat', 'Rp 15.000', 'Drinks', true),
    _MenuItem('Kerupuk', 'Rp 5.000', 'Snacks', true),
    _MenuItem('Sate Ayam', 'Rp 28.000', 'Foods', true),
    _MenuItem('Sambal Terasi', 'Rp 3.000', 'Sauce', true),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 350 + (i * 80)),
          curve: Curves.easeOutCubic,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          ),
          child: _MenuCard(item: _items[i], accent: accent),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.accent});

  final _MenuItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(Icons.restaurant_rounded,
                          size: 40, color: accent.withValues(alpha: 0.30)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Name
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 4),

                // Price + availability
                Row(
                  children: [
                    Text(
                      item.price,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.available
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Category tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Add Menu Sheet ----------

class _AddMenuSheet extends StatelessWidget {
  const _AddMenuSheet();

  static const _accent = Color(0xFFFF4D06);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Add New Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 22),

          // Image placeholder
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _accent.withValues(alpha: 0.20),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 36, color: _accent.withValues(alpha: 0.50)),
                const SizedBox(height: 6),
                Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _accent.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Text fields
          _SheetTextField(label: 'Menu Name'),
          const SizedBox(height: 12),
          _SheetTextField(label: 'Price'),
          const SizedBox(height: 12),
          _SheetTextField(label: 'Category'),
          const SizedBox(height: 12),
          _SheetTextField(label: 'Description', maxLines: 3),
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
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Save Menu',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({required this.label, this.maxLines = 1});

  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8B8B8B),
        ),
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

// ---------- Data class ----------

class _MenuItem {
  const _MenuItem(this.name, this.price, this.category, this.available);
  final String name;
  final String price;
  final String category;
  final bool available;
}
