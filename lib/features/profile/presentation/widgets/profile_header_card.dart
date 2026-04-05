import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/utils/date_text_formatter.dart';
import 'package:lung_diagnosis_app/core/widgets/fullscreen_image_view.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String id;
  final String role;
  final String status;
  final DateTime createdAt;
  final String avatarPath;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.id,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarPath.trim().isNotEmpty && File(avatarPath).existsSync()
        ? FileImage(File(avatarPath)) as ImageProvider
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F4FB8),
            Color(0xFF3B8CFF),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: avatar == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImageView(
                          image: avatar,
                          title: 'Profile photo',
                        ),
                      ),
                    );
                  },
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white.withOpacity(0.22),
              backgroundImage: avatar,
              child: avatar == null
                  ? Text(
                      name.isEmpty ? 'U' : name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: $role  •  Status: $status',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${formatIsoDateOnly(createdAt)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
