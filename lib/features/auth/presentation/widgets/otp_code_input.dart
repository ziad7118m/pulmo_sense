import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpCodeInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  late final FocusNode _focusNode;
  String _lastCompletedCode = '';

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant OtpCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  void _handleControllerChanged() {
    final digitsOnly = _normalized(widget.controller.text);
    if (digitsOnly != widget.controller.text) {
      widget.controller.value = TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
      return;
    }

    widget.onChanged?.call(digitsOnly);

    if (digitsOnly.length < widget.length) {
      _lastCompletedCode = '';
    }

    if (digitsOnly.length == widget.length && digitsOnly != _lastCompletedCode) {
      _lastCompletedCode = digitsOnly;
      widget.onCompleted?.call(digitsOnly);
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _normalized(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= widget.length) return digitsOnly;
    return digitsOnly.substring(0, widget.length);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final code = _normalized(widget.controller.text);
    final isFilled = code.length == widget.length;

    return GestureDetector(
      onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AbsorbPointer(
            absorbing: !widget.enabled,
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
              ),
            ),
          ),
          Row(
            children: List.generate(widget.length, (index) {
              final hasDigit = index < code.length;
              final isActive = widget.enabled && (index == code.length || (isFilled && index == widget.length - 1));
              final borderColor = isFilled
                  ? scheme.primary
                  : isActive
                      ? scheme.primary.withOpacity(0.70)
                      : scheme.outline.withOpacity(0.35);

              return Expanded(
                child: Container(
                  height: 62,
                  margin: EdgeInsets.only(right: index == widget.length - 1 ? 0 : 10),
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? scheme.surface
                        : scheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: isActive || isFilled ? 1.6 : 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hasDigit ? code[index] : '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
