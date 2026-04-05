import 'package:flutter/material.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/models/menu_action_item.dart';
import 'package:lung_diagnosis_app/features/shell/presentation/widgets/menu_item.dart';

class MenuItemsSection extends StatelessWidget {
  final List<MenuActionItem> items;

  const MenuItemsSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MenuActionItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.section, () => <MenuActionItem>[]).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ...entry.value.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MenuItemWidget(item: item),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
