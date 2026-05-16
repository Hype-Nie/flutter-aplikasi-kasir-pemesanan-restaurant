import 'package:equatable/equatable.dart';

class MenuAddon extends Equatable {
  final int id;
  final int menuId;
  final int addonId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MenuAddon({
    required this.id,
    required this.menuId,
    required this.addonId,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuAddon.fromJson(Map<String, dynamic> json) {
    return MenuAddon(
      id: json['id'] as int,
      menuId: json['menu_id'] as int,
      addonId: json['addon_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'menu_id': menuId,
        'addon_id': addonId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, menuId, addonId, createdAt, updatedAt];
}
