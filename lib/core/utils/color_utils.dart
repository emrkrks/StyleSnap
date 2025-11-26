import 'package:flutter/material.dart';

class ColorUtils {
  // Cache for parsed colors to avoid repeated parsing
  static final Map<String, Color> _colorCache = {};

  /// Parse hex string to Color object with caching
  static Color parse(String hex) {
    if (hex.isEmpty) return Colors.grey;

    // Check cache first
    if (_colorCache.containsKey(hex)) {
      return _colorCache[hex]!;
    }

    try {
      final hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        final color = Color(int.parse('FF$hexColor', radix: 16));
        _colorCache[hex] = color;
        return color;
      } else if (hexColor.length == 8) {
        final color = Color(int.parse(hexColor, radix: 16));
        _colorCache[hex] = color;
        return color;
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
