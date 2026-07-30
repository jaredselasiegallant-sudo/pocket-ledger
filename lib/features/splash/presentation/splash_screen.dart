import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/features/dashboard/presentation/main_navigation_shell.dart';

/// Precision Utilitarian Splash Screen
/// Deep Navy background with animated loading indicator
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style for dark splash
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1C2F),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Loading bar animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loadingAnimation = Tween<double>(begin: -0.4, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _loadingController.repeat();

    // Navigate after delay
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToApp();
      }
    });
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1C2F),
      body: Stack(
        children: [
          // ─── Main Content ───
          Center(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title
                  Text(
                    'PocketLedger',
                    style: AppTypography.displayLarge.copyWith(
                      color: const Color(0xFFBEC6E0),
                      letterSpacing: -0.02,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Offline-First & Privacy-Focused',
                    style: AppTypography.bodyLarge.copyWith(
                      color: const Color(0xFF7C839B).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Loading Indicator (Bottom) ───
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Loading Bar
                  SizedBox(
                    width: 140,
                    height: 2,
                    child: Stack(
                      children: [
                        // Background track
                        Container(
                          width: 140,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        // Animated progress
                        AnimatedBuilder(
                          animation: _loadingAnimation,
                          builder: (context, child) {
                            return Positioned(
                              left: _loadingAnimation.value * 140 - 56,
                              child: Container(
                                width: 56,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBEC6E0),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Text
                  Text(
                    'INITIALIZING SECURE VAULT',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF7C839B).withValues(alpha: 0.6),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Vignette Overlay ───
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Color(0x660D1C2F),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
