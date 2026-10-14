import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors/app_colors.dart';

/// Standard text input — matches the Figma "Input_Standard" component
/// (Inactive / Active / Filled states): white field, hairline stroke border,
/// blue border on focus, 10px radius, optional label above.
///
/// Public API preserved so every existing screen keeps working unchanged;
/// [label] is the only new (optional) field.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function(String?)? onValidate;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final double? borderRadius;
  final BorderSide? borderSide;
  final Color? borderColor;
  final bool isPassword;
  final IconData? prefixIcon;
  final Color? hintTextColor;
  final Color? textColor;
  final int? maxLines;
  final VoidCallback? onTapSuffix;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool readOnly;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.onValidate,
    this.height,
    this.width,
    this.backgroundColor,
    this.keyboardType,
    this.borderRadius,
    this.borderSide,
    this.borderColor,
    this.isPassword = false,
    this.prefixIcon,
    this.hintTextColor,
    this.textColor,
    this.maxLines,
    this.onTapSuffix,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;
  String? errorText;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
    if (widget.controller != null) {
      widget.controller!.addListener(_validateField);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller != null) {
      widget.controller!.removeListener(_validateField);
    }
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller!.text);
      if (mounted) setState(() => errorText = error);
      widget.onValidate?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 10;
    final isMultiline = widget.maxLines != null && widget.maxLines! > 1;

    Color borderColor;
    if (errorText != null) {
      borderColor = AppColors.danger;
    } else if (_focused) {
      borderColor = AppColors.primary;
    } else {
      borderColor = widget.borderColor ?? AppColors.stroke;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.caption.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
        ],
        Container(
          height: isMultiline ? null : (widget.height ?? 52),
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: _focused && errorText == null ? 1.5 : 1.0,
            ),
          ),
          alignment: isMultiline ? null : Alignment.center,
          child: TextFormField(
            focusNode: _focusNode,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            controller: widget.controller,
            validator: widget.validator,
            obscureText: obscureText,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            maxLines: widget.maxLines ?? 1,
            style: AppTextStyles.body.copyWith(
              color: widget.textColor ?? AppColors.textPrimary,
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              _validateField();
            },
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMultiline ? 14 : 12,
              ),
              hintText: widget.hintText,
              hintStyle: AppTextStyles.body.copyWith(
                color: widget.hintTextColor ?? AppColors.textMuted,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon,
                      color: AppColors.textMuted, size: 20)
                  : null,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: widget.onTapSuffix ??
                          () => setState(() => obscureText = !obscureText),
                      child: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}
