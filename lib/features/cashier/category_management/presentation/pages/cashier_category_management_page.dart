import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/shared/models/category.dart';
import '../riverpod/cashier_category_management_provider.dart';
import '../widgets/stat_chip.dart';
import '../widgets/category_tile.dart';
import '../widgets/category_sheet_text_field.dart';

class CashierCategoryManagementPage extends ConsumerStatefulWidget {
  const CashierCategoryManagementPage({super.key});

  @override
  ConsumerState<CashierCategoryManagementPage> createState() =>
      _CashierCategoryManagementPageState();
}

class _CashierCategoryManagementPageState
    extends ConsumerState<CashierCategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierCategoryManagementProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierCategoryManagementProvider);

    ref.listen(cashierCategoryManagementProvider, (prev, next) {
      if (next.status == CashierCategoryManagementStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
      if (next.status == CashierCategoryManagementStatus.success &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    });

    return _CashierCategoryManagementView(
      state: state,
      onRefresh: () =>
          ref.read(cashierCategoryManagementProvider.notifier).fetchCategories(),
      onAdd: (name, desc) =>
          ref.read(cashierCategoryManagementProvider.notifier).createCategory(name, desc),
      onEdit: (id, {name, description}) =>
          ref.read(cashierCategoryManagementProvider.notifier).updateCategory(id, name: name, description: description),
      onDelete: (id) =>
          ref.read(cashierCategoryManagementProvider.notifier).deleteCategory(id),
    );
  }
}

class _CashierCategoryManagementView extends StatefulWidget {
  const _CashierCategoryManagementView({
    required this.state,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final CashierCategoryManagementState state;
  final Future<void> Function() onRefresh;
  final Future<bool> Function(String name, String description) onAdd;
  final Future<bool> Function(int id, {String? name, String? description}) onEdit;
  final Future<bool> Function(int id) onDelete;

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

  static const _categoryColors = <Color>[
    Color(0xFFFF4D06),
    Color(0xFF3498DB),
    Color(0xFFF39C12),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFF2ECC71),
  ];

  static const _categoryIcons = <IconData>[
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.cookie_rounded,
    Icons.water_drop_rounded,
    Icons.cake_rounded,
    Icons.set_meal_rounded,
    Icons.fastfood_rounded,
    Icons.local_pizza_rounded,
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

  Color _colorForIndex(int index) =>
      _categoryColors[index % _categoryColors.length];

  IconData _iconForIndex(int index) =>
      _categoryIcons[index % _categoryIcons.length];

  @override
  Widget build(BuildContext context) {
    final categories = widget.state.categories;
    final isLoading =
        widget.state.status == CashierCategoryManagementStatus.loading;

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
          label: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
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
                  StatChip(
                    label: 'Total',
                    value: '${categories.length}',
                    color: _accent,
                  ),
                  const SizedBox(width: 10),
                  StatChip(
                    label: 'With Desc',
                    value:
                        '${categories.where((c) => c.description.isNotEmpty).length}',
                    color: const Color(0xFF2ECC71),
                  ),
                  const SizedBox(width: 10),
                  StatChip(
                    label: 'No Desc',
                    value:
                        '${categories.where((c) => c.description.isEmpty).length}',
                    color: const Color(0xFFF39C12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // --- Category list ---
            Expanded(
              child: isLoading && categories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: _accent.withValues(alpha: 0.30),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No categories yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap + to add your first category',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF8B8B8B),
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
                                itemCount: categories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) {
                                  final delay =
                                      (i / categories.length).clamp(0.0, 1.0);
                                  final curved = CurvedAnimation(
                                    parent: _animCtrl,
                                    curve: Interval(delay, 1.0,
                                        curve: Curves.easeOutCubic),
                                  );
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.15, 0),
                                      end: Offset.zero,
                                    ).animate(curved),
                                    child: FadeTransition(
                                      opacity: curved,
                                      child: CategoryTile(
                                        category: categories[i],
                                        color: _colorForIndex(i),
                                        icon: _iconForIndex(i),
                                        accent: _accent,
                                        onEdit: () => _showEditCategorySheet(
                                            context, categories[i]),
                                        onDelete: () =>
                                            _showDeleteDialog(
                                                context, categories[i]),
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
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
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
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 22),
                CategorySheetTextField(
                  label: 'Category Name',
                  controller: nameCtrl,
                ),
                const SizedBox(height: 12),
                CategorySheetTextField(
                  label: 'Description',
                  controller: descCtrl,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty) return;
                            setSheetState(() => isLoading = true);
                            final success = await widget.onAdd(
                              nameCtrl.text.trim(),
                              descCtrl.text.trim(),
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
                            'Save Category',
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

  void _showEditCategorySheet(BuildContext context, Category category) {
    final nameCtrl = TextEditingController(text: category.name);
    final descCtrl = TextEditingController(text: category.description);
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
                  'Edit Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 22),
                CategorySheetTextField(
                  label: 'Category Name',
                  controller: nameCtrl,
                ),
                const SizedBox(height: 12),
                CategorySheetTextField(
                  label: 'Description',
                  controller: descCtrl,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setSheetState(() => isLoading = true);
                            final success = await widget.onEdit(
                              category.id,
                              name: nameCtrl.text.trim(),
                              description: descCtrl.text.trim(),
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
                            'Update Category',
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

  void _showDeleteDialog(BuildContext context, Category category) {
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
              '${CashierStrings.deleteConfirmMessage}\n\nCategory: ${category.name}',
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
                        final success = await widget.onDelete(category.id);
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
