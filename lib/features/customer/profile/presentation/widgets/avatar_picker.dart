import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'dart:io';

class AvatarPicker extends ConsumerStatefulWidget {
  final String? avatarUrl;
  final void Function(String path) onAvatarSelected;

  const AvatarPicker({
    super.key,
    this.avatarUrl,
    required this.onAvatarSelected,
  });

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  String? _localPath;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _localPath = picked.path);
      widget.onAvatarSelected(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final effectiveUrl = _localPath ?? widget.avatarUrl;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.grey[200],
            backgroundImage: _localPath != null
                ? FileImage(File(_localPath!))
                : effectiveUrl != null && effectiveUrl.isNotEmpty
                ? NetworkImage(
                        '${ApiConstants.baseUrl}/assets/avatar_images/$effectiveUrl',
                      )
                      as ImageProvider
                : null,
            child: effectiveUrl == null && _localPath == null
                ? const Icon(Icons.person, size: 52, color: Colors.grey)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
