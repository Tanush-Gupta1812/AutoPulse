import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Why AutoPulse', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
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
              Text('The Automotive Gap', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                '“Your car already knows it is about to fail. We make it tell you.”',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppTokens.darkAccent : AppTokens.lightAccent,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Battery faults alone cause 1 in 5 roadside breakdowns (RAC UK). OEM apps are brand-locked and expensive, while OBD scanner tools only give confusing code numbers after damage is done.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Pitch Comparison Matrix
              Text('Competitive Advantage', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: (isDark ? AppTokens.darkBorder : AppTokens.lightBorder).withOpacity(0.6)),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1.6),
                    2: FlexColumnWidth(1.6),
                    3: FlexColumnWidth(2.0),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: (isDark ? AppTokens.darkAccent : AppTokens.lightAccent).withOpacity(0.08),
                      ),
                      children: [
                        _buildTableHeader('Feature'),
                        _buildTableHeader('OBD Scanners'),
                        _buildTableHeader('OEM Apps'),
                        _buildTableHeader('AutoPulse'),
                      ],
                    ),
                    _buildTableRow('Early Failure Forecast', 'No (After damage)', 'Limited alerts', 'Yes (Days-to-Fail)', isHighlight: true),
                    _buildTableRow('For Everyday Drivers', 'No (Mechanics)', 'Yes', 'Yes (Plain English)'),
                    _buildTableRow('Learns Car Baseline', 'No (Fixed codes)', 'No', 'Yes (AI Baseline)', isHighlight: true),
                    _buildTableRow('Works on Any Car', 'Yes (Universal)', 'No (Brand locked)', 'Yes (2013+ Any car)'),
                    _buildTableRow('Price to Driver', '₹2,500 - ₹5,000', '₹15,000+ OEM', '₹999 + ₹999/yr', isHighlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pilot Stats
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTokens.darkSurfaceElevated : AppTokens.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NIMS University Pilot Goal', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      'Targeting 100 used cars (3–10 years old) in Jaipur & NCR with local dealership and garage integration.',
                      style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppTokens.darkTextSecondary : AppTokens.lightTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  TableRow _buildTableRow(String feature, String obd, String oem, String autopulse, {bool isHighlight = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(feature, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(obd, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(oem, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(autopulse, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTokens.statusHealthy)),
        ),
      ],
    );
  }
}
