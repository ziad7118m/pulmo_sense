import 'package:flutter/material.dart';

class MenuActionItem {
  final IconData icon;
  final String title;
  final String section;
  final VoidCallback onTap;
  final bool isDestructive;

  const MenuActionItem({
    required this.icon,
    required this.title,
    required this.section,
    required this.onTap,
    this.isDestructive = false,
  });
}
