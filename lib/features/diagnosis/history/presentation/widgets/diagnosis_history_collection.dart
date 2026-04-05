import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/core/responsive/page_scaffold.dart';
import 'package:lung_diagnosis_app/features/diagnosis/domain/entities/diagnosis_item.dart';

class DiagnosisHistoryCollection extends StatelessWidget {
  final List<DiagnosisItem> items;
  final IndexedWidgetBuilder itemBuilder;
  final bool grid;
  final int columns;

  const DiagnosisHistoryCollection.list({
    super.key,
    required this.items,
    required this.itemBuilder,
  })  : grid = false,
        columns = 1;

  const DiagnosisHistoryCollection.grid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.columns,
  }) : grid = true;

  @override
  Widget build(BuildContext context) {
    if (!grid) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: itemBuilder(context, index),
          );
        },
      );
    }

    return PageScaffold(
      maxWidth: 1100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
