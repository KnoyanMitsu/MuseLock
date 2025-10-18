  import 'package:flutter/material.dart';

  class Button extends StatelessWidget {
    final String name;
    final IconData? icon;
    final VoidCallback nav;
    final double? sizeFont;
    final bool? bold;
    final double? sizeIcon;
    final double? width;
    final double? height;
    final double? shadow;
    final String value;

    const Button({
      super.key,
      required this.name,
      this.icon,
      required this.nav,
      this.sizeFont,
      this.bold,
      this.sizeIcon,
      this.width,
      this.height,
      this.shadow,
      this.value = ""
    });

    @override
    Widget build(BuildContext context) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 80,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:  Colors.grey.withValues(alpha: shadow ?? 0),
                blurRadius: 8,
                offset: const Offset(0, 10),
                spreadRadius: 1,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: nav,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: sizeIcon ?? 30),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: sizeFont ?? 15,
                        fontWeight:
                            (bold == true) ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(value),
                SizedBox(width: 10,),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
