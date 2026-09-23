import 'package:alpha_track/utils/app_size/app_size.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function(String?)? onValidate; // New: callback for real-time validation
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
  final Function(String)? onChanged; // Updated: proper typing

  const CustomTextField({
    super.key,
    this.controller,
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
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;
  String? errorText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;

    // Listen to controller changes for real-time validation
    if (widget.controller != null) {
      widget.controller!.addListener(_validateField);
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_validateField);
    }
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller!.text);
      if (mounted) {
        setState(() {
          errorText = error;
        });
      }

      // Callback to parent widget/controller
      widget.onValidate?.call(error);
    }
  }

  double _calculateHeight() {
    final lines = widget.maxLines ?? 1;
    final baseHeight = widget.height ?? ResponsiveUtils.height(50);
    final lineHeight = ResponsiveUtils.height(20);

    return lines == 1 ? baseHeight : baseHeight + ((lines - 1) * lineHeight);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.initialize(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.maxLines == null
              ? widget.height ?? ResponsiveUtils.height(50)
              : null,
          width: widget.width ?? double.infinity,
          constraints: widget.maxLines != null
              ? BoxConstraints(
                  minHeight: widget.height ?? ResponsiveUtils.height(50),
                  maxHeight: _calculateHeight(),
                )
              : null,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.blue50,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : (widget.borderColor ?? AppColors.black200),
              width: widget.borderSide?.width ?? 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x3F868181),
                blurRadius: 2,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            onTap: widget.onTap,
            controller: widget.controller,
            validator: widget.validator,
            obscureText: obscureText,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            maxLines: widget.maxLines ?? 1,
            style: TextStyle(
              color: widget.textColor ?? Colors.black,
              fontSize: ResponsiveUtils.width(14),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              _validateField(); // Trigger validation on change
            },
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.width(16),
                vertical: ResponsiveUtils.height(11),
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: widget.hintTextColor ?? AppColors.black200,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtils.width(14),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: widget.hintTextColor ?? AppColors.black200,
                      size: ResponsiveUtils.width(20),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap:
                          widget.onTapSuffix ??
                          () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                      child: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: widget.hintTextColor ?? AppColors.black200,
                        size: ResponsiveUtils.width(20),
                      ),
                    )
                  : null,
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
            padding: EdgeInsets.only(
              top: ResponsiveUtils.height(4),
              left: ResponsiveUtils.width(16),
            ),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: ResponsiveUtils.width(12),
              ),
            ),
          ),
      ],
    );
  }
}
