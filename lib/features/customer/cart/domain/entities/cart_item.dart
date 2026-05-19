import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int id;
  final int menuId;
  final String menuName;
  final String unitPrice;
  final String menuImageUrl;
  final int quantity;
  final String subtotal;
  final List<CartAddon> addons;

  const CartItem({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.unitPrice,
    required this.menuImageUrl,
    this.quantity = 1,
    required this.subtotal,
    this.addons = const [],
  });

  CartItem copyWith({
    int? quantity,
    String? subtotal,
    List<CartAddon>? addons,
  }) =>
      CartItem(
        id: id,
        menuId: menuId,
        menuName: menuName,
        unitPrice: unitPrice,
        menuImageUrl: menuImageUrl,
        quantity: quantity ?? this.quantity,
        subtotal: subtotal ?? this.subtotal,
        addons: addons ?? this.addons,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as int,
    menuId: int.tryParse(json['menu_id'].toString()) ?? 0,
    menuName: json['menu']?['name'] as String? ?? json['menu_name'] as String? ?? 'Unknown',
    unitPrice: json['unit_price'] as String? ?? '0',
    menuImageUrl: json['menu_image_url'] as String? ?? '',
    quantity: int.tryParse(json['quantity'].toString()) ?? 1,
    subtotal: json['subtotal'] as String? ?? '0',
    addons: const [],
  );

  String get totalWithAddons {
    double total = double.tryParse(subtotal) ?? 0;
    for (final addon in addons) {
      total += (double.tryParse(addon.addonPrice) ?? 0) * quantity;
    }
    return total.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [
    id,
    menuId,
    menuName,
    unitPrice,
    menuImageUrl,
    quantity,
    subtotal,
    addons,
  ];
}

class CartAddon extends Equatable {
  final int id;
  final int cartId;
  final int addonId;
  final String addonName;
  final String addonPrice;

  const CartAddon({
    required this.id,
    required this.cartId,
    required this.addonId,
    required this.addonName,
    required this.addonPrice,
  });

  factory CartAddon.fromJson(Map<String, dynamic> json) => CartAddon(
    id: json['id'] as int,
    cartId: int.tryParse(json['cart_id'].toString()) ?? 0,
    addonId: int.tryParse(json['addon_id'].toString()) ?? 0,
    addonName: json['addon_name'] as String? ?? '',
    addonPrice: json['addon_price'] as String? ?? '0',
  );

  @override
  List<Object?> get props => [id, cartId, addonId, addonName, addonPrice];
}
