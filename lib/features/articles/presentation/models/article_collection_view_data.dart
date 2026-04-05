import 'package:flutter/material.dart';

class ArticleCollectionViewData {
  final String title;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyActionText;
  final bool useResponsiveCollection;
  final bool showOwnerDelete;
  final bool showHiddenBadge;

  const ArticleCollectionViewData({
    required this.title,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyActionText,
    this.useResponsiveCollection = false,
    this.showOwnerDelete = false,
    this.showHiddenBadge = false,
  });
}
