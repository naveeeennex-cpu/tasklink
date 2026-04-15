import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Input field — filled background, md radius, ghost focus ring.
class LokalTextField extends StatefulWidget {
  const LokalTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.autofillHints,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  State<LokalTextField> createState() => _LokalTextFieldState();
}

class _LokalTextFieldState extends State<LokalTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: LokalTypography.labelLg),
        const SizedBox(height: LokalSpacing.sm),
        TextFormField(
          controller: widget.controller,
          focusNode: _focus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autofillHints: widget.autofillHints,
          style: LokalTypography.bodyLg,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: LokalTypography.bodyLg.copyWith(
              color: LokalColors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: _focused
                ? LokalColors.surfaceContainerLowest
                : LokalColors.surfaceContainerLow,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon,
                    color: LokalColors.onSurfaceVariant, size: 20),
            suffixIcon: widget.suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: LokalSpacing.lg,
              vertical: LokalSpacing.md + 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: BorderSide(
                color: LokalColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
            ),
          ),
        ),
      ],
    );
  }
}
