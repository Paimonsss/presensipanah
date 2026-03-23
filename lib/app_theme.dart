import 'dart:ui';
import 'package:flutter/material.dart';

/// ─── PANAH PRESENSI V3 — SOFT MINIMAL DESIGN SYSTEM ───
class AppTheme {
  AppTheme._();

  // ═══════════════ PALETTE ═══════════════
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralDark = Color(0xFFEE5A5A);
  static const Color teal = Color(0xFF4ECDC4);
  static const Color navy = Color(0xFF2C3E50);
  static const Color slate = Color(0xFF7F8C9B);
  static const Color cloud = Color(0xFFF8F9FD);
  static const Color snow = Color(0xFFFFFFFF);
  static const Color lavender = Color(0xFFF0EEFF);
  static const Color mint = Color(0xFFE8FFF5);
  static const Color peach = Color(0xFFFFF0ED);
  static const Color skyBlue = Color(0xFFE8F4FD);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  static const Color error = Color(0xFFE74C3C);

  // ═══════════════ GRADIENTS ═══════════════
  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF8F9FD), Color(0xFFF0EEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════ SHADOWS ═══════════════
  static List<BoxShadow> ultraSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> coralGlow = [
    BoxShadow(
      color: coral.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> navShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, -2),
    ),
  ];

  // ═══════════════ TEXT STYLES ═══════════════
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins',
    color: navy,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: navy,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: navy,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: slate,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: slate,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: slate,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    letterSpacing: 0.5,
  );

  // ═══════════════ INPUT DECORATION ═══════════════
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: body.copyWith(color: slate),
      hintStyle: body.copyWith(color: slate.withValues(alpha: 0.5)),
      filled: true,
      fillColor: cloud,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 1),
      ),
    );
  }

  // ═══════════════ THEME DATA ═══════════════
  static ThemeData get theme => ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: cloud,
        colorScheme: const ColorScheme.light(
          primary: coral,
          secondary: teal,
          surface: snow,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: navy,
          ),
          iconTheme: IconThemeData(color: navy),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            textStyle: button,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: snow,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: navy,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}

// ═══════════════ CORAL BUTTON (pill-shaped) ═══════════════
class CoralButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;

  const CoralButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !isLoading;
    return SizedBox(
      width: width ?? double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled
                  ? LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400])
                  : AppTheme.coralGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: disabled ? null : AppTheme.coralGlow,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : DefaultTextStyle(
                      style: AppTheme.button.copyWith(color: Colors.white),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════ ACCENT CARD (color bar on left) ═══════════════
class AccentCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const AccentCard({
    super.key,
    required this.child,
    this.accentColor = AppTheme.coral,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.ultraSoft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(width: 5, color: accentColor),
              Expanded(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
