import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_addon_management_bloc.dart';
import '../bloc/cashier_addon_management_event.dart';

class CashierAddonManagementPage extends StatelessWidget {
  const CashierAddonManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierAddonManagementBloc()
        ..add(const CashierAddonManagementStarted()),
      child: const _CashierAddonManagementView(),
    );
  }
}

class _CashierAddonManagementView extends StatefulWidget {
  const _CashierAddonManagementView();

  @override
  State<_CashierAddonManagementView> createState() =>
      _CashierAddonManagementViewState();
}

class _CashierAddonManagementViewState
    extends State<_CashierAddonManagementView>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  late final AnimationController _animCtrl;
  int _selectedTab = 0;

  final _tabs = const ['All', 'Toppings', 'Extra', 'Sauce'];

  final _addons = const <_AddonItem>[
    _AddonItem('Extra Cheese', 'Rp 5.000', 'Toppings', true),
    _AddonItem('Telur Ceplok', 'Rp 4.000', 'Extra', true),
    _AddonItem('Sambal Matah', 'Rp 3.000', 'Sauce', true),
    _AddonItem('Extra Nasi', 'Rp 5.000', 'Extra', false),
    _AddonItem('Mushroom', 'Rp 6.000', 'Toppings', true),
    _AddonItem('Kecap Manis', 'Rp 2.000', 'Sauce', true),
    _AddonItem('Extra Ayam', 'Rp 8.000', 'Extra', true),
    _AddonItem('Mayonnaise', 'Rp 3.000', 'Sauce', false),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
        child: FloatingActionButton(
          onPressed: () => _showAddSheet(context),
          backgroundColor: _accent,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),

            // --- Tab chips ---
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final active = i == _selectedTab;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTab = i);
                        _animCtrl
                          ..reset()
                          ..forward();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _accent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                active ? _accent : const Color(0xFFD0D0D0),
                          ),
                        ),
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : const Color(0xFF8B8B8B),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // --- Addon list ---
            Expanded(
              child: AnimatedBuilder(
                animation: _animCtrl,
                builder: (_, __) {
                  final filtered = _selectedTab == 0
                      ? _addons
                      : _addons
                          .where((a) => a.type == _tabs[_selectedTab])
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 64,
                              color: _accent.withValues(alpha: 0.25)),
                          const SizedBox(height: 12),
                          const Text(
                            'No addons found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B8B8B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final delay =
                          (i / filtered.length).clamp(0.0, 1.0);
                      final curved = CurvedAnimation(
                        parent: _animCtrl,
                        curve: Interval(delay, 1.0,
                            curve: Curves.easeOutCubic),
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(curved),
                          child:
                              _AddonTile(item: filtered[i], accent: _accent),
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
            'Addon Management',
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
              icon: Icon(Icons.sort_rounded, size: 22, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
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
            const Text('Add New Addon',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212))),
            const SizedBox(height: 22),
            _SheetTextField(label: 'Addon Name'),
            const SizedBox(height: 12),
            _SheetTextField(label: 'Price'),
            const SizedBox(height: 12),
            _SheetTextField(label: 'Type (Toppings / Extra / Sauce)'),
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
                child: const Text('Save Addon',
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

// ---------- Addon Tile ----------

class _AddonTile extends StatelessWidget {
  const _AddonTile({required this.item, required this.accent});

  final _AddonItem item;
  final Color accent;

  IconData get _typeIcon {
    switch (item.type) {
      case 'Toppings':
        return Icons.layers_rounded;
      case 'Extra':
        return Icons.add_circle_outline_rounded;
      case 'Sauce':
        return Icons.water_drop_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  Color get _typeColor {
    switch (item.type) {
      case 'Toppings':
        return const Color(0xFF9B59B6);
      case 'Extra':
        return const Color(0xFF3498DB);
      case 'Sauce':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF8B8B8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212))),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(item.price,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accent)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.type,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _typeColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toggle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: item.available ? accent : const Color(0xFFD0D0D0),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: item.available
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B8B8B)),
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

class _AddonItem {
  const _AddonItem(this.name, this.price, this.type, this.available);
  final String name;
  final String price;
  final String type;
  final bool available;
}
