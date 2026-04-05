import 'package:flutter/material.dart';

class LocalAccountStatusViewData {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final bool useFilledButton;
  final String actionLabel;

  const LocalAccountStatusViewData({
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
    required this.useFilledButton,
    this.actionLabel = 'Logout',
  });
}
