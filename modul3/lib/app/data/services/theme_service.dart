import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static const String _keyThemeMode = 'theme_mode';
  late SharedPreferences _prefs;
  
  final isDarkMode = false.obs;

  // Initialize service
  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved theme
    final savedTheme = _prefs.getBool(_keyThemeMode) ?? false;
    isDarkMode.value = savedTheme;
    
    // Apply theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    return this;
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _prefs.setBool(_keyThemeMode, isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Get current theme mode
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}

// ==========================================
// LIGHT THEME
// ==========================================
ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E5B53),
    scaffoldBackgroundColor: const Color(0xFFF0F0F0),
    cardColor: Colors.white,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E5B53),
      secondary: Color(0xFF388E3C),
      surface: Colors.white,
      background: Color(0xFFF0F0F0),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF0F0F0),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1E5B53)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1E5B53),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    iconTheme: const IconThemeData(
      color: Color(0xFF1E5B53),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Color(0xFF1E5B53)),
      titleMedium: TextStyle(color: Color(0xFF1E5B53)),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E5B53),
        foregroundColor: Colors.white,
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1E5B53),
      foregroundColor: Colors.white,
    ),
    
    useMaterial3: true,
  );
}

// ==========================================
// DARK THEME
// ==========================================
ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF26A69A),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF26A69A),
      secondary: Color(0xFF66BB6A),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF26A69A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF26A69A),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    iconTheme: const IconThemeData(
      color: Color(0xFF26A69A),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Color(0xFF26A69A)),
      titleMedium: TextStyle(color: Color(0xFF26A69A)),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF26A69A),
      foregroundColor: Colors.white,
    ),
    
    useMaterial3: true,
  );
}