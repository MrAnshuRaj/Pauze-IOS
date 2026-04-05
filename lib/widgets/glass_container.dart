import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    required this.borderRadius,
    this.padding,
    this.onTap,
    this.ripple = false,
    this.activeGlowColor,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool ripple;
  final Color? activeGlowColor;

  @override
  Widget build(BuildContext context) {
    final bool isIos = Platform.isIOS;
    final bool isAndroid = Platform.isAndroid;

    final double blurSigma = isIos ? 25 : (isAndroid ? 20 : 18);
    final Color baseTint =
        isIos ? Colors.white.withValues(alpha: 0.08) : const Color(0x14FFFFFF);
    final Color borderTint =
        isIos ? Colors.white.withValues(alpha: 0.20) : const Color(0x22FFFFFF);

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: baseTint,
      border: Border.all(color: borderTint),
      boxShadow: <BoxShadow>[
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
        if (activeGlowColor != null)
          BoxShadow(
            color: activeGlowColor!.withValues(alpha: isIos ? 0.18 : 0.14),
            blurRadius: 28,
            spreadRadius: 1.2,
          ),
      ],
    );

    final Widget glass = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: decoration,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x29FFFFFF),
                        Color(0x0D000000),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(borderRadius),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.white.withValues(alpha: isIos ? 0.20 : 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    if (!ripple || onTap == null) {
      return onTap == null
          ? glass
          : InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: glass,
            );
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: glass,
      ),
    );
  }
}
