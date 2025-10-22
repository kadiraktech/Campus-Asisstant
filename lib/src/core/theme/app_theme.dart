import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Modern Color Palette (User Approved)
  static const Color _primaryColor = Color(0xFF7B68EE); // MediumSlateBlue
  static const Color _accentColor = Color(0xFFFFF59D); // Light Pastel Yellow

  // Light Theme Colors
  static const Color _lightBackground = Color(0xFFFAF8F5); // Alpine Oat like
  static const Color _lightSurface = Colors.white; // Clean white for surfaces
  static const Color _lightTextPrimary = Color(
    0xFF333333,
  ); // Darker grey for better readability
  static const Color _lightTextSecondary = Color(0xFF555555); // Medium grey

  // Dark Theme Colors
  static const Color _darkBackground = Color(
    0xFF2C2A28,
  ); // Dark Mocha Mousse tone
  static const Color _darkSurface = Color(
    0xFF3E3C3A,
  ); // Slightly lighter than background for cards
  static const Color _darkTextPrimary = Color(
    0xFFEAEAEA,
  ); // Off-white for dark theme text
  static const Color _darkTextSecondary = Color(
    0xFFB0B0B0,
  ); // Lighter grey for secondary text

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white, // Text on primary color buttons
      secondary: _accentColor,
      onSecondary:
          Colors
              .black, // Text on accent color buttons/elements (ensure contrast)
      surface:
          _lightSurface, // Hem yüzeyler hem de genel arka plan için ana yüzey rengi
      onSurface:
          _lightTextPrimary, // surface ve (eski) background üzerindeki metinler
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    primaryColor: _primaryColor, // Still useful for some older widgets
    scaffoldBackgroundColor:
        _lightBackground, // Bu genel arka plan için kalacak
    cardTheme: CardTheme(
      elevation: 1.5, // Subtle elevation
      color: _lightSurface,
      surfaceTintColor: Colors.transparent, // M3 style
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Slightly softer
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightSurface, // Or _lightBackground for a flatter look
      foregroundColor: _lightTextPrimary,
      elevation: 0.5, // Minimal elevation
      iconTheme: const IconThemeData(color: _primaryColor),
      titleTextStyle: GoogleFonts.poppins(
        color: _lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: _lightTextPrimary, fontSize: 16),
      bodyMedium: GoogleFonts.poppins(color: _lightTextSecondary, fontSize: 14),
      titleLarge: GoogleFonts.poppins(
        color: _lightTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: GoogleFonts.poppins(
        color: _primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: GoogleFonts.poppins(
        color: _lightTextSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      labelLarge: GoogleFonts.poppins(
        // For buttons
        color: Colors.white, // Default for primary buttons
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 1.0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _lightSurface.withAlpha(
        240,
      ), // Slightly off-white or very light grey
      hintStyle: GoogleFonts.poppins(
        color: _lightTextSecondary.withAlpha((150)), // Lighter hint
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor, // Using primary for FAB for consistency
      foregroundColor: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    iconTheme: const IconThemeData(color: _primaryColor),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 0.5,
      space: 0.5,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _lightTextSecondary.withAlpha(180),
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 2.0,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: GoogleFonts.poppins(
        color: _lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      contentTextStyle: GoogleFonts.poppins(
        color: _lightTextSecondary,
        fontSize: 14,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    cardColor: _darkSurface,
    dividerColor: _darkTextSecondary.withAlpha(100),

    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: _darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: _darkTextPrimary),
    ),

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      bodyLarge: GoogleFonts.poppins(
        color: _darkTextPrimary.withAlpha((255 * 0.87).round()),
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: _darkTextSecondary.withAlpha((255 * 0.75).round()),
        fontSize: 14,
      ),
      titleLarge: GoogleFonts.poppins(
        color: _darkTextPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: GoogleFonts.poppins(
        color: _primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: GoogleFonts.poppins(
        color: _darkTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      labelLarge: GoogleFonts.poppins(
        color: _darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),

    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 1.0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: _darkSurface.withAlpha(240),
      hintStyle: GoogleFonts.poppins(color: _darkTextSecondary.withAlpha(180)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
    ),

    iconTheme: IconThemeData(color: _darkTextPrimary),

    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: _accentColor,
      onSecondary: Colors.black,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      error: Colors.redAccent.shade100,
      onError: Colors.black,
    ),

    cardTheme: CardTheme(
      elevation: 1.5,
      color: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _darkTextSecondary.withAlpha(180),
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 2.0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: _darkSurface,
      textStyle: TextStyle(
        color: _darkTextPrimary.withAlpha((255 * 0.87).round()),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: _darkBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: GoogleFonts.poppins(
        color: _darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      contentTextStyle: GoogleFonts.poppins(
        color: _darkTextSecondary,
        fontSize: 14,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkSurface,
      contentTextStyle: TextStyle(color: _darkTextPrimary),
      actionTextColor: _accentColor,
    ),
    useMaterial3: true,
  );
}

// Helper for opacity to avoid deprecated member use
extension ColorAlpha on Color {
  Color withAlphaInt(int alpha) {
    return withAlpha(alpha);
  }
}
