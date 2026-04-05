import 'package:flutter/material.dart';

enum AppNotificationType {
  reminder,
  result,
  medical,
  content,
  alert,
  schedule,
  account,
  system,
}

class AppNotificationItem {
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final AppNotificationType type;

  const AppNotificationItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.type,
  });
}
