import 'package:flutter/material.dart';
import '../utils/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.isLoading = false,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
              ? Colors.transparent
              : backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: isOutlined 
              ? AppTheme.primaryColor
              : textColor ?? Colors.white,
          elevation: isOutlined ? 0 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined
                ? BorderSide(color: AppTheme.primaryColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOutlined
                          ? AppTheme.primaryColor
                          : textColor ?? Colors.white,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
} 