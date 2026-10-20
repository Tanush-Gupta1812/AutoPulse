import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Membership & Plans', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pitch Banner
              Text('Smart Protection for Your Car', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'One highway breakdown costs upwards of ₹7,500. AutoPulse pays for itself the first time it warns you.',
                style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
              ),
              const SizedBox(height: 20),

              // Hardware Dongle Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                      child: Icon(Icons.router, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('AutoPulse OBD-II Dongle', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                              Text('₹999', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('One-time hardware purchase • 2-Year Replacement Warranty • Free delivery in 2 days', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Premium Plan Card (Hero)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(
                    color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                    width: 1.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹999',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                              ),
                            ),
                            Text(
                              '/year',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('AutoPulse AI Cloud Intelligence', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Only ₹83 per month. Complete predictive maintenance for everyday drivers.', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary)),
                    const SizedBox(height: 16),
                    _buildFeatureItem(context, 'Days-to-Failure AI Forecasts for 6 Subsystems'),
                    _buildFeatureItem(context, 'Per-car baseline learning (learns YOUR engine habits)'),
                    _buildFeatureItem(context, 'Instant roadside breakdown warning alerts'),
                    _buildFeatureItem(context, 'Partner garage priority booking & discount tokens'),
                    _buildFeatureItem(context, 'Causal diagnostic proof & money saved calculations'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AutoPulse AI Membership activated for 1 Year!')),
                          );
                        },
                        child: const Text('Get Dongle + 1-Year AI Protection (₹1,998)'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Free Scanner Tier Comparison
              Text('Compare Plans', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildComparisonRow(context, 'Raw OBD Live Stream', true, true),
                    _buildComparisonRow(context, 'Standard DTC Code Reading', true, true),
                    _buildComparisonRow(context, 'Days-to-Failure Forecasting', false, true),
                    _buildComparisonRow(context, 'Per-Car Baseline Learning', false, true),
                    _buildComparisonRow(context, 'Partner Garage Booking & Discounts', false, true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppTokens.statusHealthy),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, String feature, bool free, bool premium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(feature, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
          SizedBox(
            width: 60,
            child: Center(
              child: Icon(free ? Icons.check : Icons.close, size: 18, color: free ? AppTokens.statusHealthy : Colors.grey),
            ),
          ),
          SizedBox(
            width: 70,
            child: Center(
              child: Icon(premium ? Icons.check_circle : Icons.close, size: 18, color: premium ? (isDark ? AppTokens.darkAccent : AppTokens.lightAccent) : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
