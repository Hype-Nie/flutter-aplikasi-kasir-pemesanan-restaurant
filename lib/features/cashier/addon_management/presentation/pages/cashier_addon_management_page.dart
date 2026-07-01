import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/shared/models/addon.dart';
import '../riverpod/cashier_addon_management_provider.dart';
import '../widgets/addon_tile.dart';
import '../widgets/addon_sheet_text_field.dart';

class CashierAddonManagementPage extends ConsumerStatefulWidget {
  const CashierAddonManagementPage({super.key});

  @override
  ConsumerState<CashierAddonManagementPage> createState() =>
      _CashierAddonManagementPageState();
}

class _CashierAddonManagementPageState
    extends ConsumerState<CashierAddonManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierAddonManagementProvider.notifier).fetchAddons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierAddonManagementProvider);

    ref.listen(cashierAddonManagementProvider, (prev, next) {
      if (next.status == CashierAddonManagementStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
      if (next.status == CashierAddonManagementStatus.success &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    });

    return _CashierAddonManagementView(
      state: state,
      onRefresh: () =>
          ref.read(cashierAddonManagementProvider.notifier).fetchAddons(),
      onCreate: ({
        required String name,
        required int price,
        required String type,
        required bool isAvailable,
      }) =>
          ref.read(cashierAddonManagementProvider.notifier).createAddon(
                name: name,
                price: price,
                type: type,
                isAvailable: isAvailable,
              ),
      onUpdate: ({
        required int id,
        required String name,
        required int price,
        required String type,
        required bool isAvailable,
      }) =>
          ref.read(cashierAddonManagementProvider.notifier).updateAddon(
                id: id,
                name: name,
                price: price,
                type: type,
                isAvailable: isAvailable,
              ),
      onDelete: (int id) =>
          ref.read(cashierAddonManagementProvider.notifier).deleteAddon(id),
    );
  }
}

class _CashierAddonManagementView extends StatefulWidget {
  const _CashierAddonManagementView({
    required this.state,
    required this.onRefresh,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  final CashierAddonManagementState state;
  final Future<void> Function() onRefresh;
  final Future<bool> Function({
    required String name,
    required int price,
    required String type,
    required bool isAvailable,
  }) onCreate;
  final Future<bool> Function({
    required int id,
    required String name,
    required int price,
    required String type,
    required bool isAvailable,
  }) onUpdate;
  final Future<bool> Function(int id) onDelete;

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

  List<String> get _tabs {
    final types = widget.state.addons.map((a) => a.type).toSet().toList();
    return ['All', ...types];
  }

  List<Addon> get _filteredAddons {
    if (_selectedTab == 0) return widget.state.addons;
    final tabs = _tabs;
    if (_selectedTab >= tabs.length) return widget.state.addons;
    final selectedType = tabs[_selectedTab];
    return widget.state.addons.where((a) => a.type == selectedType).toList();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  int? _parsePrice(String input) {
    var normalized = input.trim();
    if (normalized.isEmpty) return null;

    // Normalize common formats: 1.234,56 / 1.234 / 1234.00
    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else if (normalized.contains(',') && !normalized.contains('.')) {
      normalized = normalized.replaceAll(',', '.');
    } else if (!normalized.contains(',') && normalized.contains('.')) {
      final parts = normalized.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        normalized = normalized.replaceAll('.', '');
      }
    }

    final value = double.tryParse(normalized);
    if (value == null) return null;
    return value.round();
  }

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
    final isLoading =
        widget.state.status == CashierAddonManagementStatus.loading;
    final filtered = _filteredAddons;
    final tabs = _tabs;

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
                  itemCount: tabs.length,
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
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active ? _accent : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? _accent : const Color(0xFFD0D0D0),
                          ),
                        ),
                        child: Text(
                          tabs[i],
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
              child: isLoading && widget.state.addons.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 64,
                                color: _accent.withValues(alpha: 0.25),
                              ),
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
                        )
                      : RefreshIndicator(
                          color: _accent,
                          onRefresh: widget.onRefresh,
                          child: AnimatedBuilder(
                            animation: _animCtrl,
                            builder: (_, __) {
                              return ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 0, 18, 90),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
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
                                      child: AddonTile(
                                        addon: filtered[i],
                                        formattedPrice:
                                            _formatPrice(filtered[i].price),
                                        accent: _accent,
                                        onEdit: () => _showEditSheet(context, filtered[i]),
                                        onDelete: () => _showDeleteDialog(
                                            context, filtered[i]),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black87,
            ),
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
              onPressed: widget.onRefresh,
              icon: Icon(Icons.refresh_rounded, size: 22, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedType = 'Extra';
    bool isAvailable = true;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
                  'Add New Addon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 22),
                AddonSheetTextField(label: 'Addon Name', controller: nameCtrl),
                const SizedBox(height: 12),
                AddonSheetTextField(
                  label: 'Price',
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Type dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Extra', child: Text('Extra')),
                        DropdownMenuItem(
                            value: 'Toppings', child: Text('Toppings')),
                        DropdownMenuItem(value: 'Sauce', child: Text('Sauce')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Availability toggle
                Row(
                  children: [
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isAvailable,
                      activeColor: _accent,
                      onChanged: (v) {
                        setSheetState(() => isAvailable = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                priceCtrl.text.trim().isEmpty) return;
                            final price = _parsePrice(priceCtrl.text);
                            if (price == null) return;
                            setSheetState(() => isLoading = true);
                            final success = await widget.onCreate(
                              name: nameCtrl.text.trim(),
                              price: price,
                              type: selectedType,
                              isAvailable: isAvailable,
                            );
                            if (ctx.mounted) {
                              setSheetState(() => isLoading = false);
                              if (success) Navigator.pop(ctx);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _accent.withValues(alpha: 0.50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Addon',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
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

  void _showEditSheet(BuildContext context, Addon addon) {
    final nameCtrl = TextEditingController(text: addon.name);
    final priceCtrl = TextEditingController(
      text: addon.price.toStringAsFixed(0),
    );
    String selectedType = addon.type;
    bool isAvailable = addon.isAvailable;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
                  'Edit Addon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 22),
                AddonSheetTextField(label: 'Addon Name', controller: nameCtrl),
                const SizedBox(height: 12),
                AddonSheetTextField(
                  label: 'Price',
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Type dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ['Extra', 'Toppings', 'Sauce'].contains(selectedType) ? selectedType : 'Extra',
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Extra', child: Text('Extra')),
                        DropdownMenuItem(
                            value: 'Toppings', child: Text('Toppings')),
                        DropdownMenuItem(value: 'Sauce', child: Text('Sauce')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Availability toggle
                Row(
                  children: [
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isAvailable,
                      activeColor: _accent,
                      onChanged: (v) {
                        setSheetState(() => isAvailable = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                priceCtrl.text.trim().isEmpty) return;
                            final price = _parsePrice(priceCtrl.text);
                            if (price == null) return;
                            setSheetState(() => isLoading = true);
                            final success = await widget.onUpdate(
                              id: addon.id,
                              name: nameCtrl.text.trim(),
                              price: price,
                              type: selectedType,
                              isAvailable: isAvailable,
                            );
                            if (ctx.mounted) {
                              setSheetState(() => isLoading = false);
                              if (success) Navigator.pop(ctx);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _accent.withValues(alpha: 0.50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Addon',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
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

  void _showDeleteDialog(BuildContext context, Addon addon) {
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              CashierStrings.deleteConfirmTitle,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            content: Text(
              '${CashierStrings.deleteConfirmMessage}\n\nAddon: ${addon.name}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text(
                  CashierStrings.cancel,
                  style: TextStyle(color: Color(0xFF8B8B8B)),
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);
                        final success = await widget.onDelete(addon.id);
                        if (ctx.mounted) {
                          setDialogState(() => isLoading = false);
                          if (success) Navigator.pop(ctx);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE74C3C),
                        ),
                      )
                    : const Text(
                        CashierStrings.delete,
                        style: TextStyle(
                          color: Color(0xFFE74C3C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
