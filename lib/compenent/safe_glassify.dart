import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// A lightweight, cross-platform frosted glass widget using BackdropFilter.
/// Works without Impeller. Suitable as a drop-in replacement for simple
/// translucent glass cards and chips.
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 20,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.borderColor = const Color(0x22FFFFFF),
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Backwards-compatible wrapper if existing code used SafeGlassify.
/// Internally just composes [FrostedGlass].
class SafeGlassify extends StatelessWidget {
  const SafeGlassify({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // If shader filters are not supported, BackdropFilter still works.
    // We keep a tiny opacity tweak when unsupported.
    final bool shadersSupported = ImageFilter.isShaderFilterSupported;
    final Color bg = shadersSupported ? const Color(0x33FFFFFF) : const Color(0x22FFFFFF);

    return FrostedGlass(
      backgroundColor: bg,
      child: child,
    );
  }
}


