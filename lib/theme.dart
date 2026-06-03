import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF4D94);

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,

    primaryColor: primary,

    scaffoldBackgroundColor:
    const Color(0xFF050B2C),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF050B2C),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1B1E4B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),
      ),
    ),

    bottomNavigationBarTheme:
    const BottomNavigationBarThemeData(
      backgroundColor:
      Color(0xFF161B33),
      selectedItemColor:
      Color(0xFFFF4D94),
      unselectedItemColor:
      Colors.grey,
      type:
      BottomNavigationBarType.fixed,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}