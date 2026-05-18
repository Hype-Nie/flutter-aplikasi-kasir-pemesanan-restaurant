import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuImagePicker extends StatelessWidget {
  const MenuImagePicker({
    super.key,
    required this.selectedImageFile,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    this.onClearImage,
    this.existingImageUrl,
  });

  final XFile? selectedImageFile;
  final String? existingImageUrl;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback? onClearImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Image',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 160,
            color: const Color(0xFFF5F5F5),
            child: _buildPreview(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4D06),
                  side: const BorderSide(color: Color(0xFFFF4D06)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickFromCamera,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4D06),
                  side: const BorderSide(color: Color(0xFFFF4D06)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (onClearImage != null) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: onClearImage,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear selected image',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (selectedImageFile != null) {
      return Image.file(File(selectedImageFile!.path), fit: BoxFit.cover);
    }

    final url = existingImageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 34, color: Color(0xFFB5B5B5)),
          SizedBox(height: 6),
          Text(
            'No image selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }
}
