import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme provider (for future theme switching)
final themeProvider = StateProvider<bool>((ref) {
  return true; // true = dark theme (always on for now)
});
