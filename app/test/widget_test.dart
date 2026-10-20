import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/main.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/theme/app_tokens.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AutoPulseApp renders successfully with ProviderScope', (WidgetTester tester) async {
    // Provide a standard phone viewport (390 x 844 pt)
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: AutoPulseApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify brand title renders
    expect(find.text('AutoPulse'), findsOneWidget);
    // Verify OBD-II Status indicator
    expect(find.text('OBD-II Online'), findsOneWidget);
  });

  test('AutoPulse Theme Tokens have correct WCAG AA status colors', () {
    expect(AppTokens.statusHealthy, const Color(0xFF10B981));
    expect(AppTokens.statusWatch, const Color(0xFFF59E0B));
    expect(AppTokens.statusWarning, const Color(0xFFF97316));
    expect(AppTokens.statusCritical, const Color(0xFFEF4444));

    expect(AppTokens.getStatusColor('OK'), AppTokens.statusHealthy);
    expect(AppTokens.getStatusColor('CRITICAL'), AppTokens.statusCritical);
    expect(AppTokens.getScoreColor(92), AppTokens.statusHealthy);
    expect(AppTokens.getScoreColor(54), AppTokens.statusWarning);
  });

  test('Both Dark and Light ThemeData are configured properly', () {
    final dark = AppTheme.darkTheme;
    final light = AppTheme.lightTheme;

    expect(dark.brightness, Brightness.dark);
    expect(light.brightness, Brightness.light);
    expect(dark.scaffoldBackgroundColor, AppTokens.darkBackground);
    expect(light.scaffoldBackgroundColor, AppTokens.lightBackground);
  });
}
