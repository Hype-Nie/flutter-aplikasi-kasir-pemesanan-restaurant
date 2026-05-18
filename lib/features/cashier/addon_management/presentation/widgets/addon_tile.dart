import 'package:flutter/material.dart';
import 'package:restaurant/shared/models/addon.dart';

class AddonTile extends StatelessWidget {
  const AddonTile({
    super.key,
    required this.addon,
    required this.formattedPrice,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  final Addon addon;
  final String formattedPrice;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _typeIcon {
    switch (addon.type.toLowerCase()) {
      case 'toppings':
        return Icons.layers_rounded;
      case 'extra':
        return Icons.add_circle_outline_rounded;
      case 'sauce':
        return Icons.water_drop_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  Color get _typeColor {
    switch (addon.type.toLowerCase()) {
      case 'toppings':
        return const Color(0xFF9B59B6);
      case 'extra':
        return const Color(0xFF3498DB);
      case 'sauce':
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
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
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
                Text(
                  addon.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        addon.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Availability indicator + delete
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: addon.isAvailable
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFFE74C3C),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: const Color(0xFF3498DB).withValues(alpha: 0.80),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: const Color(0xFFE74C3C).withValues(alpha: 0.60),
            ),
          ),
        ],
      ),
    );
  }
}
