import 'package:flutter/material.dart';

class AuthDropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const AuthDropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
      isExpanded: true,
      validator: validator,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.secondary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.secondary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.secondary, width: 2),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
