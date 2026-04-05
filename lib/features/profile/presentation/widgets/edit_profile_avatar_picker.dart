import 'dart:io';

import 'package:flutter/material.dart';

class EditProfileAvatarPicker extends StatelessWidget {
  final File? profileImage;
  final ValueChanged<String> onSelected;

  const EditProfileAvatarPicker({
    super.key,
    required this.profileImage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 58,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
          child: profileImage == null
              ? Icon(
                  Icons.person,
                  size: 46,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
            onSelected: onSelected,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'camera', child: Text('Take photo')),
              PopupMenuItem(value: 'gallery', child: Text('Pick from gallery')),
            ],
          ),
        ),
      ],
    );
  }
}
