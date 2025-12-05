import 'package:flutter/material.dart';

/// App-wide constants for Agasthi Mobile
class AppConstants {
  // App Information
  static const String appName = 'Agasthi Mobile';
  static const String appVersion = '1.0.0';
  
  // API Configuration (Update when backend is ready)
  // static const String baseUrl = 'https://api.example.com';
  // static const String apiVersion = 'v1';
  
  // Royal Purple and Midnight Blue Colors
  static const Color royalPurple = Color(0xFF572290); // #572290
  static const Color midnightBlue = Color(0xFF2A0A4E); // #2A0A4E
  static const Color darkPurple1 = Color(0xFF1b033d); // #1b033d
  static const Color purpleVariant1 = Color(0xFF6E3BA9); // #6E3BA9
  static const Color purpleVariant2 = Color(0xFF3C2176); // #3C2176
  static const Color purpleVariant3 = Color(0xFF2c0957); // #2c0957
  
  // Luxury Gold Colors
  static const Color luxuryGold = Color(0xFFC7A43B); // #C7A43B
  static const Color luxuryGoldLight = Color(0xFFF6DE8D); // #F6DE8D
  
  // Dark Backgrounds
  static const Color darkBackground1 = Color(0xFF080017); // #080017
  static const Color darkBackground2 = Color(0xFF09001a); // #09001a
  
  // Legacy colors (keeping for compatibility)
  static const Color primaryColor = royalPurple; // Royal Purple
  static const Color accentColor = luxuryGold; // Luxury Gold
  
  // Muted colors for secondary text
  static const Color mutedText = Color(0xFF9E9E9E); // Gray-purple
  
  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0); // Light gray-purple
  
  // Background colors
  static const Color darkPurpleBackground = darkBackground1; // Dark background
  
  // Gradient Royal - linear-gradient(135deg, royal-purple → midnight-blue)
  // Used for royal-themed sections
  static const LinearGradient gradientRoyal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalPurple, midnightBlue],
  );
  
  // Gradient Gold - linear-gradient(135deg, luxury-gold → luxury-gold-light)
  // Used for buttons and gold accents
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [luxuryGold, luxuryGoldLight],
  );
  
  // Gradient Hero - linear-gradient(135deg, midnight-blue → royal-purple → luxury-gold/10%)
  // Main hero section background
  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      midnightBlue,
      royalPurple,
      Color(0x19C7A43B), // luxury-gold with 10% opacity (0x19 = ~10%)
    ],
  );
  
  // Legacy gradients (for backward compatibility)
  static const LinearGradient primaryGradient = gradientRoyal;
  static const LinearGradient accentGradient = gradientGold;
  
  // Text Gradient Gold: from-luxury-gold to-luxury-gold-light
  static const LinearGradient textGradientGold = LinearGradient(
    colors: [luxuryGold, luxuryGoldLight],
  );
  
  // Text Gradient Royal: from-royal-purple to-midnight-blue
  static const LinearGradient textGradientRoyal = LinearGradient(
    colors: [royalPurple, midnightBlue],
  );
  
  // Helper method to create ShaderMask for text gradients
  static ShaderMask createTextGradient({
    required Widget child,
    required Gradient gradient,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child,
    );
  }
  
  // Private constructor to prevent instantiation
  AppConstants._();
}

