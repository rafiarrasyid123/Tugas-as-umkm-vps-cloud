import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final bg = backgroundColor ??
        (isOutlined ? AppTheme.surface : AppTheme.primary);
    final fg = textColor ??
        (isOutlined ? AppTheme.textPrimary : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1.0 : 0.6,
          child: Container(
            decoration: AppTheme.neoDecoration(
              color: bg,
              radius: 10,
              borderWidth: 2.2,
              shadowOffset: isEnabled ? const Offset(3.5, 3.5) : const Offset(1, 1),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
