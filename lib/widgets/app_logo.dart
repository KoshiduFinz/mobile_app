import 'package:flutter/material.dart';

/// App Logo Widget - Displays the Agasthi Mobile logo
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;

  const AppLogo({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height ?? 80,
      width: width ?? 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading logo: $error');
        return const SizedBox(
          height: 80,
          width: 200,
          child: Center(
            child: Text(
              'Logo not found',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

