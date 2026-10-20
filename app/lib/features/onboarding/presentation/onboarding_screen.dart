import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'step': '01',
      'title': 'Plug & Pair in 30 Seconds',
      'subtitle': 'The compact AutoPulse OBD-II dongle plugs into any car built since 2013. Live engine telemetry streams immediately to your phone over Bluetooth Low Energy.',
      'icon': Icons.bluetooth_searching,
      'badge': 'Universal Compatibility',
    },
    {
      'step': '02',
      'title': 'AI Learns Your Car’s Normal',
      'subtitle': 'Unlike generic scanners that only show codes after breakdown, AutoPulse models your car’s individualized baseline to spot micro-drifts in battery voltage, thermal regulation, and fuel trims.',
      'icon': Icons.insights,
      'badge': 'Predictive Diagnostics',
    },
    {
      'step': '03',
      'title': 'Pre-empt Breakdown & Save ₹',
      'subtitle': 'Receive plain-English forecasts like "Battery fails in ~9 days" before roadside disaster strikes. Book partner garages at exclusive pre-emptive rates and avoid towing fees.',
      'icon': Icons.health_and_safety,
      'badge': '₹4,500+ Avg Savings',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Brand
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        ),
                        child: Icon(
                          Icons.electric_bolt,
                          color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AutoPulse',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                        color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large Graphic Card
                        Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                            border: Border.all(
                              color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    slide['icon'] as IconData,
                                    size: 56,
                                    color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                    border: Border.all(
                                      color: isDark ? AppTokens.darkBorderHigh : AppTokens.lightBorderHigh,
                                    ),
                                  ),
                                  child: Text(
                                    slide['badge'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Step Pill
                        Text(
                          'STEP ${slide['step']}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          slide['title'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          slide['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Navigation & Progress Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent)
                              : (isDark ? AppTokens.darkBorderHigh : AppTokens.lightBorderHigh),
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/pair');
                        }
                      },
                      child: Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
