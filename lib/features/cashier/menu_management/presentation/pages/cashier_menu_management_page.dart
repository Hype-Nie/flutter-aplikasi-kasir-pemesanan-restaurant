import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/shared/models/addon.dart';
import 'package:restaurant/shared/models/menu.dart';
import '../riverpod/cashier_menu_management_provider.dart';
import '../widgets/menu_card.dart';
import '../widgets/menu_image_picker.dart';
import '../widgets/menu_sheet_text_field.dart';

class CashierMenuManagementPage extends ConsumerStatefulWidget {
  const CashierMenuManagementPage({super.key});

  @override
  ConsumerState<CashierMenuManagementPage> createState() =>
      _CashierMenuManagementPageState();
}

class _CashierMenuManagementPageState
    extends ConsumerState<CashierMenuManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierMenuManagementProvider.notifier).fetchMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierMenuManagementProvider);

    ref.listen(cashierMenuManagementProvider, (prev, next) {
      if (next.status == CashierMenuManagementStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
      if (next.status == CashierMenuManagementStatus.success &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    });

    return _CashierMenuManagementView(
      state: state,
      onRefresh: () =>
          ref.read(cashierMenuManagementProvider.notifier).fetchMenus(),
      onCreate:
          ({
            required int categoryId,
            required String name,
            required int price,
            required bool isAvailable,
            required List<int> addonIds,
            String? description,
            XFile? imageFile,
          }) => ref
              .read(cashierMenuManagementProvider.notifier)
              .createMenu(
                categoryId: categoryId,
                name: name,
                price: price,
                isAvailable: isAvailable,
                addonIds: addonIds,
                description: description,
                imageFile: imageFile,
              ),
      onUpdate:
          (
            int id, {
            int? price,
            String? description,
            XFile? imageFile,
            String? name,
            int? categoryId,
            bool? isAvailable,
            List<int>? addonIds,
          }) => ref
              .read(cashierMenuManagementProvider.notifier)
              .updateMenu(
                id,
                price: price,
                description: description,
                imageFile: imageFile,
                name: name,
                categoryId: categoryId,
                isAvailable: isAvailable,
                addonIds: addonIds,
              ),
      onDelete: (int id) =>
          ref.read(cashierMenuManagementProvider.notifier).deleteMenu(id),
    );
  }
}

class _CashierMenuManagementView extends StatefulWidget {
  const _CashierMenuManagementView({
    required this.state,
    required this.onRefresh,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  final CashierMenuManagementState state;
  final Future<void> Function() onRefresh;
  final Future<bool> Function({
    required int categoryId,
    required String name,
    required int price,
    required bool isAvailable,
    required List<int> addonIds,
    String? description,
    XFile? imageFile,
  })
  onCreate;
  final Future<bool> Function(
    int id, {
    int? price,
    String? description,
    XFile? imageFile,
    String? name,
    int? categoryId,
    bool? isAvailable,
    List<int>? addonIds,
  })
  onUpdate;
  final Future<bool> Function(int id) onDelete;

  @override
  State<_CashierMenuManagementView> createState() =>
      _CashierMenuManagementViewState();
}

class _CashierMenuManagementViewState
    extends State<_CashierMenuManagementView> {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Menu> get _filteredMenus {
    var menus = widget.state.menus;
    // Filter by category
    if (_selectedCategoryIndex > 0 &&
        _selectedCategoryIndex <= widget.state.categories.length) {
      final selectedCategory =
          widget.state.categories[_selectedCategoryIndex - 1];
      menus = menus.where((m) => m.categoryId == selectedCategory.id).toList();
    }
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      menus = menus
          .where((m) => m.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return menus;
  }

  String _categoryNameForMenu(Menu menu) {
    final cat = widget.state.categories
        .where((c) => c.id == menu.categoryId)
        .firstOrNull;
    return cat?.name ?? 'Unknown';
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Widget _buildAddonSelector({
    required List<Addon> addons,
    required Set<int> selectedAddonIds,
    required void Function(int addonId, bool selected) onSelected,
  }) {
    if (addons.isEmpty) {
      return const Text(
        'No addons available',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8B8B8B),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: addons.map((addon) {
        final selected = selectedAddonIds.contains(addon.id);
        final disabled = !addon.isAvailable;
        final labelColor = disabled
            ? const Color(0xFFB0B0B0)
            : (selected ? _accent : const Color(0xFF121212));

        return FilterChip(
          label: Text(
            '${addon.name} • ${_formatPrice(addon.price)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          selected: selected,
          onSelected: disabled ? null : (value) => onSelected(addon.id, value),
          selectedColor: _accent.withValues(alpha: 0.12),
          backgroundColor: const Color(0xFFF5F5F5),
          checkmarkColor: _accent,
          side: BorderSide(color: selected ? _accent : const Color(0xFFDADADA)),
          showCheckmark: !disabled,
        );
      }).toList(),
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      return await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
        maxHeight: 1280,
        requestFullMetadata: false,
      );
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(CashierStrings.unexpectedError),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        widget.state.status == CashierMenuManagementStatus.loading;
    final filteredMenus = _filteredMenus;
    final categoryNames = [
      'All',
      ...widget.state.categories.map((c) => c.name),
    ];

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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.black54,
                    ),
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
                  itemCount: categoryNames.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final active = i == _selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
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
                          categoryNames[i],
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

            // --- Menu grid ---
            Expanded(
              child: isLoading && widget.state.menus.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : filteredMenus.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 64,
                            color: _accent.withValues(alpha: 0.30),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No menus found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: _accent,
                      onRefresh: widget.onRefresh,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.82,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filteredMenus.length,
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
                            child: MenuCard(
                              menu: filteredMenus[i],
                              categoryName: _categoryNameForMenu(
                                filteredMenus[i],
                              ),
                              formattedPrice: _formatPrice(
                                filteredMenus[i].price,
                              ),
                              accent: _accent,
                              onTap: () => _showMenuDetailSheet(
                                context,
                                filteredMenus[i],
                              ),
                            ),
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
              onPressed: widget.onRefresh,
              icon: Icon(Icons.refresh_rounded, size: 22, color: _accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenuSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    XFile? selectedImageFile;
    int? selectedCategoryId;
    bool isAvailable = true;
    bool isLoading = false;
    final addons = widget.state.addons;
    final selectedAddonIds = <int>{};

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
            child: SingleChildScrollView(
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

                  // Category dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedCategoryId,
                        hint: const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B8B8B),
                          ),
                        ),
                        isExpanded: true,
                        items: widget.state.categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setSheetState(() => selectedCategoryId = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  MenuSheetTextField(label: 'Menu Name', controller: nameCtrl),
                  const SizedBox(height: 12),
                  MenuSheetTextField(
                    label: 'Description',
                    controller: descCtrl,
                  ),
                  const SizedBox(height: 12),
                  MenuSheetTextField(
                    label: 'Price',
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  MenuImagePicker(
                    selectedImageFile: selectedImageFile,
                    onPickFromGallery: () async {
                      final picked = await _pickImage(ImageSource.gallery);
                      if (picked == null) return;
                      setSheetState(() => selectedImageFile = picked);
                    },
                    onPickFromCamera: () async {
                      final picked = await _pickImage(ImageSource.camera);
                      if (picked == null) return;
                      setSheetState(() => selectedImageFile = picked);
                    },
                    onClearImage: selectedImageFile == null
                        ? null
                        : () => setSheetState(() => selectedImageFile = null),
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Addons (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87.withValues(alpha: 0.80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAddonSelector(
                    addons: addons,
                    selectedAddonIds: selectedAddonIds,
                    onSelected: (addonId, selected) {
                      setSheetState(() {
                        if (selected) {
                          selectedAddonIds.add(addonId);
                        } else {
                          selectedAddonIds.remove(addonId);
                        }
                      });
                    },
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
                                  priceCtrl.text.trim().isEmpty ||
                                  selectedCategoryId == null) {
                                return;
                              }
                              final price = int.tryParse(priceCtrl.text.trim());
                              if (price == null) return;
                              setSheetState(() => isLoading = true);
                              final success = await widget.onCreate(
                                categoryId: selectedCategoryId!,
                                name: nameCtrl.text.trim(),
                                price: price,
                                isAvailable: isAvailable,
                                addonIds: selectedAddonIds.toList(),
                                description: descCtrl.text.trim(),
                                imageFile: selectedImageFile,
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
                        disabledBackgroundColor: _accent.withValues(
                          alpha: 0.50,
                        ),
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
                              'Save Menu',
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
      ),
    );
  }

  void _showMenuDetailSheet(BuildContext context, Menu menu) {
    final nameCtrl = TextEditingController(text: menu.name);
    final priceCtrl = TextEditingController(
      text: menu.price.toStringAsFixed(0),
    );
    final descCtrl = TextEditingController(text: menu.description ?? '');
    XFile? selectedImageFile;
    bool isAvailable = menu.isAvailable;
    bool isLoading = false;
    final categories = widget.state.categories;
    int? selectedCategoryId = menu.categoryId;
    final addons = widget.state.addons;
    final selectedAddonIds = widget.state.menuAddons
        .where((item) => item.menuId == menu.id)
        .map((item) => item.addonId)
        .toSet();

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
            child: SingleChildScrollView(
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
                  Text(
                    'Edit ${menu.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121212),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _categoryNameForMenu(menu),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: categories.isEmpty ? null : selectedCategoryId,
                        hint: const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B8B8B),
                          ),
                        ),
                        isExpanded: true,
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setSheetState(() => selectedCategoryId = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MenuSheetTextField(label: 'Name', controller: nameCtrl),
                  const SizedBox(height: 12),
                  MenuSheetTextField(
                    label: 'Description',
                    controller: descCtrl,
                  ),
                  const SizedBox(height: 12),
                  MenuSheetTextField(
                    label: 'Price',
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  MenuImagePicker(
                    selectedImageFile: selectedImageFile,
                    existingImageUrl: menu.imageUrl,
                    onPickFromGallery: () async {
                      final picked = await _pickImage(ImageSource.gallery);
                      if (picked == null) return;
                      setSheetState(() => selectedImageFile = picked);
                    },
                    onPickFromCamera: () async {
                      final picked = await _pickImage(ImageSource.camera);
                      if (picked == null) return;
                      setSheetState(() => selectedImageFile = picked);
                    },
                    onClearImage: selectedImageFile == null
                        ? null
                        : () => setSheetState(() => selectedImageFile = null),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Addons (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87.withValues(alpha: 0.80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAddonSelector(
                    addons: addons,
                    selectedAddonIds: selectedAddonIds,
                    onSelected: (addonId, selected) {
                      setSheetState(() {
                        if (selected) {
                          selectedAddonIds.add(addonId);
                        } else {
                          selectedAddonIds.remove(addonId);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
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
                  Row(
                    children: [
                      // Update button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final price = int.tryParse(
                                      priceCtrl.text.trim(),
                                    );
                                    if (price == null) return;
                                    setSheetState(() => isLoading = true);
                                    final success = await widget.onUpdate(
                                      menu.id,
                                      name: nameCtrl.text.trim(),
                                      price: price,
                                      description: descCtrl.text.trim(),
                                      imageFile: selectedImageFile,
                                      isAvailable: isAvailable,
                                      categoryId: selectedCategoryId,
                                      addonIds: selectedAddonIds.toList(),
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
                              disabledBackgroundColor: _accent.withValues(
                                alpha: 0.50,
                              ),
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
                                    'Update Menu',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Delete button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            _showDeleteDialog(context, menu);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(
                              0xFFE74C3C,
                            ).withValues(alpha: 0.10),
                            foregroundColor: const Color(0xFFE74C3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Menu menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          CashierStrings.deleteConfirmTitle,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          '${CashierStrings.deleteConfirmMessage}\n\nMenu: ${menu.name}',
          style: const TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              CashierStrings.cancel,
              style: TextStyle(color: Color(0xFF8B8B8B)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.onDelete(menu.id);
            },
            child: const Text(
              CashierStrings.delete,
              style: TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
