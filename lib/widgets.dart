import 'package:flutter/material.dart';
import 'theme.dart';

class SafeHerLogo extends StatelessWidget {
  final double size;
  final bool isLight;

  const SafeHerLogo({super.key, this.size = 100, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isLight
                  ? [Colors.white, Colors.pink.shade100]
                  : [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black12
                    : AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.shield_rounded,
              size: size * 0.5,
              color: isLight ? AppTheme.primaryColor : Colors.white,
            ),
          ),
        ),
        if (size >= 80) ...[
          const SizedBox(height: 16),
          Text(
            'SAFEHER',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: isLight ? Colors.white : AppTheme.primaryColor,
              shadows: [
                Shadow(
                  color: Colors.black12,
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFCE4EC), // Light Pink
                Colors.white,
              ],
            ),
          ),
        ),
        // Decorative Circles
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor.withOpacity(0.1),
            ),
          ),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }
}